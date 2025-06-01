module Players
  class PlayerUploader
    include MinioSetting

    def self.upload(file)
      filename = file.original_filename.gsub(/\s+/, '_')
      key = "players/#{filename}"
      obj = s3_resource.bucket(BUCKET).object(key)
      obj.put(body: file.tempfile, content_type: file.content_type)
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
