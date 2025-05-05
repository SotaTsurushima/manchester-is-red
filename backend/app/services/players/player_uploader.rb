# app/services/players/player_uploader.rb
module Players
  class PlayerUploader
    def self.upload(file)
      require 'aws-sdk-s3'

      access_key = ENV['MINIO_ACCESS_KEY']
      secret_key = ENV['MINIO_SECRET_KEY']
      bucket     = 'manchester-united-bucket'

      s3 = Aws::S3::Resource.new(
        access_key_id: access_key,
        secret_access_key: secret_key,
        endpoint: 'http://minio:9000',
        region: 'us-east-1',
        force_path_style: true
      )

      key = "players/#{file.original_filename}"
      obj = s3.bucket(bucket).object(key)
      obj.put(body: file.tempfile, content_type: file.content_type)

      base_url = 'http://localhost:9000'
      "#{base_url}/#{bucket}/#{key}"
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
  end
end