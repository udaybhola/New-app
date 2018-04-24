class Leaderboards
  @@instances = {}

  def self.candidatures
    unless @@instances.key?(:candidatures)
      @@instances[:candidatures] = Leaderboard::Candidature.new(redis_instance)
    end
    @@instances[:candidatures]
  end

  def self.parties
    unless @@instances.key?(:parties)
      @@instances[:parties] = Leaderboard::Party.new(redis_instance)
    end
    @@instances[:parties]
  end

  def self.influencers
    unless @@instances.key?(:influencers)
      @@instances[:influencers] = Leaderboard::Influencer.new(redis_instance)
    end
    @@instances[:influencers]
  end

  def self.redis_instance
    if Rails.env.production?
      Redis.new(url: ENV['REDIS_URL'], thread_safe: true)
    else
      Redis.new(url: 'redis://localhost:6379', thread_safe: true)
    end
  end
end
