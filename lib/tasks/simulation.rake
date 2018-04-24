require 'faker'

num_users_per_constituency = 30
num_candidates_per_constituency = 10
num_issues_per_constituency = 20

def simulate_voting(num_users_per_constituency,
                    num_candidates_per_constituency,
                    election,
                    users, const)

  religions = Religion.all.map(&:name)
  castes = Caste.all.map(&:name)
  professions = Profession.all.map(&:name)
  education_levels = Education.all.map(&:name)

  puts "Start creating candidates"
  candidates = []
  num_candidates_per_constituency.times do
    canidate = {
      email: Faker::Internet.unique.email,
      name: Faker::Name.unique.name,
      phone: Faker::PhoneNumber.phone_number,
      constituency: const,
      religion: religions.sample,
      caste: castes.sample,
      profession: professions.sample,
      education: education_levels.sample,
      pincode: "560001",
      income: "Rs 100000",
      assets: "Rs 1000000",
      liabilities: "Rs 500000",
      criminal_cases: "1. Murder Case",
      website: "mpdmukh@neta.com",
      twitter: "twitter.com/mpdmukh",
      facebook: "facebook.com/mpdmukh"
    }

    email = canidate[:email]
    name = canidate[:name]
    phone = canidate[:phone]
    constituency = canidate[:constituency]
    religion = canidate[:religion]
    caste = canidate[:caste]
    profession = canidate[:profession]
    education = canidate[:education]
    income = canidate[:income]
    assets = canidate[:assets]
    liabilities = canidate[:liabilities]
    criminal_cases = canidate[:criminal_cases]
    website = canidate[:website]
    twitter = canidate[:twitter]
    facebook = canidate[:facebook]
    cand = Candidate.new(phone_number: Faker::PhoneNumber.phone_number)

    cand.profile = Profile.new
    cand.phone_number = phone
    profile = cand.profile
    profile.name = name
    profile.religion = Religion.find_by(name: religion)
    profile.caste = Caste.find_by(name: caste)
    profile.profession = Profession.find_by(name: profession)
    profile.education = Education.find_by(name: education)
    profile.contact[:pincode] = canidate[:pincode]
    profile.financials[:income] = income if income
    profile.financials[:assets] = assets if assets
    profile.financials[:liabilities] = liabilities if liabilities
    profile.civil_record[:criminal_cases] = criminal_cases if criminal_cases
    profile.contact[:email] = email if email
    profile.contact[:website] = website if website
    profile.contact[:twitter] = twitter if twitter
    profile.contact[:facebook] = facebook if facebook

    cand.profile.user = User.new
    cand.profile.user.email = email
    cand.profile.user.name = name
    cand.profile.user.firebase_user_id = SecureRandom.urlsafe_base64(nil, false)
    cand.profile.user.phone_number = phone
    cand.profile.user.skip_password_validation = true

    candidates << cand
  end
  candidates.each(&:save!)
  puts "End creating candidates"

  puts "Start creating candidatures"
  candidatures = []
  candidates.each do |_cand|
    candidatures << Candidature
                    .create!(
                      candidate_id: _cand.id,
                      party: Party.all.sample, election: election,
                      constituency: const,
                      declared: false, result: ""
                    )
  end
  puts "End creating candidatures"

  puts "Start voting candidates"
  first_votes = []
  users.take(num_users_per_constituency - 2).each do |user|
    candidature = candidatures[rand(candidatures.count)]
    first_votes << CandidateVote.create!(user_id: user.id, candidature_id: candidature.id, election_id: election.id, is_valid: true, previous_vote: nil)
    sleep 1.seconds
  end

  # Change some votes
  first_votes.take(2).each do |first_vote|
    candidature = first_vote.candidature
    other_candidature = Candidature.where(constituency_id: const.id, election_id: election.id).where.not(id: candidature.id).first
    CandidateVote.create!(user_id: first_vote.user.id, election_id: election.id, candidature_id: other_candidature.id, is_valid: true, previous_vote: first_vote)
    sleep 1.seconds
  end
  puts "End voting candidates"
end

def simulate_users(_num_users, const)
  religions = Religion.all.map(&:name)
  castes = Caste.all.map(&:name)
  professions = Profession.all.map(&:name)
  education_levels = Education.all.map(&:name)

  users = []
  puts "Start creating users"
  _num_users.times do
    user = {
      email: Faker::Internet.unique.email,
      name: Faker::Name.name,
      phone: Faker::PhoneNumber.phone_number,
      constituency: const,
      religion: religions.sample,
      caste: castes.sample,
      profession: professions.sample,
      education: education_levels.sample,
      pincode: "560001",
      income: "Rs 100000",
      assets: "Rs 1000000",
      liabilities: "Rs 500000",
      criminal_cases: "1. Murder Case",
      website: "mpdmukh@neta.com",
      twitter: "twitter.com/mpdmukh",
      facebook: "facebook.com/mpdmukh"
    }

    email = user[:email]
    name = user[:name]
    phone = user[:phone]
    constituency = user[:constituency]
    religion = user[:religion]
    caste = user[:caste]
    profession = user[:profession]
    education = user[:education]
    income = user[:income]
    assets = user[:assets]
    liabilities = user[:liabilities]
    criminal_cases = user[:criminal_cases]
    website = user[:website]
    twitter = user[:twitter]
    facebook = user[:facebook]
    new_user = User.new
    new_user.email = email
    new_user.name = name
    new_user.firebase_user_id = SecureRandom.urlsafe_base64(nil, false)
    new_user.profile = Profile.new
    new_user.phone_number = phone
    new_user.assembly_constituency = constituency if constituency
    profile = new_user.profile
    profile.name = name
    profile.religion = Religion.find_by(name: religion)
    profile.caste = Caste.find_by(name: caste)
    profile.profession = Profession.find_by(name: profession)
    profile.education = Education.find_by(name: education)
    profile.contact[:pincode] = user[:pincode]
    profile.financials[:income] = income if income
    profile.financials[:assets] = assets if assets
    profile.financials[:liabilities] = liabilities if liabilities
    profile.civil_record[:criminal_cases] = criminal_cases if criminal_cases
    profile.contact[:email] = email if email
    profile.contact[:website] = website if website
    profile.contact[:twitter] = twitter if twitter
    profile.contact[:facebook] = facebook if facebook
    new_user.skip_password_validation = true
    users << new_user
  end
  users.each(&:save!)
  puts "End creating users"
  users
end

namespace :simulation do
  desc "Creates election and voting simulation for a given state"
  task :election, [:state_id] => [:environment] do |_task, args|
    if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
      puts "~" * 80
      state_id = args[:state_id]
      puts "Starting simulation for state #{state_id}"
      cs = CountryState.find_by_code!(state_id)
      puts "Destroy existing elections, users, candidatures in this state #{cs.name}"
      cs.elections.each(&:destroy)

      cs.assembly_constituencies.each do |_const|
        puts "Clearing existing issues & polls for #{_const.name}"
        _const.issues.destroy_all
        _const.polls.destroy_all
      end

      cs.assembly_constituencies.each do |_const|
        _const.candidatures.each do |_candidature|
          _candidature.candidate.try(:destroy)
        end
        _const.candidatures.destroy_all
      end
      cs.parliamentary_constituencies.each do |_const|
        _const.candidatures.each do |_candidature|
          _candidature.candidate.try(:destroy)
        end
        _const.candidatures.destroy_all
      end
      cs.assembly_constituencies.each do |const|
        const.users.each { |item| item.activities.destroy_all }
        const.users.each { |item| item.profile.try(:destroy) }
        const.users.destroy_all
      end

      parliamentary_simulated = {}

      prev_election = Election.where(country_state: cs, kind: Election::KIND_ASSEMBLY).where('ends_at > ?', DateTime.now).where('starts_at < ?', DateTime.now).first
      if prev_election
        # there is an existing election which can be used
        election_assembly = prev_election
        puts "Found an existing valid assembly election, using it"
      else
        puts "Creating a new election for assembly"
        election_assembly = Election.create!(
          country_state: cs,
          kind: Election::KIND_ASSEMBLY,
          starts_at: 200.days.ago,
          ends_at: 200.days.from_now
        )
      end

      prev_election = Election.where(kind: Election::KIND_PARLIAMENT).where('ends_at > ?', DateTime.now).where('starts_at < ?', DateTime.now).first
      if prev_election
        election_parliament = prev_election
        puts "Found an existing valid parliamentary election, using it"
      else
        puts "Creating a new parliamentary election"
        election_parliament = Election.create!(
          kind: Election::KIND_PARLIAMENT,
          starts_at: 200.days.ago,
          ends_at: 200.days.from_now
        )
      end

      cs.parliamentary_constituencies.take(2).each do |_parl_const|
        puts "=" * 80
        puts "Start Working with parliamentary constituency"
        puts "Name: #{_parl_const.name}"
        puts "Id: #{_parl_const.id}"

        parl_users = []
        _parl_const.children.take(3).each do |const|
          puts "#" * 80
          puts "Working with assembly constituency"
          puts "Name: #{const.name}"
          puts "Id: #{const.id}"
          puts "-" * 80

          users = simulate_users(num_users_per_constituency, const)
          parl_users += users
          puts "Start creating election for assembly and simulate voting"
          simulate_voting(num_users_per_constituency,
                          num_candidates_per_constituency,
                          election_assembly,
                          users, const)
          puts "-" * 80
          puts "#" * 80
        end
        puts "Start creating election for parliament and simulate voting"
        simulate_voting(num_users_per_constituency,
                        num_candidates_per_constituency,
                        election_parliament,
                        parl_users, _parl_const)
        puts "End Working with parliamentary constituency"
        puts "Name: #{_parl_const.name}"
        puts "Id: #{_parl_const.id}"
        puts "=" * 80
      end
      puts "~" * 80
    else
      puts "Can run only in dev mode"
    end
  end

  desc "Rewires images of user, leader and post for given states, assumes that voting with simulation:election, simulation:issues is already setup"
  task :rework_images, [:image_type, :state_id] => [:environment] do |_task, _args|
    if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
      image_type = _args[:image_type]
      state_id = _args[:state_id]
      puts "Starting simulation for state #{state_id}"
      cs = CountryState.find_by_code!(state_id)
      image_resources_csv = File.read(
        Rails.root.join('db', 'csv', 'image_resources.csv')
      )
      image_resources = CSV.parse(image_resources_csv, headers: true)
      user_images = []
      leader_images = []
      issue_images = []
      image_resources.each do |image_obj|
        resource_type = image_obj["resource_type"]
        resource_url = image_obj["resource_url"]
        case resource_type
        when "user"
          user_images << resource_url
        when "leader"
          leader_images << resource_url
        when "issues"
          issue_images << resource_url
        end
      end
      puts "+" * 80
      puts "---- User Images -----"
      user_images.each do |image|
        puts image
      end
      puts "+" * 80

      puts "+" * 80
      puts "---- Leader Images -----"
      leader_images.each do |image|
        puts image
      end
      puts "+" * 80

      puts "+" * 80
      puts "---- Issue Images -----"
      issue_images.each do |image|
        puts image
      end
      puts "+" * 80

      case image_type
      when 'user'
        puts "+" * 80
        puts "---- Update user images -----"
        profiles = []
        cs.parliamentary_constituencies.each do |_parl_const|
          _parl_const.children.each do |_const|
            _const.users.each do |user|
              profile = user.profile
              profile.remote_profile_pic_url = user_images.sample
              profiles << profile
              puts "user with name #{profile.name} rewired to image #{profile.remote_profile_pic_url}"
            end
          end
        end
        puts "Saving images of count #{profiles.count}...."
        profiles.each(&:save!)
        puts "+" * 80
      when 'leader'
        puts "+" * 80
        puts "---- Update leader images -----"
        profiles = []

        cs.parliamentary_constituencies.each do |_parl_const|
          _parl_const.candidates.select(:id).uniq.each do |cand|
            profile = cand.profile
            profile.remote_profile_pic_url = leader_images.sample
            profiles << profile
            puts "Candidate with name #{profile.name} rewired to image #{profile.remote_profile_pic_url}"
          end
          _parl_const.children.each do |_const|
            _const.candidates.select(:id).uniq.each do |cand|
              profile = cand.profile
              profile.remote_profile_pic_url = leader_images.sample
              profiles << profile
              puts "Candidate with name #{profile.name} rewired to image #{profile.remote_profile_pic_url}"
            end
          end
        end
        puts "Saving images of count #{profiles.count}...."
        profiles.each(&:save!)
        puts "+" * 80
      when 'post'
        puts "+" * 80
        puts "---- Update post images -----"
        posts = []
        total_image_count = 0
        cs.parliamentary_constituencies.each do |_parl_const|
          _parl_const.children.each do |_const|
            _const.issues.each do |issue|
              num_images = [1, 2, 3, 4].sample
              attachments = []
              num_images.times do
                attachment = Attachment.new
                attachment.remote_media_url = issue_images.sample
                attachments << attachment
              end
              issue.attachments = attachments
              total_image_count += num_images
              posts << issue
              puts "Issue with id #{issue.id} has been given new images"
            end
            _const.polls.each do |poll|
              attachments = []
              attachment = Attachment.new
              attachment.remote_media_url = issue_images.sample
              attachments << attachment
              poll.attachments = attachments
              total_image_count += 1
              posts << poll
              puts "Poll with id #{poll.id} has been given new image"
            end
          end
        end
        puts "Saving images of count #{total_image_count}...."
        posts.each(&:save!)
        puts "+" * 80
      end
    else
      puts "Works only in development"
    end
  end

  desc "Creates issues in a state where election is already simulated "
  task :issues, [:state_id] => [:environment] do |_task, _args|
    if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
      puts "-" * 80
      state_id = _args[:state_id]
      cs = CountryState.find_by_code!(state_id)
      constituencies = cs.constituncies.where(id: Candidature.all.map(&:constituency_id))
      puts "Found constituencies for which candidatures exist #{constituencies.count}"
      puts "Filtering only assembly constituencies"
      assembly_constituencies = constituencies.where.not(parent_id: nil)
      puts "Found assembly constituencies for which candidatures exist #{assembly_constituencies.count}"
      assembly_constituencies.each do |_const|
        puts "Clearing existing issues & polls for #{_const.name}"
        _const.issues.destroy_all
        _const.polls.destroy_all
      end
      assembly_constituencies.each do |_const|
        puts "=" * 80
        puts "Now working on #{_const.name} with id #{_const.id}"
        puts "Creating new issues & polls"
        issues = []
        polls = []
        num_issues_per_constituency.times do |_index|
          issues << if _index % 3 === 0
                      poll = Poll.create!(
                        question: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                        poll_options: rand(2..4).times.map { |_i| PollOption.create(answer: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote) },
                        region: _const,
                        user: _const.users.sample
                      )
                      polls << poll
                      poll
                    else
                      Issue.create!(
                        title: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                        description: Faker::Lorem.paragraph,
                        region: _const,
                        user: _const.users.sample
                      )
                    end
        end
        ## throw in some comments and likes
        issues.take(num_issues_per_constituency - rand(5)).each do |_issue|
          rand(10).times do
            _issue.comments.create!(user: _const.users.sample, text: Faker::Lorem.paragraph)
          end

          rand(10).times do
            _issue.likes.create!(user: _const.users.sample)
          end
        end

        ## perform voting for polls
        10.times do
          polls.each do |poll|
            PollVote.create!(poll_id: poll.id, user_id: _const.users.sample.id, poll_option_id: poll.poll_options.sample.id)
          end
        end

        puts "Total issues & polls created #{issues.count}"
        puts "=" * 80
      end
      puts "-" * 80
    else
      puts "Works only in development mode"
    end
  end

  desc "Creates election, voting, posts in a given state and a constituency"
  task :election_and_issues, [:state_code, :kind, :const_name] => [:environment] do |_task, args|
    if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
      puts "~" * 80
      state_id = args[:state_code]
      puts "Starting simulation for state #{state_id}"
      cs = CountryState.find_by_code!(state_id)
      const = cs.constituencies.where(name: args[:const_name], kind: args[:kind]).first
      if const
        puts "Found constituency '#{const.try(:name)}' of kind '#{const.try(:kind)}'"
        ## Simulate elections and voting
        puts "Clearing existing issues & polls for #{const.name}"
        const.issues.destroy_all
        const.polls.destroy_all

        puts "Clearing existing candidatures for #{const.name}"
        const.candidatures.each do |_candidature|
          _candidature.candidate.try(:destroy)
        end
        const.candidatures.destroy_all

        puts "Clearing existing users for #{const.name}"
        const.users.each { |item| item.activities.destroy_all }
        const.users.each { |item| item.profile.try(:destroy) }
        const.users.destroy_all
        puts "#" * 80
        puts "Working with assembly constituency"
        puts "Name: #{const.name}"
        puts "Id: #{const.id}"
        puts "-" * 80

        users = simulate_users(num_users_per_constituency, const)
        puts "Start creating election for assembly and simulate voting"

        if const.is_assembly?
          prev_election = Election.where(country_state: cs, kind: Election::KIND_ASSEMBLY).where('ends_at > ?', DateTime.now).where('starts_at < ?', DateTime.now).first
          if prev_election
            # there is an existing election which can be used
            election = prev_election
            puts "Found an existing valid assembly election, using it"
          else
            puts "Creating a new election for assembly"
            election = Election.create!(
              country_state: cs,
              kind: Election::KIND_ASSEMBLY,
              starts_at: 200.days.ago,
              ends_at: 200.days.from_now
            )
          end
        elsif const.is_parliament?
          prev_election = Election.where(kind: Election::KIND_PARLIAMENT).where('ends_at > ?', DateTime.now).where('starts_at < ?', DateTime.now).first
          if prev_election
            election = prev_election
            puts "Found an existing valid parliamentary election, using it"
          else
            puts "Creating a new parliamentary election"
            election = Election.create!(
              kind: Election::KIND_PARLIAMENT,
              starts_at: 200.days.ago,
              ends_at: 200.days.from_now
            )
          end
        end

        simulate_voting(num_users_per_constituency,
                        num_candidates_per_constituency,
                        election,
                        users, const)
        const.reload
        puts "-" * 80
        puts "#" * 80
        if const.is_assembly?
          puts "Start working on creating issues and polls"
          puts "=" * 80
          puts "Now working on #{const.name} with id #{const.id}"
          puts "Creating new issues & polls"
          issues = []
          polls = []
          num_issues_per_constituency.times do |_index|
            issues << if _index % 3 === 0
                        poll = Poll.create!(
                          question: [Faker::RickAndMorty,
                                     Faker::BackToTheFuture,
                                     Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                          poll_options: rand(2..4).times.map do |_i|
                                          PollOption.create(
                                            answer: [Faker::RickAndMorty,
                                                     Faker::BackToTheFuture,
                                                     Faker::HitchhikersGuideToTheGalaxy].sample.quote
                                          )
                                        end,
                          region: const,
                          user_id: const.users.sample.id
                        )
                        polls << poll
                        poll
                      else
                        Issue.create!(
                          title: [Faker::RickAndMorty, Faker::BackToTheFuture,
                                  Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                          description: Faker::Lorem.paragraph,
                          region: const,
                          user: const.users.sample
                        )
                      end
          end

          # Create admin poll for this constituency
          admin_poll = Poll.create!(
            question: [Faker::RickAndMorty,
                       Faker::BackToTheFuture,
                       Faker::HitchhikersGuideToTheGalaxy].sample.quote,
            poll_options: rand(2..4).times.map do |_i|
                            PollOption.create(
                              answer: [Faker::RickAndMorty,
                                       Faker::BackToTheFuture,
                                       Faker::HitchhikersGuideToTheGalaxy].sample.quote
                            )
                          end,
            region: const
          )
          polls << admin_poll

          ## throw in some comments and likes
          issues.take(num_issues_per_constituency - rand(5)).each do |_issue|
            rand(10).times do
              _issue.comments.create!(user: const.users.sample,
                                      text: Faker::Lorem.paragraph)
            end

            rand(10).times do
              _issue.likes.create!(user: const.users.sample)
            end
          end

          ## Lets take one issue and have the candidate comment on it
          issues.sample.comments.create!(user: const.candidates.sample.profile.user,
                                         text: Faker::Lorem.paragraph)

          ## perform voting for polls
          10.times do
            polls.each do |poll|
              PollVote.create!(poll_id: poll.id,
                               user_id: const.users.sample.id,
                               poll_option_id: poll.poll_options.sample.id)
            end
          end

          # admin poll, let everyone participate
          const.users.each do |user|
            PollVote.create!(poll_id: admin_poll.id, user_id: user.id,
                             poll_option_id: admin_poll.poll_options.sample.id)
            sleep 1.second
            # let them change their decision
            PollVote.create!(poll_id: admin_poll.id, user_id: user.id,
                             poll_option_id: admin_poll.poll_options.sample.id)
          end

          puts "Total issues & polls created #{issues.count}"
          puts "=" * 80
        else
          puts "Not adding issues/polls for parliamentary constituency"
        end

        ## Add images to users, candidates and issues

        image_resources_csv = File.read(
          Rails.root.join('db', 'csv', 'image_resources.csv')
        )
        image_resources = CSV.parse(image_resources_csv, headers: true)
        user_images = []
        leader_images = []
        issue_images = []
        image_resources.each do |image_obj|
          resource_type = image_obj["resource_type"]
          resource_url = image_obj["resource_url"]
          case resource_type
          when "user"
            user_images << resource_url
          when "leader"
            leader_images << resource_url
          when "issues"
            issue_images << resource_url
          end
        end

        profiles = []
        puts "=" * 80
        puts "Start working on images for users"
        users.each do |user|
          profile = user.profile
          profile.remote_profile_pic_url = user_images.sample
          profiles << profile
          puts "user with name #{profile.name} rewired to image #{profile.remote_profile_pic_url}"
        end
        puts "Saving images of count #{profiles.count}"
        profiles.each(&:save!)
        puts "=" * 80

        profiles = []
        puts "=" * 80
        puts "Start working on images for candidates"
        const.candidates.select(:id).uniq.each do |cand|
          profile = cand.profile
          profile.remote_profile_pic_url = leader_images.sample
          profiles << profile
          puts "Candidate with name #{profile.name} rewired to image #{profile.remote_profile_pic_url}"
        end
        puts "Saving images of count #{profiles.count}"
        profiles.each(&:save!)
        puts "=" * 80

        puts "=" * 80
        puts "Start working on images for issues"
        total_image_count = 0
        posts = []
        const.issues.each do |issue|
          num_images = [1, 2, 3, 4].sample
          attachments = []
          num_images.times do
            attachment = Attachment.new
            attachment.remote_media_url = issue_images.sample
            attachments << attachment
          end
          issue.attachments = attachments
          total_image_count += num_images
          posts << issue
          puts "Issue with id #{issue.id} has been given new images"
        end
        const.polls.each do |poll|
          attachments = []
          attachment = Attachment.new
          attachment.remote_media_url = issue_images.sample
          attachments << attachment
          poll.attachments = attachments
          total_image_count += 1
          posts << poll
          puts "Poll with id #{poll.id} has been given new image"
        end
        puts "Saving images of count #{total_image_count}...."
        posts.each(&:save!)
        puts "+" * 80
        puts "=" * 80
      else
        puts "Could not find a constituency, nothing to do."
      end
      puts "~" * 80
    else
      puts "Can run only in dev mode"
    end
  end

  desc "Create election and issues for given parliament"
  task :election_and_issues_parliament, [:state_code, :const_name] => [:environment] do |_task, args|
    puts "~" * 80
    state_id = args[:state_code]
    puts "Starting simulation for state #{state_id}"
    cs = CountryState.find_by_code!(state_id)
    const = cs.constituencies.where(name: args[:const_name], kind: 'parliamentary').first
    if const
      puts "Parliament constituency #{const.name} in #{cs.name} exists"
      puts "Going ahead with simulation across all assemblies of this parliamentary constituency"

      puts "=" * 80
      puts "Start on parliamentary constituency #{const.name}"
      Rake::Task["simulation:election_and_issues"].invoke(cs.code, 'parliamentary', const.name)
      puts "=" * 80

      Rake::Task["simulation:election_and_issues"].reenable

      const.children.each do |child|
        puts "=" * 80
        puts "Start on assembly constituency #{child.name}"
        Rake::Task["simulation:election_and_issues"].invoke(cs.code, 'assembly', child.name)
        puts "=" * 80
        Rake::Task["simulation:election_and_issues"].reenable
      end

    else
      puts "Parliament constituency with name '#{args[:const_name]}' in state '#{args[:state_code]}' does not exists"
    end
  end

  desc "Destroys all simulations bringing environment to clean state. Note that influx db is also dropped"
  task destroy_all: [:environment] do
    if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
      puts "-" * 80
      puts "Cleaning up and resetting influx"
      Rake::Task["influx:destroy"].invoke
      puts "-" * 80

      puts "-" * 80
      puts "Clear db now"
      puts "Destroying users......"
      User.destroy_all
      puts "Destroying candidates......"
      Candidate.destroy_all
      puts "Destroying elections......"
      Election.destroy_all
      puts "Destroying candidatures......"
      Candidature.destroy_all
      puts "Destroying posts......"
      Post.destroy_all
      puts "Destroying comments......"
      Comment.destroy_all
      puts "Destroying likes......"
      Like.destroy_all
      puts "Destroying activities......"
      Activity.destroy_all

      puts "-" * 80
    else
      puts "Can only be done in simulation mode or development mode"
    end
  end

  desc "Makes all necessary arrangements to setup, simulations. Mostly influx"
  task setup: [:environment] do
    if Rails.env.development? || ENV['SIMULATION_MODE'].to_i == 1
      puts "-" * 80
      puts "Setup influx"
      Rake::Task["influx:setup"].invoke
      puts "-" * 80
    else
      puts "Can only be done in simulation mode or development mode"
    end
  end
end
