# app/services/player_uploader.rb
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
end