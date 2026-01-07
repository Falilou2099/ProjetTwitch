-- ============================================
-- ANALYTICS SERVICE DATABASE
-- ============================================
-- Gère les statistiques, métriques, analyses

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: stream_analytics
-- ============================================
CREATE TABLE stream_analytics (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    total_viewers INTEGER DEFAULT 0,
    peak_viewers INTEGER DEFAULT 0,
    average_viewers INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    new_followers INTEGER DEFAULT 0,
    new_subscribers INTEGER DEFAULT 0,
    total_donations_cents INTEGER DEFAULT 0,
    total_bits INTEGER DEFAULT 0,
    chat_messages_count INTEGER DEFAULT 0,
    stream_duration_seconds INTEGER DEFAULT 0,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stream_analytics_stream_id ON stream_analytics(stream_id);
CREATE INDEX idx_stream_analytics_user_id ON stream_analytics(user_id);
CREATE INDEX idx_stream_analytics_recorded_at ON stream_analytics(recorded_at);

-- ============================================
-- TABLE: viewer_metrics
-- ============================================
CREATE TABLE viewer_metrics (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL,
    viewer_count INTEGER NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_viewer_metrics_stream_id ON viewer_metrics(stream_id);
CREATE INDEX idx_viewer_metrics_recorded_at ON viewer_metrics(recorded_at);

-- ============================================
-- TABLE: user_watch_history
-- ============================================
CREATE TABLE user_watch_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    stream_id INTEGER NOT NULL,
    watch_duration_seconds INTEGER DEFAULT 0,
    started_watching_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    stopped_watching_at TIMESTAMP
);

CREATE INDEX idx_user_watch_history_user_id ON user_watch_history(user_id);
CREATE INDEX idx_user_watch_history_stream_id ON user_watch_history(stream_id);
CREATE INDEX idx_user_watch_history_started_at ON user_watch_history(started_watching_at);

-- ============================================
-- TABLE: channel_analytics
-- ============================================
CREATE TABLE channel_analytics (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    date DATE NOT NULL,
    total_views INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    new_followers INTEGER DEFAULT 0,
    new_subscribers INTEGER DEFAULT 0,
    total_watch_time_seconds BIGINT DEFAULT 0,
    average_concurrent_viewers INTEGER DEFAULT 0,
    peak_concurrent_viewers INTEGER DEFAULT 0,
    total_revenue_cents INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(channel_user_id, date)
);

CREATE INDEX idx_channel_analytics_channel_id ON channel_analytics(channel_user_id);
CREATE INDEX idx_channel_analytics_date ON channel_analytics(date);

-- ============================================
-- TABLE: vod_analytics
-- ============================================
CREATE TABLE vod_analytics (
    id SERIAL PRIMARY KEY,
    vod_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    total_views INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    average_watch_percentage DECIMAL(5,2) DEFAULT 0,
    total_watch_time_seconds BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vod_analytics_vod_id ON vod_analytics(vod_id);
CREATE INDEX idx_vod_analytics_user_id ON vod_analytics(user_id);

-- ============================================
-- TABLE: clip_analytics
-- ============================================
CREATE TABLE clip_analytics (
    id SERIAL PRIMARY KEY,
    clip_id INTEGER NOT NULL,
    creator_user_id INTEGER NOT NULL,
    total_views INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clip_analytics_clip_id ON clip_analytics(clip_id);
CREATE INDEX idx_clip_analytics_creator_id ON clip_analytics(creator_user_id);

-- ============================================
-- TABLE: follower_growth
-- ============================================
CREATE TABLE follower_growth (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    date DATE NOT NULL,
    new_followers INTEGER DEFAULT 0,
    unfollowers INTEGER DEFAULT 0,
    net_followers INTEGER DEFAULT 0,
    total_followers INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(channel_user_id, date)
);

CREATE INDEX idx_follower_growth_channel_id ON follower_growth(channel_user_id);
CREATE INDEX idx_follower_growth_date ON follower_growth(date);

-- ============================================
-- TABLE: subscriber_growth
-- ============================================
CREATE TABLE subscriber_growth (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    date DATE NOT NULL,
    new_subscribers INTEGER DEFAULT 0,
    cancelled_subscribers INTEGER DEFAULT 0,
    net_subscribers INTEGER DEFAULT 0,
    total_subscribers INTEGER DEFAULT 0,
    tier_1_count INTEGER DEFAULT 0,
    tier_2_count INTEGER DEFAULT 0,
    tier_3_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(channel_user_id, date)
);

CREATE INDEX idx_subscriber_growth_channel_id ON subscriber_growth(channel_user_id);
CREATE INDEX idx_subscriber_growth_date ON subscriber_growth(date);

-- ============================================
-- TABLE: revenue_analytics
-- ============================================
CREATE TABLE revenue_analytics (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    date DATE NOT NULL,
    subscription_revenue_cents INTEGER DEFAULT 0,
    donation_revenue_cents INTEGER DEFAULT 0,
    bits_revenue_cents INTEGER DEFAULT 0,
    ad_revenue_cents INTEGER DEFAULT 0,
    total_revenue_cents INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(channel_user_id, date)
);

CREATE INDEX idx_revenue_analytics_channel_id ON revenue_analytics(channel_user_id);
CREATE INDEX idx_revenue_analytics_date ON revenue_analytics(date);

-- ============================================
-- TABLE: chat_analytics
-- ============================================
CREATE TABLE chat_analytics (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL,
    total_messages INTEGER DEFAULT 0,
    unique_chatters INTEGER DEFAULT 0,
    messages_per_minute DECIMAL(10,2) DEFAULT 0,
    top_emotes JSONB,
    top_chatters JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_analytics_stream_id ON chat_analytics(stream_id);

-- ============================================
-- TABLE: category_performance
-- ============================================
CREATE TABLE category_performance (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    streams_count INTEGER DEFAULT 0,
    total_watch_time_seconds BIGINT DEFAULT 0,
    average_viewers INTEGER DEFAULT 0,
    peak_viewers INTEGER DEFAULT 0,
    total_revenue_cents INTEGER DEFAULT 0,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_category_performance_channel_id ON category_performance(channel_user_id);
CREATE INDEX idx_category_performance_category_id ON category_performance(category_id);
CREATE INDEX idx_category_performance_period ON category_performance(period_start, period_end);

-- ============================================
-- TABLE: engagement_metrics
-- ============================================
CREATE TABLE engagement_metrics (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    date DATE NOT NULL,
    chat_participation_rate DECIMAL(5,2) DEFAULT 0,
    average_watch_duration_seconds INTEGER DEFAULT 0,
    follower_to_viewer_ratio DECIMAL(5,2) DEFAULT 0,
    subscriber_to_viewer_ratio DECIMAL(5,2) DEFAULT 0,
    clips_created INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(channel_user_id, date)
);

CREATE INDEX idx_engagement_metrics_channel_id ON engagement_metrics(channel_user_id);
CREATE INDEX idx_engagement_metrics_date ON engagement_metrics(date);

-- ============================================
-- TABLE: advertising_analytics
-- ============================================
CREATE TABLE advertising_analytics (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL,
    ad_id INTEGER NOT NULL,
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    click_through_rate DECIMAL(5,2) DEFAULT 0,
    revenue_cents INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_advertising_analytics_stream_id ON advertising_analytics(stream_id);
CREATE INDEX idx_advertising_analytics_ad_id ON advertising_analytics(ad_id);

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

CREATE TRIGGER update_channel_analytics_updated_at BEFORE UPDATE ON channel_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vod_analytics_updated_at BEFORE UPDATE ON vod_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clip_analytics_updated_at BEFORE UPDATE ON clip_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_revenue_analytics_updated_at BEFORE UPDATE ON revenue_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VUES AGRÉGÉES
-- ============================================

-- Vue: Performance globale par chaîne (30 derniers jours)
CREATE VIEW channel_performance_30d AS
SELECT 
    channel_user_id,
    SUM(total_views) as total_views,
    SUM(unique_viewers) as unique_viewers,
    SUM(new_followers) as new_followers,
    SUM(new_subscribers) as new_subscribers,
    SUM(total_watch_time_seconds) as total_watch_time_seconds,
    AVG(average_concurrent_viewers) as avg_concurrent_viewers,
    MAX(peak_concurrent_viewers) as peak_concurrent_viewers,
    SUM(total_revenue_cents) as total_revenue_cents
FROM channel_analytics
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY channel_user_id;

-- Vue: Croissance des revenus
CREATE VIEW revenue_growth AS
SELECT 
    channel_user_id,
    date,
    total_revenue_cents,
    LAG(total_revenue_cents) OVER (PARTITION BY channel_user_id ORDER BY date) as previous_day_revenue,
    total_revenue_cents - LAG(total_revenue_cents) OVER (PARTITION BY channel_user_id ORDER BY date) as revenue_change
FROM revenue_analytics
ORDER BY channel_user_id, date DESC;

-- Vue: Top streams par viewers
CREATE VIEW top_streams_by_viewers AS
SELECT 
    stream_id,
    user_id,
    peak_viewers,
    average_viewers,
    total_viewers,
    stream_duration_seconds,
    recorded_at
FROM stream_analytics
ORDER BY peak_viewers DESC, average_viewers DESC
LIMIT 100;
