require 'selenium-webdriver'

class FetchStatsWorker
  include Sidekiq::Worker

  def perform
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

    driver = Selenium::WebDriver.for(
      :remote,
      url: ENV.fetch('SELENIUM_DRIVER_URL', 'http://selenium:4444/wd/hub'),
      capabilities: options
    )

    begin
      url = "https://www.transfermarkt.com/bruno-fernandes/profil/spieler/240306"
      driver.get(url)

      sleep 5

      # クッキー・トラッキング同意ポップアップを閉じる
      begin
        accept_btn = driver.find_element(css: 'button[mode="primary"]')
        accept_btn.click
        sleep 2 # ポップアップが消えるのを待つ
        puts "✅ Accept & continueボタンをクリックしました"
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts "ℹ️ Accept & continueボタンは見つかりませんでした"
      end

      stats = driver.find_elements(css: 'a.tm-player-performance__stats-list-item-value[data-testid="performance-item-link"]')
      puts stats
      if stats.empty?
        puts "⚠️ statsが取得できませんでした。セレクタの確認が必要です。"
      else
        stats.each_with_index do |stat, i|
          value = stat.attribute('innerHTML').strip
          puts "stat[#{i}]: #{value}"
        end

        # ゴール数、アシスト数を取得
        goals = stats[1]&.attribute('innerHTML')&.strip
        assists = stats[2]&.attribute('innerHTML')&.strip

        puts "✅Goals: #{goals}, Assists: #{assists}"
      end
    rescue => e
      puts "❌ エラーが発生しました: #{e.message}"
    ensure
      driver.quit
    end
  end
end
