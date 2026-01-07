#!/bin/bash

echo "📊 État de la Plateforme Twitch"
echo "================================"
echo ""

# Vérifier si Docker est accessible
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker n'est pas accessible"
    exit 1
fi

echo "🐳 Services Docker Compose:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker compose ps

echo ""
echo "💾 Bases de données:"
echo ""

# Fonction pour tester une connexion PostgreSQL
test_db() {
    local name=$1
    local port=$2
    local db=$3
    
    if docker exec twitch-$name-db pg_isready -U twitch_user -d $db > /dev/null 2>&1; then
        echo "✅ $name-db (port $port) - OK"
    else
        echo "❌ $name-db (port $port) - ERREUR"
    fi
}

test_db "users" "5432" "users_db"
test_db "streams" "5433" "streams_db"
test_db "chat" "5434" "chat_db"
test_db "subscriptions" "5435" "subscriptions_db"
test_db "analytics" "5436" "analytics_db"

echo ""
if docker exec twitch-redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis (port 6379) - OK"
else
    echo "❌ Redis (port 6379) - ERREUR"
fi

echo ""
echo "📈 Services de monitoring:"
echo ""

# Tester Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo "✅ Prometheus (http://localhost:9090) - OK"
else
    echo "❌ Prometheus - ERREUR"
fi

# Tester Grafana
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ Grafana (http://localhost:3000) - OK"
else
    echo "❌ Grafana - ERREUR"
fi

# Tester AlertManager
if curl -s http://localhost:9093/-/healthy > /dev/null 2>&1; then
    echo "✅ AlertManager (http://localhost:9093) - OK"
else
    echo "❌ AlertManager - ERREUR"
fi

echo ""
echo "🌐 API Gateway:"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ API Gateway (http://localhost:8000) - OK"
else
    echo "❌ API Gateway - ERREUR"
fi

echo ""
echo "================================"
