#!/bin/bash

echo "🔍 Test de Connectivité des Bases de Données"
echo "=============================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fonction pour tester une base
test_database() {
    local name=$1
    local container=$2
    local db=$3
    
    echo "📊 Test de $name..."
    
    # Test de connexion
    if docker exec $container pg_isready -U twitch_user -d $db > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Connexion OK${NC}"
    else
        echo -e "${RED}❌ Connexion FAILED${NC}"
        return 1
    fi
    
    # Lister les tables
    echo "   Tables disponibles:"
    docker exec $container psql -U twitch_user -d $db -c "\dt" 2>&1 | grep -E "public \|" | awk '{print "   - " $3}'
    
    # Compter les tables
    local table_count=$(docker exec $container psql -U twitch_user -d $db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>&1 | tr -d ' ')
    echo "   Total: $table_count tables"
    
    echo ""
}

# Tester toutes les bases
test_database "Users DB" "twitch-users-db" "users_db"
test_database "Streams DB" "twitch-streams-db" "streams_db"
test_database "Chat DB" "twitch-chat-db" "chat_db"
test_database "Subscriptions DB" "twitch-subscriptions-db" "subscriptions_db"
test_database "Analytics DB" "twitch-analytics-db" "analytics_db"

echo "=============================================="
echo "🧪 Test des Requêtes avec Jointures"
echo "=============================================="
echo ""

# Insérer des données de test
echo "📝 Insertion de données de test..."

# Users DB - Créer des utilisateurs
docker exec twitch-users-db psql -U twitch_user -d users_db -c "
INSERT INTO users (username, email, password_hash, bio) VALUES
('streamer1', 'streamer1@twitch.com', 'hash123', 'Pro gamer'),
('viewer1', 'viewer1@twitch.com', 'hash456', 'Gaming fan'),
('viewer2', 'viewer2@twitch.com', 'hash789', 'Esports enthusiast')
ON CONFLICT (email) DO NOTHING;
" 2>&1 | grep -E "INSERT|ERROR"

# Streams DB - Créer des catégories et streams
docker exec twitch-streams-db psql -U twitch_user -d streams_db -c "
INSERT INTO categories (name, slug, description) VALUES
('Just Chatting', 'just-chatting', 'Talk shows and conversations'),
('League of Legends', 'league-of-legends', 'MOBA game'),
('Valorant', 'valorant', 'FPS game')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO streams (user_id, category_id, title, is_live, viewer_count) VALUES
(1, 1, 'Morning Stream!', true, 150),
(1, 2, 'Ranked Grind', false, 0)
ON CONFLICT DO NOTHING;
" 2>&1 | grep -E "INSERT|ERROR"

# Chat DB - Créer des messages
docker exec twitch-chat-db psql -U twitch_user -d chat_db -c "
INSERT INTO chat_messages (stream_id, user_id, message) VALUES
(1, 2, 'Hello everyone!'),
(1, 3, 'Great stream!'),
(1, 2, 'PogChamp')
ON CONFLICT DO NOTHING;
" 2>&1 | grep -E "INSERT|ERROR"

# Subscriptions DB - Créer des abonnements
docker exec twitch-subscriptions-db psql -U twitch_user -d subscriptions_db -c "
INSERT INTO subscriptions (user_id, streamer_user_id, tier_id, is_active) VALUES
(2, 1, 1, true),
(3, 1, 2, true)
ON CONFLICT DO NOTHING;
" 2>&1 | grep -E "INSERT|ERROR"

echo -e "${GREEN}✅ Données de test insérées${NC}"
echo ""

# Test des requêtes
echo "🔍 Test 1: Requête simple - Lister les utilisateurs"
docker exec twitch-users-db psql -U twitch_user -d users_db -c "
SELECT id, username, email FROM users LIMIT 5;
"

echo ""
echo "🔍 Test 2: Requête avec jointure simulée - Streams avec catégories"
docker exec twitch-streams-db psql -U twitch_user -d streams_db -c "
SELECT 
    s.id,
    s.user_id,
    s.title,
    s.is_live,
    s.viewer_count,
    c.name as category_name
FROM streams s
LEFT JOIN categories c ON s.category_id = c.id
LIMIT 5;
"

echo ""
echo "🔍 Test 3: Requête avec agrégation - Messages par stream"
docker exec twitch-chat-db psql -U twitch_user -d chat_db -c "
SELECT 
    stream_id,
    COUNT(*) as message_count,
    COUNT(DISTINCT user_id) as unique_users
FROM chat_messages
GROUP BY stream_id;
"

echo ""
echo "🔍 Test 4: Requête avec jointure - Abonnements avec tiers"
docker exec twitch-subscriptions-db psql -U twitch_user -d subscriptions_db -c "
SELECT 
    s.id,
    s.user_id,
    s.streamer_user_id,
    st.tier_name,
    st.price_cents / 100.0 as price_dollars,
    s.is_active
FROM subscriptions s
JOIN subscription_tiers st ON s.tier_id = st.id
WHERE s.is_active = true;
"

echo ""
echo "🔍 Test 5: Vue - Statistiques utilisateurs"
docker exec twitch-users-db psql -U twitch_user -d users_db -c "
SELECT * FROM user_stats LIMIT 5;
"

echo ""
echo "=============================================="
echo "📊 Test des Exporters Prometheus"
echo "=============================================="
echo ""

# Tester les exporters
test_exporter() {
    local name=$1
    local port=$2
    
    echo "📈 Test $name (port $port)..."
    if curl -s http://localhost:$port/metrics | head -5 > /dev/null 2>&1; then
        local metric_count=$(curl -s http://localhost:$port/metrics | grep -v "^#" | wc -l)
        echo -e "${GREEN}✅ Exporter OK - $metric_count métriques disponibles${NC}"
    else
        echo -e "${RED}❌ Exporter FAILED${NC}"
    fi
}

test_exporter "Users DB Exporter" "9187"
test_exporter "Streams DB Exporter" "9188"
test_exporter "Chat DB Exporter" "9189"
test_exporter "Subscriptions DB Exporter" "9190"
test_exporter "Analytics DB Exporter" "9191"
test_exporter "Redis Exporter" "9121"

echo ""
echo "=============================================="
echo "🎯 Test Prometheus"
echo "=============================================="
echo ""

echo "📊 Vérification des targets Prometheus..."
curl -s http://localhost:9090/api/v1/targets | python3 -c "
import sys, json
data = json.load(sys.stdin)
targets = data.get('data', {}).get('activeTargets', [])
print(f'Total targets: {len(targets)}')
for t in targets:
    job = t.get('labels', {}).get('job', 'unknown')
    health = t.get('health', 'unknown')
    status = '✅' if health == 'up' else '❌'
    print(f'{status} {job}: {health}')
" 2>/dev/null || echo "⚠️  Impossible de parser les targets"

echo ""
echo "=============================================="
echo -e "${GREEN}✅ Tests terminés!${NC}"
echo "=============================================="
