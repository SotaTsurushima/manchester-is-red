require 'selenium-webdriver'

class FetchStatsWorker
  include Sidekiq::Worker

  def perform
    driver = setup_driver

    begin
      player_url = "https://www.transfermarkt.com/bruno-fernandes/profil/spieler/240306"
      driver.navigate.to player_url
      sleep 2

      handle_cookie_banner(driver)
      activate_premier_league_tab(driver)
      goals, assists = fetch_goals_and_assists(driver)

      puts "🎯 Bruno Fernandes: Goals: #{goals || '不明'}, Assists: #{assists || '不明'}"

    rescue => e
      puts "❌ エラー: #{e.message}"
    ensure
      puts "🛑 ドライバーを終了します"
      driver.quit
    end
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

  def handle_cookie_banner(driver)
    begin
      driver.find_element(css: 'button[mode="primary"]').click
      sleep 2
    rescue Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  def activate_premier_league_tab(driver)
    puts "🔍 Premier Leagueタブを探しています..."
    pl_divs = driver.find_elements(css: 'div.tm-player-performance__thumb')
    pl_div = pl_divs.find do |div|
      begin
        img = div.find_element(css: 'img')
        img.attribute('title') == "Premier League"
      rescue
        false
      end
    end

    if pl_div
      is_active = pl_div.attribute('class').include?('tm-player-performance__thumb--active')
      puts "Premier Leagueタブは#{is_active ? 'すでにアクティブ' : '非アクティブ'}です"
      unless is_active
        driver.execute_script("arguments[0].scrollIntoView(true);", pl_div)
        sleep 1
        pl_div.click
        sleep 2
        puts "Premier Leagueタブをクリックしました"
      end
    end
  end

  def fetch_goals_and_assists(driver)
    puts "📊 統計データ（Goals / Assists）の取得を試みます..."

    stats_items = driver.find_elements(css: 'li[data-testid="performance-slide-stat-item"]')

    # li内のaタグの値（innerHTML）をすべて配列で取得
    values = stats_items.map do |item|
      begin
        a_tag = item.find_element(css: 'a.tm-player-performance__stats-list-item-value') rescue nil
        a_tag ? a_tag.attribute('innerHTML').strip : nil
      rescue Selenium::WebDriver::Error::NoSuchElementError
        nil
      end
    end.compact
    puts values

    # 2個目（index 1）がゴール、3個目（index 2）がアシスト
    goals = values[1]
    assists = values[2]

    [goals, assists]
  end

  def fetch_first_stat_value(driver)
    stats_items = driver.find_elements(css: 'li[data-testid="performance-slide-stat-item"]')
    stats_items.each do |item|
      begin
        # li内の最初のaタグの値を取得
        value = item.find_element(css: 'a.tm-player-performance__stats-list-item-value').text.strip
        puts "value: #{value}"
        # 必要なら break で1つだけ取得して終了
        break
      rescue Selenium::WebDriver::Error::NoSuchElementError
        # スキップ
      end
    end
  end
end
