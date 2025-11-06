# Chatwoot Environment Setup Guide for New Clients

This document explains how to create and deploy a new Chatwoot environment for a new client using the existing Docker-based infrastructure.

## Overview

Chatwoot is deployed using a custom Docker image built from the feat/zendly branch, which contains minor modifications for logo and branding.

Once the base image is built, it is used to create dedicated Chatwoot environments for each client (e.g., Ontop, Littio) while reusing the same PostgreSQL and Redis services.

## Deployment Architecture

Each client environment runs as an independent Docker service based on the same base Chatwoot image, but with separate database configurations.

Shared resources:

PostgreSQL → one instance, multiple databases (one per client)

Redis → one instance, multiple logical databases (different db_number per client)

Client-specific resources:
- Chatwoot Rails service
- Chatwoot Sidekiq service
- Environment variables and branding settings

## Prerequisites

- Docker and Docker Compose installed
- Access to the chatwoot repository (branch feat/zendly)
- Access to the existing docker-setup folder structure containing other client deployments
- Base image built and available locally or in your Docker registry

## 🚀 Step-by-Step Setup
1. Clone the existing client folder

Inside the docker-setup directory, duplicate an existing client’s folder (e.g., ontop) and rename it with the new client’s name.

```
cd docker-setup
cp -r ontop littio
```

2. Update docker-compose.yaml and docker-compose.override.yaml

Modify the service names so that both the Rails and Sidekiq containers use the new client identifier.

Example changes:
```
# Before
services:
  ontop-rails:
  ontop-sidekiq:

# After
services:
  littio-rails:
  littio-sidekiq:
```
3. Update environment variables (.env)

Adjust the following variables in the .env file for the new client:

Variable	Description	Example
FRONTEND_URL	URL for the frontend interface	
REDIS_URL	Redis connection with a unique DB number	redis://redis:6379/3
POSTGRES_DATABASE	New database name for the client	chatwoot_littio
BRAND_URL	Client branding URL

⚠️ Make sure to increment the db_number in REDIS_URL so each client has its own logical Redis database.

4. Build and start the containers

Run the following commands inside the new client’s folder:

```
docker compose -f docker-compose.yaml up --build -d
```


This builds and starts the new Chatwoot environment in detached mode.

5. Run the setup script

After the containers are up, execute the Chatwoot setup script:

```
sh setup_chatwoot.sh
```

This script initializes the database, runs migrations, and configures the environment for the new client.


## Create Additional Users or Accounts (Platform API)

Once the Chatwoot environment is running, you can create new accounts or users through the Chatwoot Platform API.

1. Connect to the Rails shell and create a platform app

Access the Rails console inside the running container:

```
docker exec -it littio-rails bash
RAILS_ENV=production bundle exec rails c
```

Then create a platform app:
```
app = PlatformApp.create(name: 'littio')
app.access_token.token
```

Copy the generated token — it will be used to authenticate API requests.

2. Use the Platform API to create or update accounts

Once you have the token, you can consume the Platform API to create or manage accounts and users.

Documentation:
- 📘 Building on Top of Chatwoot: Platform APIs
- 🔗 Postman Workspace: Chatwoot APIs
