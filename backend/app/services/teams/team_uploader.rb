require 'open-uri'

module Teams
  class TeamUploader
    include MinioSetting

    def self.upload_from_url(url, team_name)
      response = URI.open(url)
      # ファイル名を安全に
      safe_name = team_name.downcase.gsub(/\s+/, '_').gsub(/[^a-z0-9_]/, '')
      filename = "#{safe_name}_crest.png"
      key = "teams/#{filename}"

      obj = s3_resource.bucket(BUCKET).object(key)
      obj.put(body: response.read, content_type: 'image/png')
      base_url = ENDPOINT.sub('minio', 'localhost')
      "#{base_url}/#{BUCKET}/#{key}"
    end

    def self.delete(image_url)
      key = extract_key_from_url(image_url)
      obj = s3_resource.bucket(BUCKET).object(key)
      obj.delete
    end
  end
end
