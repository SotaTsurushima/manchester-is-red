# マルチステージビルド
FROM ruby:3.2.2 AS builder
WORKDIR /app

# 必要な最小限のパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-mysql-client \
    default-libmysqlclient-dev \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile* ./
RUN bundle install

FROM ruby:3.2.2
WORKDIR /app

# 必要な最小限のパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    default-mysql-client \
    default-libmysqlclient-dev \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . .

# ✅ 一度だけマイグレーションを実行（Render にこの状態でデプロイ）
CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0 -p 8000"]
# CMD ["bundle", "exec", "rails", "db:migrate"]

# CMD ["sh", "-c", "mkdir -p tmp/pids && rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0 -p 8000"]