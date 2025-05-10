Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発環境の設定
    if Rails.env.development?
      origins 'http://localhost:3000', 'http://localhost:8000'
    end

    # 本番環境の設定
    if Rails.env.production?
      origins 'https://manchester-is-red-frontend.onrender.com', 'http://manchester-is-red-frontend.onrender.com'
    end

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: ['Authorization']
  end
end
