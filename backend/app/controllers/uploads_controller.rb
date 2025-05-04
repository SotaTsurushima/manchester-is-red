class UploadsController < ApplicationController
  def create
    file = params[:file]
    name = params[:name]
    
    unless file
      render json: { error: 'No file uploaded' }, status: :bad_request and return
    end

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

    ext = File.extname(file.original_filename)
    key = "players/#{name}"

    obj = s3.bucket(bucket).object(key)
    obj.put(body: file.tempfile, content_type: file.content_type)

    base_url = 'http://localhost:9000'
    url = "#{base_url}/#{bucket}/#{key}"

    render json: { url: url }
  rescue => e
    Rails.logger.error e.full_message
    render json: { error: e.message }, status: :internal_server_error
  end
end
