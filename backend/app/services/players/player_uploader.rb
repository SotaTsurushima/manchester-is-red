# app/services/players/player_uploader.rb
module Players
  class PlayerUploader
    BUCKET = 'manchester-united-bucket'
    ENDPOINT = 'http://minio:9000'
    REGION = 'us-east-1'

    def self.s3_resource
      require 'aws-sdk-s3'
      Aws::S3::Resource.new(
        access_key_id: ENV['MINIO_ACCESS_KEY'],
        secret_access_key: ENV['MINIO_SECRET_KEY'],
        endpoint: ENDPOINT,
        region: REGION,
        force_path_style: true
      )
    end

    def self.upload(file)
      key = "players/#{file.original_filename}"
      obj = s3_resource.bucket(BUCKET).object(key)
      obj.put(body: file.tempfile, content_type: file.content_type)
      base_url = ENDPOINT.sub('minio', 'localhost') # 必要に応じて調整
      "#{base_url}/#{BUCKET}/#{key}"
    end

    def handle_error(e)
      Rails.logger.error e.full_message # ログにも詳細を出す
      render json: {
        success: false,
        error: e.message,
        class: e.class.to_s,
        full_message: e.full_message(highlight: false, order: :top)
      }, status: :internal_server_error
    end

    def self.delete(image_url)
      key = extract_key_from_url(image_url)
      obj = s3_resource.bucket(BUCKET).object(key)
      obj.delete
    end

    def self.extract_key_from_url(image_url)
      uri = URI.parse(image_url)
      path = uri.path # => "/manchester-united-bucket/players/xxxx.jpg"
      path.split('/', 3)[2] # => "players/xxxx.jpg"
    end
  end
end