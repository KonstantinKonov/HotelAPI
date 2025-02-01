## Hotel API

API application for hotel booking.


### Deployment

```bash
docker compose up --build
```

### Database schemas

<p align="center">
  <img src="https://github.com/KonstantinKonov/HotelAPI/blob/main/readme-img/db_schema.png"/>
</p>

### Architecture Patterns

### Authentication service
This application is provided with a simple authentication service using jwt-tokens. Registration, login and logout endpoints are defined in `src/api/auth.py` file. There are no roles defined, so any registered user is allowed to perform CRUD operations on any table.

### Database
#### PostgreSQL
The main part of the app is a PostgreSQL database which is working in asynchronious mode. Asynchronious driver `asyncpg` is used. A docker container with PostgreSQL database is deployed using `docker compose`. The part of the `docker-compose.yml` file which build and deploys the container:
```yml
db:
    image: postgres:14
    container_name: db
    env_file: .env
    volumes:
      - db_vol_data:/var/lib/postgresql/data
    networks:
      - mynetwork
    ports:
      - 5432:5432
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d booking -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 3
```
The part of the `.env` file, which provides neccessary settings for database deployment:
```.env
DB_HOST=<database name in the docker network>
DB_PORT=<port>
POSTGRES_USER=<database user>
POSTGRES_PASSWORD=<database password>
POSTGRES_DB=<database name>
```

#### Redis
Redis service is employed for caching some often requested data, like list of the hotels. The time of the caching is hardcoded in redis decorator.
```python
@cache(expire=10)
```
The redis container is build in docker-compose.yml file
```yml
redis:
  image: redis
  container_name: redis
  env_file: .env
  networks:
    - mynetwork
  ports:
    - 6379:6379
```
Redis host and password should be defined in `.env` file
```.env
REDIS_HOST=<redis name in the docker network>
REDIS_PORT=<port>
```

#### Migrations
Migrations are performed with alembic python library.


### Background Tasks
There are two services responsible for background task. Celery worker is used for ad hoc background tasks. Celery beat is setted for periodic background tasks.
Both services are build with `docker-compose`
```yml
celery_worker:
  build: 
    context: .
  container_name: celery_worker
  env_file: .env
  networks:
    - mynetwork
  command: celery -A src.tasks.celery_app:celery_instance worker -l INFO

celery_beat:
  build: 
    context: .
  container_name: celery_beat
  env_file: .env
  networks:
    - mynetwork
  command: celery -A src.tasks.celery_app:celery_instance beat -l INFO
```


### CI/CD
CI/CD pipeline is build using GitHub Actions service.

#### Build

#### Tests

#### Linter

#### Deployment

