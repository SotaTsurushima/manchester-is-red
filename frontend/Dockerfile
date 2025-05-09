FROM node:20-slim

WORKDIR /app

COPY package.json yarn.lock ./
# バージョンの整合性を保つ？
RUN yarn install --frozen-lockfile

COPY . .

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000
CMD ["yarn", "start"]