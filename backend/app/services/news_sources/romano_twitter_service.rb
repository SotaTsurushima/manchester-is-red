module NewsSources
  class RomanoTwitterService
    CACHE_DURATION = 15.minutes
    MAX_TWEETS = 50
    MAX_RETRIES = 3

    def fetch_news
      Rails.cache.fetch('romano_tweets', expires_in: CACHE_DURATION) do
        with_rate_limit_handling do
          fetch_tweets
        end
      end
    rescue Twitter::Error::TooManyRequests => error
      handle_rate_limit(error)
    rescue Twitter::Error => error
      handle_twitter_error(error)
    end

    private

    def fetch_tweets
      client.search(
        "from:FabrizioRomano manchester united OR mufc",
        result_type: "recent",
        tweet_mode: "extended"
      ).take(MAX_TWEETS).map do |tweet|
        format_tweet(tweet)
      end
    end

    def with_rate_limit_handling
      retries = 0
      begin
        check_rate_limit
        yield
      rescue Twitter::Error::TooManyRequests => error
        retries += 1
        if retries <= MAX_RETRIES
          sleep_time = error.rate_limit.reset_in + 1
          Rails.logger.warn "Rate limit reached. Sleeping for #{sleep_time} seconds"
          sleep sleep_time
          retry
        else
          raise
        end
      end
    end

    def check_rate_limit
      limit = client.rate_limit_status
      remaining = limit.remaining
      reset_time = limit.reset_in

      if remaining.zero?
        Rails.logger.warn "No API calls remaining. Reset in #{reset_time} seconds"
        sleep reset_time + 1
      elsif remaining < 5
        Rails.logger.warn "Only #{remaining} API calls remaining"
      end
    end

    def handle_rate_limit(error)
      Rails.logger.error "Rate limit exceeded. Reset in #{error.rate_limit.reset_in} seconds"
      cached_result = Rails.cache.read('romano_tweets')
      return cached_result if cached_result.present?
      
      # キャッシュがない場合は空配列を返す
      []
    end

    def handle_twitter_error(error)
      Rails.logger.error "Twitter API error: #{error.message}"
      cached_result = Rails.cache.read('romano_tweets')
      return cached_result if cached_result.present?
      
      []
    end

    def format_tweet(tweet)
      {
        title: tweet.full_text,
        url: "https://twitter.com/FabrizioRomano/status/#{tweet.id}",
        image: extract_image(tweet),
        date: tweet.created_at,
        description: tweet.full_text,
        source: 'Fabrizio Romano',
        reliability: get_reliability(tweet.full_text),
        status: get_transfer_status(tweet.full_text)
      }
    end

    def extract_image(tweet)
      return nil unless tweet.media?
      tweet.media.first.media_url_https.to_s
    end

    def get_reliability(text)
      text.downcase.include?('here we go') ? 'Tier 1' : 'Tier 2'
    end

    def get_transfer_status(text)
      text = text.downcase
      if text.include?('here we go')
        'Confirmed'
      elsif text.include?('advanced') || text.include?('close')
        'Advanced Talks'
      else
        'Rumour'
      end
    end

    def client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_API_KEY']
        config.consumer_secret = ENV['TWITTER_API_KEY_SECRET']
        config.access_token = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end
    end
  end
end 