<img src="https://img.shields.io/badge/-Vue.js-4FC08D.svg?logo=vue.js&style=plastic"><img src="https://img.shields.io/badge/-Nuxt.js-00C58E.svg?logo=nuxt.js&style=plastic"><img src="https://img.shields.io/badge/-Ruby-CC342D.svg?logo=ruby&style=plastic"><img src="https://img.shields.io/badge/-Rails-CC0000.svg?logo=rails&style=plastic"><img src="https://img.shields.io/badge/-Docker-1488C6.svg?logo=docker&style=plastic"><img src="https://img.shields.io/badge/-Mysql-4479A1.svg?logo=mysql&style=plastic"><img src="https://img.shields.io/badge/-Redis-D82C20.svg?logo=redis&style=plastic">

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
