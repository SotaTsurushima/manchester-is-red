require 'selenium-webdriver'

class FetchTransfermarktStatsService
  def initialize(driver: nil, logger: Rails.logger)
    @driver = driver || setup_driver
    @should_quit_driver = driver.nil?
    @logger = logger
  end

  def call
    fetch_player_links.each do |player_info|
      begin
        db_player = find_db_player_by_url(player_info[:url])
        next unless db_player
        update_player_stats(player_info, db_player)
      rescue => e
        @logger.warn "Error for #{player_info[:name]}: #{e.class} #{e.message}"
      end
    end
  ensure
    @driver.quit if @should_quit_driver
  end

  private

  def setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('user-agent=Mozilla/5.0')
    Selenium::WebDriver.for(
      :remote,
      url: ENV.fetch('SELENIUM_DRIVER_URL', 'http://selenium:4444/wd/hub'),
      capabilities: options
    )
  end

  def fetch_player_links
    @driver.navigate.to "https://www.transfermarkt.com/manchester-united/startseite/verein/985"
    sleep 2
    handle_cookie_banner
    @driver.find_elements(css: 'table.items > tbody > tr').map do |row|
      begin
        link = row.find_element(css: 'td:nth-child(2) a')
        url = link.attribute('href')
        next unless url && !url.empty?
        { name: link.text.strip, url: url.start_with?('http') ? url : "https://www.transfermarkt.com#{url}" }
      rescue
        nil
      end
    end.compact
  end

  def slug_to_name(slug)
    slug.split('-').map(&:capitalize).join(' ')
  end

  def extract_slug_from_url(url)
    url.split('/')[3]
  end

  def find_db_player_by_url(url)
    slug = extract_slug_from_url(url)
    Player.where('LOWER(name) = ?', slug_to_name(slug).downcase).first
  end

  def update_player_stats(player_info, db_player)
    @driver.navigate.to player_info[:url]
    sleep 2
    handle_cookie_banner
    activate_premier_league_tab rescue nil
    goals, assists = fetch_goals_and_assists
    db_player.update(
      goals: goals.to_s.strip.empty? ? 0 : goals.to_i,
      assists: assists.to_s.strip.empty? ? 0 : assists.to_i
    )
    @logger.info "Updated: #{db_player.name}"
  end

  def handle_cookie_banner
    @driver.find_element(css: 'button[mode="primary"]').click
    sleep 2
  rescue Selenium::WebDriver::Error::NoSuchElementError
  end

  def activate_premier_league_tab
    pl_div = @driver.find_elements(css: 'div.tm-player-performance__thumb').find do |div|
      img = div.find_element(css: 'img') rescue nil
      img&.attribute('title') == "Premier League"
    end
    return unless pl_div
    unless pl_div.attribute('class').include?('tm-player-performance__thumb--active')
      @driver.execute_script("arguments[0].scrollIntoView(true);", pl_div)
      sleep 1
      pl_div.click
      sleep 2
    end
  end

  def fetch_goals_and_assists
    stats = @driver.find_elements(css: 'li[data-testid="performance-slide-stat-item"]').map do |item|
      a_tag = item.find_element(css: 'a.tm-player-performance__stats-list-item-value') rescue nil
      a_tag&.attribute('innerHTML')&.strip
    end.compact
    [stats[1], stats[2]]
  end
end 