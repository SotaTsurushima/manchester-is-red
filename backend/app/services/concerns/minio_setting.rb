# app/services/concerns/s3_uploadable.rb
module MinioSetting
  extend ActiveSupport::Concern

  included do
    BUCKET = 'manchester-united-bucket'
    ENDPOINT = 'http://minio:9000'
    REGION = 'us-east-1'
  end

  class_methods do
    def s3_resource
      require 'aws-sdk-s3'
      Aws::S3::Resource.new(
        access_key_id: ENV['MINIO_ACCESS_KEY'],
        secret_access_key: ENV['MINIO_SECRET_KEY'],
        endpoint: ENDPOINT,
        region: REGION,
        force_path_style: true
      )
    end

    def extract_key_from_url(image_url)
      uri = URI.parse(image_url)
      path = uri.path
      path.split('/', 3)[2]
    end
  end
end