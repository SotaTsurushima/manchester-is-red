FROM node:20-slim

WORKDIR /app

COPY package.json yarn.lock ./
# バージョンの整合性を保つ？
RUN yarn install --frozen-lockfile

COPY . .

# 本番環境用の設定
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# 本番環境用の起動コマンド
CMD ["yarn", "start"]