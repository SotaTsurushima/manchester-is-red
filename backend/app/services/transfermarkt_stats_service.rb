require 'nokogiri'
require 'open-uri'
require_relative 'name_normalizer'

class TransfermarktStatsService
  include ServiceHandler
  include NameNormalizer

  TRANSFERMARKT_URL = 'https://www.transfermarkt.com/manchester-united/startseite/verein/985'
  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language' => 'en-US,en;q=0.5',
    'Connection' => 'keep-alive'
  }.freeze

  # debug用
  def fetch_transfermarkt_market_value(player_url, max_retries = 2)
    doc = fetch_with_retry(player_url, max_retries)
    value_text = extract_market_value_text(doc)
    parse_market_value(value_text)
  end

  def fetch_market_values
    doc = fetch_with_retry(TRANSFERMARKT_URL, 2)
    players = {}
    doc.css('table.items tbody tr').each do |row|
      name = row.at_css('td.hauptlink a')&.text&.strip
      value_text = row.at_css('td.rechts.hauptlink')&.text
      value = parse_market_value(value_text)
      players[name] = value if name && value
    end
    # DB更新処理（normalize_nameによる部分一致）
    players.each do |name, market_value|
      normalized_name = normalize_name(name)
      player = Player.all.find do |p|
        db_name = normalize_name(p.name)
        db_name == normalized_name || db_name.include?(normalized_name) || normalized_name.include?(db_name)
      end
      next unless player
      if player.update(market_value: market_value)
        puts "Updated #{player.name}: #{market_value}"
      else
        puts "Failed to update #{player.name}: #{player.errors.full_messages.join(', ')}"
      end
    end
    players
  end

  private

  def fetch_with_retry(url, max_retries)
    retries = 0
    begin
      sleep(rand(10..20))
      Nokogiri::HTML(URI.open(url, HEADERS))
    rescue OpenURI::HTTPError => e
      if e.message.include?('429') && retries < max_retries
        retries += 1
        sleep(600 * (2 ** (retries - 1)))
        retry
      else
        raise "Failed to fetch data from #{url}: #{e.message}"
      end
    end
  end

  def extract_market_value_text(doc)
    doc.at_css('div[data-market-value]')&.text ||
      doc.at_css('.tm-player-market-value-development__current-value')&.text ||
      doc.at_css('.right-td .right-td')&.text ||
      doc.at_css('div[class*="marktwert"]')&.text ||
      doc.at_css('div[class*="dataMarktwert"] span')&.text ||
      doc.css('div').find { |div| div.text =~ /€[\d\.,]+[mk]?/i }&.text
  end

  def parse_market_value(value_str)
    return nil unless value_str
    if value_str.match?(/€[\d\.,]+m/i)
      value_str.gsub(/[€m,]/i, '').to_f
    elsif value_str.match?(/€[\d\.,]+k/i)
      value_str.gsub(/[€k,]/i, '').to_f / 1000
    else
      nil
    end
  end
end