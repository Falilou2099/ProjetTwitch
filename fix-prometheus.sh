#!/bin/bash

echo "🔧 Correction de la Configuration Prometheus et Tests"
echo "====================================================="
echo ""

# Redémarrer Prometheus pour recharger la config
echo "🔄 Redémarrage de Prometheus..."
docker compose restart prometheus
sleep 5

# Tester les exporters directement
echo ""
echo "📊 Test des Exporters PostgreSQL..."
echo ""

for port in 9187 9188 9189 9190 9191; do
    echo "Test port $port..."
    curl -s http://localhost:$port/metrics 2>&1 | head -3
    echo ""
done

# Tester Redis exporter
echo "Test Redis Exporter (9121)..."
curl -s http://localhost:9121/metrics 2>&1 | head -3
echo ""

# Vérifier les targets Prometheus
echo ""
echo "🎯 Vérification des Targets Prometheus..."
curl -s http://localhost:9090/api/v1/targets 2>&1 | python3 -m json.tool 2>/dev/null | head -100

# Tester les bases de données avec des requêtes
echo ""
echo "💾 Test des Bases de Données..."
echo ""

# Test Users DB
echo "1️⃣ Users DB:"
docker exec twitch-users-db psql -U twitch_user -d users_db -c "
SELECT 'Users DB OK' as status, COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'public';
" 2>&1

# Insérer des données de test
echo ""
echo "📝 Insertion de données de test..."
docker exec twitch-users-db psql -U twitch_user -d users_db -c "
INSERT INTO users (username, email, password_hash, bio) VALUES
('alice', 'alice@example.com', 'hash1', 'Streamer'),
('bob', 'bob@example.com', 'hash2', 'Viewer'),
('charlie', 'charlie@example.com', 'hash3', 'Moderator')
ON CONFLICT (email) DO NOTHING;
SELECT 'Inserted' as status, COUNT(*) as user_count FROM users;
" 2>&1

# Test avec jointure - Followers
echo ""
echo "2️⃣ Test Jointure - Users avec Followers:"
docker exec twitch-users-db psql -U twitch_user -d users_db -c "
-- Créer des relations de followers
INSERT INTO followers (follower_user_id, followed_user_id) 
SELECT 2, 1 WHERE NOT EXISTS (SELECT 1 FROM followers WHERE follower_user_id=2 AND followed_user_id=1);
INSERT INTO followers (follower_user_id, followed_user_id) 
SELECT 3, 1 WHERE NOT EXISTS (SELECT 1 FROM followers WHERE follower_user_id=3 AND followed_user_id=1);

-- Requête avec jointure
SELECT 
    u.username as streamer,
    COUNT(f.id) as follower_count
FROM users u
LEFT JOIN followers f ON u.id = f.followed_user_id
GROUP BY u.id, u.username
ORDER BY follower_count DESC
LIMIT 5;
" 2>&1

# Test Streams DB avec jointures
echo ""
echo "3️⃣ Test Streams DB avec Catégories:"
docker exec twitch-streams-db psql -U twitch_user -d streams_db -c "
-- Insérer des données
INSERT INTO categories (name, slug, description) VALUES
('Gaming', 'gaming', 'Video games'),
('Music', 'music', 'Music streams')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO streams (user_id, category_id, title, is_live, viewer_count)
SELECT 1, 1, 'Epic Gaming Session', true, 250
WHERE NOT EXISTS (SELECT 1 FROM streams WHERE user_id=1 AND title='Epic Gaming Session');

-- Requête avec jointure
SELECT 
    s.title,
    s.viewer_count,
    c.name as category,
    s.is_live
FROM streams s
JOIN categories c ON s.category_id = c.id
ORDER BY s.viewer_count DESC
LIMIT 5;
" 2>&1

# Test Chat DB
echo ""
echo "4️⃣ Test Chat DB avec Messages:"
docker exec twitch-chat-db psql -U twitch_user -d chat_db -c "
-- Insérer des messages
INSERT INTO chat_messages (stream_id, user_id, message) VALUES
(1, 2, 'Hello World!'),
(1, 3, 'Great stream!'),
(1, 2, 'PogChamp')
ON CONFLICT DO NOTHING;

-- Statistiques par stream
SELECT 
    stream_id,
    COUNT(*) as total_messages,
    COUNT(DISTINCT user_id) as unique_chatters
FROM chat_messages
GROUP BY stream_id;
" 2>&1

# Test Subscriptions DB avec jointures complexes
echo ""
echo "5️⃣ Test Subscriptions DB avec Jointures:"
docker exec twitch-subscriptions-db psql -U twitch_user -d subscriptions_db -c "
-- Créer des abonnements
INSERT INTO subscriptions (user_id, streamer_user_id, tier_id, is_active)
SELECT 2, 1, 1, true
WHERE NOT EXISTS (SELECT 1 FROM subscriptions WHERE user_id=2 AND streamer_user_id=1);

INSERT INTO subscriptions (user_id, streamer_user_id, tier_id, is_active)
SELECT 3, 1, 2, true
WHERE NOT EXISTS (SELECT 1 FROM subscriptions WHERE user_id=3 AND streamer_user_id=1);

-- Requête avec jointure
SELECT 
    s.user_id,
    s.streamer_user_id,
    st.tier_name,
    st.price_cents / 100.0 as price_usd,
    s.is_active,
    s.subscribed_at
FROM subscriptions s
JOIN subscription_tiers st ON s.tier_id = st.id
WHERE s.is_active = true
ORDER BY st.price_cents DESC;
" 2>&1

# Test Analytics DB avec agrégations
echo ""
echo "6️⃣ Test Analytics DB:"
docker exec twitch-analytics-db psql -U twitch_user -d analytics_db -c "
-- Insérer des analytics
INSERT INTO stream_analytics (stream_id, user_id, peak_viewers, average_viewers, unique_viewers)
VALUES (1, 1, 500, 350, 1200)
ON CONFLICT DO NOTHING;

SELECT * FROM stream_analytics LIMIT 5;
" 2>&1

echo ""
echo "====================================================="
echo "✅ Tests terminés!"
echo ""
echo "🌐 Accès aux interfaces:"
echo "   - Prometheus: http://localhost:9090"
echo "   - Grafana:    http://localhost:3000"
echo ""
echo "💡 Dans Prometheus, essaye ces requêtes:"
echo "   - up"
echo "   - pg_up"
echo "   - pg_stat_database_numbackends"
echo ""
