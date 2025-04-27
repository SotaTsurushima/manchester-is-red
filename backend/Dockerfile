# backendのDockerfile

# 必要な基本情報を指定
ARG RUBY_VERSION=3.2.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Railsアプリケーションの作業ディレクトリ
WORKDIR /rails

# 必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl default-mysql-client libjemalloc2 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 本番環境設定
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# ビルドステージ（アプリケーションのインストール）
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 必要なGemfileのインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# アプリケーションコードをコピー
COPY . .

# ビルド後、最終ステージでアプリケーションを準備
FROM base

# アプリケーションと依存関係をコピー
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# 非rootユーザーで実行
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# エントリーポイントの設定
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# デフォルトでサーバー起動
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
