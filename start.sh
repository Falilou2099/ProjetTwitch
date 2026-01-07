#!/bin/bash

set -e

echo "🚀 Démarrage de la Plateforme Twitch - Architecture Microservices"
echo "=================================================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher avec couleur
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

# Arrêter les services existants
print_info "Arrêt des services existants..."
docker compose down 2>/dev/null || true
echo ""

# Étape 1: Bases de données
print_info "📦 Étape 1/4: Démarrage des bases de données..."
docker compose up -d users-db streams-db chat-db subscriptions-db analytics-db redis

print_warning "Attente de l'initialisation des bases (30 secondes)..."
for i in {30..1}; do
    echo -ne "\r   Temps restant: ${i}s "
    sleep 1
done
echo ""

# Vérifier l'état des bases
print_info "Vérification de l'état des bases..."
docker compose ps users-db streams-db chat-db subscriptions-db analytics-db redis
echo ""

# Étape 2: Exporters
print_info "📊 Étape 2/4: Démarrage des exporters Prometheus..."
docker compose up -d \
    postgres-exporter-users \
    postgres-exporter-streams \
    postgres-exporter-chat \
    postgres-exporter-subscriptions \
    postgres-exporter-analytics \
    redis-exporter

sleep 5
print_success "Exporters démarrés"
echo ""

# Étape 3: Stack d'observabilité
print_info "📈 Étape 3/4: Démarrage de la stack d'observabilité..."
docker compose up -d node-exporter cadvisor
sleep 2
docker compose up -d prometheus alertmanager
sleep 5
docker compose up -d grafana
print_success "Stack d'observabilité démarrée"
echo ""

# Étape 4: API Gateway
print_info "🌐 Étape 4/4: Démarrage de l'API Gateway..."
docker compose up -d api-gateway
print_success "API Gateway démarré"
echo ""

# Afficher l'état final
echo "=================================================================="
print_success "Démarrage terminé!"
echo ""
echo "📋 État des services:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "🌐 Accès aux interfaces:"
echo "   • Grafana:       http://localhost:3000 (admin/admin)"
echo "   • Prometheus:    http://localhost:9090"
echo "   • AlertManager:  http://localhost:9093"
echo "   • cAdvisor:      http://localhost:8080"
echo "   • API Gateway:   http://localhost:8000"
echo ""

echo "📊 Bases de données PostgreSQL:"
echo "   • Users DB:          localhost:5432 (users_db)"
echo "   • Streams DB:        localhost:5433 (streams_db)"
echo "   • Chat DB:           localhost:5434 (chat_db)"
echo "   • Subscriptions DB:  localhost:5435 (subscriptions_db)"
echo "   • Analytics DB:      localhost:5436 (analytics_db)"
echo ""

echo "🔧 Commandes utiles:"
echo "   • Voir les logs:     docker compose logs -f [service]"
echo "   • Arrêter:           docker compose down"
echo "   • Redémarrer:        docker compose restart [service]"
echo "   • État:              docker compose ps"
echo ""

print_success "Plateforme prête! 🎉"
