FROM node:20-slim

WORKDIR /app

COPY package.json yarn.lock ./
# バージョンの整合性を保つ？
RUN yarn install --frozen-lockfile

COPY . .

CMD ["yarn", "dev"]