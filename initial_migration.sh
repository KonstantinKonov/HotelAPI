#!/bin/bash

source .env

apt update
apt install postgresql-client

while !pg_isready -U $POSTGRES_USER -h $DB_HOST -p $POSTGRES_PORT; do
	echo "Waiting for database to be ready..."
	sleep 2
done

echo "Database is ready!"


alembic upgrade head

exec "$@"