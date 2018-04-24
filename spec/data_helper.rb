module DataHelper
  HEADERS = {
    "Accept" => "application/json",
    "CONTENT_TYPE" => "application/json",
    "HTTP_USER_AGENT" => "RSpec"
  }.freeze

  def data_helper_create_data_set
    create_religions
    create_castes
    # create_education_levels
    create_professions
    create_country_states
    create_districts
    create_constituencies
    create_issue_categories
    create_elections
    create_parties
    create_users
    create_candidates
    create_posts
    create_candidatures
    create_party_leaders
  end

  def create_religions
    religions = %w[Muslim Hindu Sikh Christian]
    religions.each do |religion|
      create(:religion, name: religion)
    end
  end

  def create_castes
    castes = %w[Jatt Khap Kamma Khsatriya Harijan]
    castes.each do |caste|
      Caste.find_or_create_by!(name: caste)
    end
  end

  def create_education_levels
    education_levels = ["Graduate", "Post Graduate", "12th Pass", "10th Pass"]
    education_levels.each do |education|
      create(:education, name: education)
    end
  end

  def create_professions
    professions = ["Private", "Public"]
    professions.each do |profession|
      create(:profession, name: profession)
    end
  end

  def create_country_states
    states = [
      {
        name: "Telangana",
        abbreviation: "TS"
      },
      {
        name: "Karnataka",
        abbreviation: "KA"
      },
      {
        name: "Rajasthan",
        abbreviation: "RJ"
      },
      {
        name: "Gujrat",
        abbreviation: "GJ"
      }
    ]

    states.each do |state|
      name = state[:name]
      abbreviation = state[:abbreviation]
      create(:country_state, name: name, abbreviation: abbreviation)
    end
  end

  def create_districts
    districts = [
      {
        "name": "Bengaluru",
        "state": "Karnataka"
      },
      {
        "name": "Ahmedabad",
        "state": "Gujrat"
      },
      {
        "name": "Jaipur",
        "state": "Rajasthan"
      }
    ]

    districts.each do |district|
      name = district[:name]
      state = district[:state]
      country_state = CountryState.find_by(name: state)
      create(:district, name: name, country_state: country_state)
    end
  end

  def create_constituencies
    constituencies = [
      {
        name: "Jaipur North Constituency",
        country_state: CountryState.find_by(abbreviation: 'RJ'),
        kind: "assembly",
        districts: ["Jaipur"]
      },
      {
        name: "Jaipur Constituency",
        country_state: CountryState.find_by(abbreviation: 'RJ'),
        kind: "parliamentary",
        children: ["Jaipur North Constituency"]
      },
      {
        name: "Bengaluru South Constituency",
        country_state: CountryState.find_by(abbreviation: 'KA'),
        kind: "assembly",
        districts: ["Bengaluru"]
      },
      {
        name: "Bengaluru Central Constituency",
        country_state: CountryState.find_by(abbreviation: 'KA'),
        kind: "assembly",
        districts: ["Bengaluru"]
      },
      {
        name: "Bengaluru Constituency",
        country_state: CountryState.find_by(abbreviation: 'KA'),
        kind: "parliamentary",
        children: ["Bengaluru South Constituency", "Bengaluru Central Constituency"],
        districts: ["Bengaluru"]
      },
      {
        name: "Ahmedabad South Constituency",
        country_state: CountryState.find_by(abbreviation: 'GJ'),
        kind: "assembly"
      },
      {
        name: "Ahmedabad Constituency",
        country_state: CountryState.find_by(abbreviation: 'GJ'),
        kind: "parliamentary",
        children: ["Ahmedabad South Constituency"]
      }
    ]

    constituencies.each do |constituency|
      name = constituency[:name]
      country_state = constituency[:country_state]
      kind = constituency[:kind]
      children = constituency[:children] || []
      districts = constituency[:districts] || []
      created_constituency = create(:constituency, name: name, country_state: country_state, kind: kind)
      districts.each do |district|
        created_constituency.districts << District.find_by(name: district)
      end
      children_constituencies = []
      children.each do |child|
        children_constituencies << Constituency.find_by(name: child)
      end
      created_constituency.children = children_constituencies
      created_constituency.save!
    end
  end

  def create_issue_categories
    categories = ["Environmental Issues", "Infrastructure", "Infrastructure", "Educational Issues", "Financial Issues", "National Issues"]
    categories.each do |category_name|
      create(:category, name: category_name, slug: category_name.parameterize)
    end
  end

  def create_elections
    elections = [
      {
        kind: "assembly",
        country_state: CountryState.find_by(abbreviation: 'KA'),
        starts_at: 15.days.from_now,
        ends_at: 21.days.from_now
      },
      {
        kind: "assembly",
        country_state: CountryState.find_by(abbreviation: 'RJ'),
        starts_at: 30.days.from_now,
        ends_at: 45.days.from_now
      },
      {
        kind: "assembly",
        country_state: CountryState.find_by(abbreviation: 'GJ'),
        starts_at: 10.days.ago,
        ends_at: 5.days.ago
      }
    ]

    elections.each do |election|
      country_state = election[:country_state]
      starts_at = election[:starts_at]
      ends_at = election[:ends_at]
      kind = election[:kind]
      create(:election, country_state: country_state, kind: kind, starts_at: starts_at, ends_at: ends_at)
    end
  end

  def create_parties
    parties = [
      {
        name: "Bharatiya Janata Party",
        abbreviation: "BJP"
      },
      {
        name: "Indian National Congress",
        abbreviation: "INC"
      },
      {
        name: "Telangana Rashtra Samithi",
        abbreviation: "TRS"
      },
      {
        name: "Shiromani Akali Dal",
        abbreviation: "SAD"
      }
    ]

    parties.each do |party|
      name = party[:name]
      abbreviation = party[:abbreviation]
      create(:party, name: name, abbreviation: abbreviation)
    end
  end

  def create_users
    religions = Religion.all.map(&:name)
    castes = Caste.all.map(&:name)
    professions = Profession.all.map(&:name)
    education_levels = Education.all.map(&:name)

    users = [
      {
        email: 'user1@neta.com',
        name: 'user1',
        phone: '1231231000',
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        religion: religions.sample,
        caste: castes.sample,
        profession: professions.sample,
        education: education_levels.sample,
        pincode: "560001"
      },
      {
        email: 'user2@neta.com',
        name: 'user2',
        phone: '1231231001',
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        religion: religions.sample,
        caste: castes.sample,
        profession: professions.sample,
        education: education_levels.sample,
        pincode: "560001"
      },
      {
        email: 'user3@neta.com',
        name: 'user3',
        phone: '1231231002',
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        religion: religions.sample,
        caste: castes.sample,
        profession: professions.sample,
        education: education_levels.sample,
        pincode: "560001"
      },
      {
        email: 'neta1@neta.com',
        name: 'neta1',
        phone: '1231231231',
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        religion: religions.sample,
        caste: castes.sample,
        profession: professions.sample,
        education: education_levels.sample,
        pincode: "560001",
        income: "Rs 120000",
        assets: "Rs 1200000",
        liabilities: "Rs 200000",
        criminal_cases: "none",
        website: "mpsinha@neta.com",
        twitter: "twitter.com/mpsinha",
        facebook: "facebook.com/mpsinha"
      },
      {
        email: 'neta2@neta.com',
        name: 'neta2',
        phone: '1231231230',
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        religion: religions.sample,
        caste: castes.sample,
        profession: professions.sample,
        education: education_levels.sample,
        pincode: "560001",
        income: "Rs 220000",
        assets: "Rs 200000",
        liabilities: "Rs 2000000",
        criminal_cases: "1. For attempting to kill Baba Ramdev",
        website: "mpring@neta.com",
        twitter: "twitter.com/mpring",
        facebook: "facebook.com/mpring"
      },
      {
        email: 'neta3@neta.com',
        name: 'neta3',
        phone: '1231231232',
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
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
    ]

    users.each do |user|
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
      firebase_user_id = SecureRandom.urlsafe_base64(nil, false)
      new_user = create(:user, name: name, email: email, firebase_user_id: firebase_user_id)
      new_user.phone_number = phone
      new_user.assembly_constituency = constituency if constituency
      profile = create(:profile, user: new_user)
      profile.religion = Religion.find_by(name: religion)
      profile.caste = Caste.find_by(name: caste)
      profile.profession = Profession.find_by(name: profession)
      profile.education = education
      profile.contact[:pincode] = user[:pincode]
      profile.financials[:income] = income if income
      profile.financials[:assets] = assets if assets
      profile.financials[:liabilities] = liabilities if liabilities
      profile.civil_record[:criminal_cases] = criminal_cases if criminal_cases
      profile.contact[:email] = email if email
      profile.contact[:website] = website if website
      profile.contact[:twitter] = twitter if twitter
      profile.contact[:facebook] = facebook if facebook
      profile.save!
      new_user.save!
    end
  end

  def create_candidates
    candidates = [
      {
        email: 'neta1@neta.com',
        name: 'neta1',
        phone: '1231231231'
      },
      {
        email: 'neta2@neta.com',
        name: 'neta2',
        phone: '1231231230'
      },
      {
        email: 'neta3@neta.com',
        name: 'neta3',
        phone: '1231231232'
      }
    ]

    candidates.each do |candidate|
      email = candidate[:email]
      name = candidate[:name]
      phone = candidate[:phone]
      user = User.find_or_create_by(email: email, name: name, phone_number: phone)
      profile = user.profile
      new_candidate = Candidate.new(phone_number: phone)
      new_candidate.profile = profile
      new_candidate.save!
    end
  end

  def create_posts
    constituencies = Constituency.all
    categories = Category.all
    users = User.limit(3)

    issues = [
      {
        title: Faker::Lorem.sentence,
        description: Faker::Lorem.paragraph
      },
      {
        title: Faker::Lorem.sentence,
        description: Faker::Lorem.paragraph
      },
      {
        title: Faker::Lorem.sentence,
        description: Faker::Lorem.paragraph,
        anonymous: true
      },
      {
        title: Faker::Lorem.sentence,
        description: Faker::Lorem.paragraph
      },
      {
        title: Faker::Lorem.sentence,
        description: Faker::Lorem.paragraph,
        anonymous: true
      }
    ]

    polls = [
      {
        question: Faker::Lorem.sentence,
        poll_options: Faker::Lorem.sentences
      },
      {
        question: Faker::Lorem.sentence,
        poll_options: Faker::Lorem.sentences
      },
      {
        question: Faker::Lorem.sentence,
        poll_options: Faker::Lorem.sentences
      },
      {
        question: Faker::Lorem.sentence,
        poll_options: Faker::Lorem.sentences
      }
    ]

    issues.each do |issue|
      title = issue[:title]
      description = issue[:description]
      anonymous = issue[:anonymous] || false
      create(:issue, region: constituencies.sample, category: categories.sample, title: title, description: description, user: users.sample, anonymous: anonymous)
    end

    polls.each do |poll|
      question = poll[:question]
      poll_options = poll[:poll_options]
      user_poll = create(:poll, region: constituencies.sample, category: categories.sample, question: question, user: users.sample)
      user_poll.poll_options.destroy
      poll_options.each do |option|
        user_poll.poll_options.build(answer: option, poll_votes_count: 0)
      end
      user_poll.save!
    end
  end

  def create_candidatures
    candidatures = [
      {
        email: 'neta1@neta.com',
        name: 'neta1',
        phone: '1231231231',
        party: Party.find_by(name: "Bharatiya Janata Party"),
        election: Election.find_by(country_state: CountryState.find_by(abbreviation: 'KA')),
        declared: true,
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        result: "won"
      },
      {
        email: 'neta2@neta.com',
        name: 'neta1',
        phone: '1231231230',
        party: Party.find_by(name: "Indian National Congress"),
        election: Election.find_by(country_state: CountryState.find_by(abbreviation: 'KA')),
        declared: true,
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        result: "lost"
      },
      {
        email: 'neta3@neta.com',
        name: 'neta1',
        phone: '1231231232',
        party: Party.find_by(name: "Bharatiya Janata Party"),
        election: Election.find_by(country_state: CountryState.find_by(abbreviation: 'KA')),
        declared: false,
        constituency: Constituency.find_by(name: "Bengaluru South Constituency"),
        result: "lost"
      }
    ]

    candidatures.each do |candidature|
      phone = candidature[:phone]
      party = candidature[:party]
      election = candidature[:election]
      declared = candidature[:declared]
      result = candidature[:result]
      constituency = candidature[:constituency]
      candidate = Candidate.find_by(phone_number: phone)
      Candidature.find_or_create_by(candidate: candidate, party: party, election: election, constituency: constituency, declared: declared, result: result)
    end
  end

  def create_party_leaders
    candidates = Candidate.all
    parties = Party.all

    parties.each do |party|
      party_leader_position = create(:party_leader_position)
      create(:party_leader, party: party, candidate: candidates.sample, party_leader_position: party_leader_position)
    end
  end

  def request_headers
    user = User.order('created_at asc').first
    HEADERS.merge(user.create_new_auth_token)
  end
end
