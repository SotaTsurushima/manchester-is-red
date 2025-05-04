require 'dotenv'
Dotenv.load('../.env')
require 'aws-sdk-s3'

# MinIOの設定（Docker Composeの場合はサービス名でアクセス）
s3 = Aws::S3::Resource.new(
  endpoint: 'http://minio:9000', # ←ここを修正
  access_key_id: ENV['MINIO_ACCESS_KEY'],
  secret_access_key: ENV['MINIO_SECRET_KEY'],
  force_path_style: true,
  region: 'us-east-1'
)

bucket = s3.bucket('manchester-united-bucket')

# file_path = '../images/old_trafford.jpg'
filename = File.basename(file_path)
object_key = "players/#{filename}"

# アップロード
obj = bucket.object(object_key)
obj.upload_file(file_path)

# 公開URLを取得
image_url = obj.public_url
