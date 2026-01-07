-- ============================================
-- SUBSCRIPTIONS SERVICE DATABASE
-- ============================================
-- Gère les abonnements, donations, paiements, points de chaîne

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: subscription_tiers
-- ============================================
CREATE TABLE subscription_tiers (
    id SERIAL PRIMARY KEY,
    tier_name VARCHAR(50) UNIQUE NOT NULL,
    tier_level INTEGER UNIQUE NOT NULL,
    price_cents INTEGER NOT NULL,
    description TEXT,
    benefits JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion des tiers par défaut
INSERT INTO subscription_tiers (tier_name, tier_level, price_cents, description, benefits) VALUES
('Tier 1', 1, 499, 'Abonnement de base', '{"emotes": 1, "badge": true, "ad_free": false}'),
('Tier 2', 2, 999, 'Abonnement intermédiaire', '{"emotes": 2, "badge": true, "ad_free": true}'),
('Tier 3', 3, 2499, 'Abonnement premium', '{"emotes": 5, "badge": true, "ad_free": true, "priority_support": true}');

-- ============================================
-- TABLE: subscriptions
-- ============================================
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    streamer_user_id INTEGER NOT NULL,
    tier_id INTEGER NOT NULL REFERENCES subscription_tiers(id),
    is_active BOOLEAN DEFAULT TRUE,
    is_gift BOOLEAN DEFAULT FALSE,
    gifted_by INTEGER,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    renewed_at TIMESTAMP,
    expires_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_streamer_id ON subscriptions(streamer_user_id);
CREATE INDEX idx_subscriptions_tier_id ON subscriptions(tier_id);
CREATE INDEX idx_subscriptions_is_active ON subscriptions(is_active);
CREATE INDEX idx_subscriptions_expires_at ON subscriptions(expires_at);

-- ============================================
-- TABLE: donations
-- ============================================
CREATE TABLE donations (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    donor_user_id INTEGER NOT NULL,
    streamer_user_id INTEGER NOT NULL,
    amount_cents INTEGER NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    message TEXT,
    is_anonymous BOOLEAN DEFAULT FALSE,
    donated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    refunded_at TIMESTAMP,
    is_refunded BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_donations_donor_id ON donations(donor_user_id);
CREATE INDEX idx_donations_streamer_id ON donations(streamer_user_id);
CREATE INDEX idx_donations_donated_at ON donations(donated_at);
CREATE INDEX idx_donations_amount ON donations(amount_cents);

-- ============================================
-- TABLE: payments
-- ============================================
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    payment_type VARCHAR(50) NOT NULL, -- 'subscription', 'donation', 'bits'
    reference_id INTEGER, -- ID de la subscription ou donation
    amount_cents INTEGER NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50) NOT NULL, -- 'credit_card', 'paypal', 'crypto'
    payment_provider VARCHAR(50),
    transaction_id VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded'
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_type ON payments(payment_type);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- ============================================
-- TABLE: channel_points
-- ============================================
CREATE TABLE channel_points (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    channel_user_id INTEGER NOT NULL,
    points_balance INTEGER DEFAULT 0,
    total_earned INTEGER DEFAULT 0,
    total_spent INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, channel_user_id)
);

CREATE INDEX idx_channel_points_user_id ON channel_points(user_id);
CREATE INDEX idx_channel_points_channel_id ON channel_points(channel_user_id);
CREATE INDEX idx_channel_points_balance ON channel_points(points_balance);

-- ============================================
-- TABLE: channel_points_transactions
-- ============================================
CREATE TABLE channel_points_transactions (
    id SERIAL PRIMARY KEY,
    channel_points_id INTEGER NOT NULL REFERENCES channel_points(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- 'earned', 'spent', 'bonus', 'refund'
    points_amount INTEGER NOT NULL,
    reason VARCHAR(255),
    reference_id INTEGER, -- ID de la récompense si applicable
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_channel_points_transactions_points_id ON channel_points_transactions(channel_points_id);
CREATE INDEX idx_channel_points_transactions_type ON channel_points_transactions(transaction_type);
CREATE INDEX idx_channel_points_transactions_created_at ON channel_points_transactions(created_at);

-- ============================================
-- TABLE: channel_points_rewards
-- ============================================
CREATE TABLE channel_points_rewards (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    reward_name VARCHAR(255) NOT NULL,
    reward_description TEXT,
    points_cost INTEGER NOT NULL,
    background_color VARCHAR(7) DEFAULT '#9147FF',
    is_enabled BOOLEAN DEFAULT TRUE,
    is_user_input_required BOOLEAN DEFAULT FALSE,
    max_per_stream INTEGER,
    max_per_user_per_stream INTEGER,
    global_cooldown_seconds INTEGER,
    redemptions_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_channel_points_rewards_channel_id ON channel_points_rewards(channel_user_id);
CREATE INDEX idx_channel_points_rewards_is_enabled ON channel_points_rewards(is_enabled);

-- ============================================
-- TABLE: channel_points_redemptions
-- ============================================
CREATE TABLE channel_points_redemptions (
    id SERIAL PRIMARY KEY,
    reward_id INTEGER NOT NULL REFERENCES channel_points_rewards(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL,
    channel_user_id INTEGER NOT NULL,
    user_input TEXT,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'fulfilled', 'cancelled', 'rejected'
    redeemed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fulfilled_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_channel_points_redemptions_reward_id ON channel_points_redemptions(reward_id);
CREATE INDEX idx_channel_points_redemptions_user_id ON channel_points_redemptions(user_id);
CREATE INDEX idx_channel_points_redemptions_channel_id ON channel_points_redemptions(channel_user_id);
CREATE INDEX idx_channel_points_redemptions_status ON channel_points_redemptions(status);
CREATE INDEX idx_channel_points_redemptions_redeemed_at ON channel_points_redemptions(redeemed_at);

-- ============================================
-- TABLE: bits_transactions
-- ============================================
CREATE TABLE bits_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    streamer_user_id INTEGER NOT NULL,
    bits_amount INTEGER NOT NULL,
    message TEXT,
    transaction_id VARCHAR(255) UNIQUE,
    cheered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bits_transactions_user_id ON bits_transactions(user_id);
CREATE INDEX idx_bits_transactions_streamer_id ON bits_transactions(streamer_user_id);
CREATE INDEX idx_bits_transactions_cheered_at ON bits_transactions(cheered_at);

-- ============================================
-- TABLE: gift_subscriptions
-- ============================================
CREATE TABLE gift_subscriptions (
    id SERIAL PRIMARY KEY,
    gifter_user_id INTEGER NOT NULL,
    streamer_user_id INTEGER NOT NULL,
    tier_id INTEGER NOT NULL REFERENCES subscription_tiers(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    is_anonymous BOOLEAN DEFAULT FALSE,
    total_cost_cents INTEGER NOT NULL,
    gifted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gift_subscriptions_gifter_id ON gift_subscriptions(gifter_user_id);
CREATE INDEX idx_gift_subscriptions_streamer_id ON gift_subscriptions(streamer_user_id);
CREATE INDEX idx_gift_subscriptions_gifted_at ON gift_subscriptions(gifted_at);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_subscription_tiers_updated_at BEFORE UPDATE ON subscription_tiers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_channel_points_updated_at BEFORE UPDATE ON channel_points
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_channel_points_rewards_updated_at BEFORE UPDATE ON channel_points_rewards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_channel_points_redemptions_updated_at BEFORE UPDATE ON channel_points_redemptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VUES
-- ============================================

-- Vue: Abonnements actifs
CREATE VIEW active_subscriptions AS
SELECT 
    s.*,
    st.tier_name,
    st.price_cents
FROM subscriptions s
JOIN subscription_tiers st ON s.tier_id = st.id
WHERE s.is_active = true 
  AND (s.expires_at IS NULL OR s.expires_at > CURRENT_TIMESTAMP);

-- Vue: Revenus par streamer
CREATE VIEW streamer_revenue AS
SELECT 
    streamer_user_id,
    SUM(CASE WHEN payment_type = 'subscription' THEN amount_cents ELSE 0 END) as subscription_revenue,
    SUM(CASE WHEN payment_type = 'donation' THEN amount_cents ELSE 0 END) as donation_revenue,
    SUM(CASE WHEN payment_type = 'bits' THEN amount_cents ELSE 0 END) as bits_revenue,
    SUM(amount_cents) as total_revenue,
    COUNT(*) as total_transactions
FROM payments p
WHERE p.status = 'completed'
GROUP BY streamer_user_id;

-- Vue: Top donateurs
CREATE VIEW top_donors AS
SELECT 
    donor_user_id,
    streamer_user_id,
    COUNT(*) as donation_count,
    SUM(amount_cents) as total_donated
FROM donations
WHERE is_refunded = false
GROUP BY donor_user_id, streamer_user_id
ORDER BY total_donated DESC;
