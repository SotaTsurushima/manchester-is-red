require 'net/http'
require 'json'

module Teams
  class FootballOrgTeamsService
    API_KEY = ENV['FOOTBALL_API_KEY'] # .envやcredentialsで管理推奨
    BASE_URL = 'https://api.football-data.org/v4/competitions/PL/teams'

    TEAM_NAME_MAP = {
      "Wolverhampton Wanderers FC" => "Wolves",
      "Newcastle United FC" => "Newcastle Utd",
      "Nottingham Forest FC" => "Nott'ham Forest",
      # 他にも必要に応じて追加
    }

    def update_crest_urls
      data = fetch_with_retry_api(BASE_URL)
      data['teams'].each do |team|
        api_name = team['name']
        db_name = TEAM_NAME_MAP[api_name] || api_name.gsub(/ (FC|AFC)$/, '')
        search_name = db_name.gsub(/ (FC|AFC)$/, '')

        puts search_name
        crest_url = team['crest']

        t = Team.where('name LIKE ?', "%#{db_name}%").first
        unless t
          Team.all.each do |team_record|
            if db_name.include?(team_record.name)
              t = team_record
              break
            end
          end
        end
        next unless t # 既存レコードのみ処理

        minio_url = Teams::TeamUploader.upload_from_url(crest_url, search_name)
        t.crest_url = minio_url
        t.save!
      end
    end

    def fetch_with_retry_api(url, max_retries = 3)
      retries = 0
      begin
        sleep(rand(1..3)) # 軽いランダムスリープ
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri)
        request['X-Auth-Token'] = API_KEY
        response = http.request(request)
        if response.code == '429'
          raise '429 Too Many Requests'
        end
        JSON.parse(response.body)
      rescue => e
        if e.message.include?('429') && retries < max_retries
          retries += 1
          sleep(60 * (2 ** (retries - 1))) # 1分, 2分, 4分...
          retry
        else
          raise "Failed to fetch data from #{url}: #{e.message}"
        end
      end
    end
  end
end