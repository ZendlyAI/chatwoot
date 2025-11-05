#!/bin/bash

echo "Inserte el nombre del cliente:"
read customer_name
# Preparar la base de datos de Chatwoot
echo "Preparando la base de datos en Chatwoot..."
docker compose exec -T "$customer_name"-rails /bin/sh -c "bundle exec rails db:chatwoot_prepare"

# Ejecutar las migraciones
echo "Ejecutando migraciones en Chatwoot..."
docker compose exec -T "$customer_name"-rails /bin/sh -c "bundle exec rails db:migrate"

# Esperar a que las migraciones se completen con un límite de tiempo
echo "Esperando a que las migraciones se completen..."
timeout=300  # Tiempo límite en segundos (5 minutos)
interval=5  # Intervalo de comprobación en segundos

elapsed=0
while docker compose exec -T "$customer_name"-rails /bin/sh -c "bundle exec rails db:migrate:status" | grep 'down' > /dev/null; do
    if [ $elapsed -ge $timeout ]; then
        echo "Error: Tiempo límite alcanzado. Las migraciones no se completaron en $timeout segundos."
        exit 1
    fi
    sleep $interval
    elapsed=$((elapsed + interval))
    echo "Migraciones aún en curso... Tiempo transcurrido: $elapsed segundos."
done

# Verificar que no hay migraciones pendientes
echo "Verificando migraciones pendientes..."
if docker compose exec -T "$customer_name"-rails /bin/sh -c "bundle exec rails db:migrate:status" | grep 'down' > /dev/null; then
    echo "Error: Aún hay migraciones pendientes después de ejecutar migrate."
    exit 1
else
    echo "Migraciones completadas con éxito."
fi
