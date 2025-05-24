![My Skills](https://skillicons.dev/icons?i=docker,ruby,rails,vue,nuxtjs,tailwind,vite,redis,github,mysql&perline=5)



# Manchester United Match Tracker

A web application to track Manchester United matches, player information, and team news using the Football Data API.

## Features

- Match schedule and results
- Player information
- Team news from Sky Sports
- Competition filtering (Premier League, Champions League)

## Tech Stack

- **Frontend**: Vue.js/Nuxt.js 3.5.13/3.16.2
- **Backend**: Ruby on Rails 8.0.2
- **Database**: MySQL 8.0
- **Storage**: Minio 
- **Container**: Docker 3.8

## Prerequisites

- Docker
- Docker Compose
- Football Data API Key

## Setup

1. Clone the repository

```bash
git clone [repository-url]
cd manchester-is-red
```

2. Create environment files

```bash
# Root directory
cp .env.example .env

# Frontend
cp frontend/.env.example frontend/.env

# Backend
cp backend/.env.example backend/.env
```

3. Add your Football Data API key to `backend/.env`

## Notes

- MinIO/S3 integration and image deletion permissions are described in the README or code comments.
- For detailed API specs or customization, see the `/docs` directory or code comments.

---

**Questions and contributions are welcome!**
