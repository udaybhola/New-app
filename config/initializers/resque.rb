Resque.redis = if Rails.env.production?
                 Redis.new(url: ENV['REDIS_URL'], thread_safe: true)
               else
                 Redis.new(url: 'redis://localhost:6379', thread_safe: true)
            end
