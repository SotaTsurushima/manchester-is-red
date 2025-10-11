<div align="center">

![My Skills](https://skillicons.dev/icons?i=docker,ruby,rails,vue,nuxtjs,tailwind,vite,redis,github,mysql&perline=5)

# ⚽ Manchester United Match Tracker

**A web app to track Manchester United matches, player info, and team news — built with Nuxt 3 × Rails 8 × Docker.**

</div>

---

## 🚀 Overview

**Manchester United Match Tracker** is a full-stack web application that lets fans easily follow:
- 🏟️ Upcoming & past match results  
- 👕 Player profiles & stats  
- 📰 Latest team news from **Sky Sports**  
- 🏆 Competition filtering (Premier League, Champions League, etc.)

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | Nuxt.js (Vue 3, TypeScript) / Tailwind CSS / Vite |
| **Backend** | Ruby on Rails 8.0.2 |
| **Database** | MySQL 8.0 |
| **Cache/Queue** | Redis |
| **Storage** | MinIO (S3 compatible) |
| **Containerization** | Docker 3.8 |
| **API Documentation** | Swagger UI / TypeSpec |


---

## 📘 API Documentation

### Swagger UI
- Location: `http://localhost:8000/api-docs`
- Tool: [swagger-ui](https://swagger.io/tools/swagger-ui/)
- Generated automatically from OpenAPI spec via Rails (`rswag` or `grape-swagger`)

### TypeSpec (API Spec)
- Directory: `/api-spec`
- Command to preview:  
  ```bash
  yarn api:preview

## ⚙️ Setup

### **1️⃣ Clone the repository**

```bash
git clone [repository-url]
cd manchester-is-red
```

### **2️⃣ Configure environment variables**
```bash
.env
frontend/.env
backend/.env
```

### **3️⃣ Build and run the containers**
```bash
# ----------------------------------------
# 🏗️ Build and run the containers
# ----------------------------------------

# Build containers
make b

# Run containers
make u

# ----------------------------------------
# 🧰 Prepare database
# ----------------------------------------
make back
rails db:migrate
rails db:seed
```

### **4️⃣ Access the app**
```bash
Frontend → http://localhost:3000
Backend API → http://localhost:8000
```


### **5️⃣ (Optional) Stop and remove containers**
```bash
make down
```
