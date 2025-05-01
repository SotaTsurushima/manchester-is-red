FROM ruby:3.2.8-slim

# 必要な最小限のパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-mysql-client \
    default-libmysqlclient-dev \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails

# 環境設定
ENV RAILS_ENV="development"

# Gemfileをコピーして依存関係をインストール
COPY Gemfile* ./
RUN bundle install

# アプリケーションコードをコピー
COPY . .

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
