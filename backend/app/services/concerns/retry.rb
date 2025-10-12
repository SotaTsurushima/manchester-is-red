module Retry
  extend ActiveSupport::Concern

  FBREF_HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language' => 'en-US,en;q=0.5',
    'Connection' => 'keep-alive'
  }.freeze

  private

  def fetch_with_retry(url, max_retries = 3, headers = FBREF_HEADERS)
    retries = 0
    begin
      sleep(rand(10..20))
      response = URI.open(url, headers)
      Nokogiri::HTML(response)
    rescue OpenURI::HTTPError => e
      if e.message.include?('429') && retries < max_retries
        retries += 1
        sleep(1800 * (2 ** (retries - 1)))
        retry
      else
        raise "データの取得に失敗しました #{url}: #{e.message}"
      end
    end
  end

  def with_retry(max_retries = 3, base_delay = 1)
    retries = 0
    begin
      yield
    rescue => e
      if retries < max_retries
        retries += 1
        delay = base_delay * (2 ** (retries - 1))
        sleep(delay)
        retry
      else
        raise e
      end
    end
  end
end