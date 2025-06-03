require 'net/http'
require 'json'

module Teams
  class FootballOrgTeamsService
    API_KEY = ENV['FOOTBALL_API_KEY'] # .envやcredentialsで管理推奨
    BASE_URL = 'https://api.football-data.org/v4/competitions/PL/teams'

    def fetch_and_save_teams
      data = fetch_with_retry_api(BASE_URL)
      data['teams'].each do |team|
        name = team['name']
        crest_url = team['crest']
        minio_url = Teams::TeamUploader.upload_from_url(crest_url, name)

        t = Team.find_or_initialize_by(name: name)
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