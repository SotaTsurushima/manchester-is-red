module Teams
  class TeamUploader
    include MinioSetting

    def self.upload_from_url(url, team_name)
      response = URI.open(url)
      filename = "#{team_name.downcase.gsub(/\s+/, '_')}_crest.png"
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
