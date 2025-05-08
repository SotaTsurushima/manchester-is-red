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

# 環境設定
ENV RAILS_ENV="production"

# 起動スクリプトのコピーと実行権限の付与
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]
