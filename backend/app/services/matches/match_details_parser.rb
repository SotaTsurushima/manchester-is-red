module Matches
  class MatchDetailsParser
    def initialize(match, match_doc)
      @match = match
      @doc = match_doc
    end

    def save_details
      save_goals
      save_assists
    end

    private

    def save_goals
      # 得点者情報を取得（複数のセレクターパターンを試す）
      goal_selectors = [
        'div#div_goals_scored table tbody tr',
        'div#div_goals_for table tbody tr',
        'table#stats_standard_goals tbody tr'
      ]

      goal_selectors.each do |selector|
        @doc.css(selector).each do |row|
          player_name = row.at_css('td[data-stat="player"] a')&.text&.strip
          minute = row.at_css('td[data-stat="minute"]')&.text&.strip
          team = row.at_css('td[data-stat="team"]')&.text&.strip

          next unless player_name

          # 既存の得点者レコードを削除（重複防止）
          @match.match_details.where(scorer_name: player_name).destroy_all

          # 新しい得点者レコードを作成
          @match.match_details.create!(
            scorer_name: player_name,
            additional_data: {
              minute: minute,
              team: team,
              event_type: 'goal'
            }
          )

          puts "Saved goal: #{player_name} (#{minute}')"
        end
      end
    end

    def save_assists
      # アシスト者情報を取得（複数のセレクターパターンを試す）
      assist_selectors = [
        'div#div_goals_assisted table tbody tr',
        'div#div_assists table tbody tr',
        'table#stats_standard_assists tbody tr'
      ]

      assist_selectors.each do |selector|
        @doc.css(selector).each do |row|
          player_name = row.at_css('td[data-stat="player"] a')&.text&.strip
          minute = row.at_css('td[data-stat="minute"]')&.text&.strip
          team = row.at_css('td[data-stat="team"]')&.text&.strip

          next unless player_name

          # 既存のアシスト者レコードを削除（重複防止）
          @match.match_details.where(assist_name: player_name).destroy_all

          # 新しいアシスト者レコードを作成
          @match.match_details.create!(
            assist_name: player_name,
            additional_data: {
              minute: minute,
              team: team,
              event_type: 'assist'
            }
          )

          puts "Saved assist: #{player_name} (#{minute}')"
        end
      end
    end
  end
end 