class AddInitialVotePercentToCandidature < ActiveRecord::Migration[5.1]
  def up
    add_column :candidatures, :initial_vote_percent, :real, null: false, default: 0
    total = 0
    Candidature.find_each do |cand|
      cand.update_attributes(initial_vote_percent: rand(5000..7000) / 1000000.to_f)
      total += 1
      puts "#{total} Completed"
    end
  end

  def down
    remove_column :candidatures, :initial_vote_percent
  end
end
