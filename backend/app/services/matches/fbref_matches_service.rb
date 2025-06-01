require 'nokogiri'
require 'open-uri'

module Matches
  class FbrefMatchesService
    BASE_URLS = {
      'Premier League' => 'https://fbref.com/en/squads/19538871/matchlogs/2024-2025/schedule/Manchester-United-Scores-and-Fixtures-Premier-League',
      'Europa League' => 'https://fbref.com/en/squads/19538871/matchlogs/2024-2025/schedule/Manchester-United-Scores-and-Fixtures-Europa-League',
      'FA Cup' => 'https://fbref.com/en/squads/19538871/matchlogs/2024-2025/schedule/Manchester-United-Scores-and-Fixtures-FA-Cup',
      'EFL Cup' => 'https://fbref.com/en/squads/19538871/matchlogs/2024-2025/schedule/Manchester-United-Scores-and-Fixtures-EFL-Cup'
    }.freeze

    HEADERS = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }.freeze

    def fetch_and_save_matches
      BASE_URLS.each do |competition, url|
        doc = fetch_with_retry(url)
        doc.css('table#matchlogs_for tbody tr').each do |row|
          date = row.at_css('th[data-stat="date"]')&.text&.strip
          time = row.at_css('td[data-stat="start_time"]')&.text&.strip
          competition_name = row.at_css('td[data-stat="comp"] a')&.text&.strip
          round = row.at_css('td[data-stat="round"]')&.text&.strip
          day = row.at_css('td[data-stat="dayofweek"]')&.text&.strip
          venue = row.at_css('td[data-stat="venue"]')&.text&.strip
          result = row.at_css('td[data-stat="result"]')&.text&.strip
          goals_for = row.at_css('td[data-stat="goals_for"]')&.text&.strip
          goals_against = row.at_css('td[data-stat="goals_against"]')&.text&.strip
          opponent_name = row.at_css('td[data-stat="opponent"] a')&.text&.strip

          # 必要な値が取得できているか確認
          puts [date, time, competition_name, round, day, venue, result, goals_for, goals_against, opponent_name].join(' | ')

          next unless date && opponent_name

          # Home/Away判定
          if venue == 'Home'
            home_team_name = 'Manchester United'
            away_team_name = opponent_name
          else
            home_team_name = opponent_name
            away_team_name = 'Manchester United'
          end

          # 4. teamsテーブルにデータを保存（find_or_create_byで重複防止）
          home_team = Team.find_or_create_by!(name: home_team_name)
          away_team = Team.find_or_create_by!(name: away_team_name)

          date_obj = begin
            DateTime.parse("#{date} #{time}")
          rescue
            nil
          end

          next unless date_obj

          # 5. matchesテーブルの保存時にteam_idを使う
          match = Match.find_or_initialize_by(
            utc_date: date_obj,
            competition: competition_name
          )
          match.home_team_id = home_team.id
          match.away_team_id = away_team.id
          match.score = "#{goals_for} - #{goals_against}"
          match.venue = venue
          match.status = result
          match.save!
        end
      end
    end

    private

    def fetch_with_retry(url, max_retries = 3)
      retries = 0
      begin
        sleep(rand(5..10))
        response = URI.open(url, HEADERS)
        Nokogiri::HTML(response)
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
  end
end 