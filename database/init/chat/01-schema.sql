-- ============================================
-- CHAT SERVICE DATABASE
-- ============================================
-- Gère les messages, emotes, modération du chat

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: chat_messages
-- ============================================
CREATE TABLE chat_messages (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    stream_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_by INTEGER,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_messages_stream_id ON chat_messages(stream_id);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX idx_chat_messages_is_deleted ON chat_messages(is_deleted);

-- ============================================
-- TABLE: emotes
-- ============================================
CREATE TABLE emotes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    creator_user_id INTEGER,
    is_global BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emotes_code ON emotes(code);
CREATE INDEX idx_emotes_is_global ON emotes(is_global);
CREATE INDEX idx_emotes_creator ON emotes(creator_user_id);

-- ============================================
-- TABLE: channel_emotes
-- ============================================
CREATE TABLE channel_emotes (
    id SERIAL PRIMARY KEY,
    emote_id INTEGER NOT NULL REFERENCES emotes(id) ON DELETE CASCADE,
    channel_user_id INTEGER NOT NULL,
    subscription_tier INTEGER DEFAULT 0, -- 0 = tous, 1-3 = tiers spécifiques
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(emote_id, channel_user_id)
);

CREATE INDEX idx_channel_emotes_emote_id ON channel_emotes(emote_id);
CREATE INDEX idx_channel_emotes_channel_id ON channel_emotes(channel_user_id);

-- ============================================
-- TABLE: moderators
-- ============================================
CREATE TABLE moderators (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    moderator_user_id INTEGER NOT NULL,
    assigned_by INTEGER NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(channel_user_id, moderator_user_id)
);

CREATE INDEX idx_moderators_channel ON moderators(channel_user_id);
CREATE INDEX idx_moderators_user ON moderators(moderator_user_id);
CREATE INDEX idx_moderators_is_active ON moderators(is_active);

-- ============================================
-- TABLE: chat_bans
-- ============================================
CREATE TABLE chat_bans (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    banned_user_id INTEGER NOT NULL,
    banned_by INTEGER NOT NULL,
    ban_reason TEXT NOT NULL,
    is_permanent BOOLEAN DEFAULT FALSE,
    banned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    unbanned_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_chat_bans_channel ON chat_bans(channel_user_id);
CREATE INDEX idx_chat_bans_user ON chat_bans(banned_user_id);
CREATE INDEX idx_chat_bans_is_active ON chat_bans(is_active);

-- ============================================
-- TABLE: chat_timeouts
-- ============================================
CREATE TABLE chat_timeouts (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    moderator_user_id INTEGER NOT NULL,
    timeout_reason TEXT,
    duration_seconds INTEGER NOT NULL,
    timed_out_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_chat_timeouts_channel ON chat_timeouts(channel_user_id);
CREATE INDEX idx_chat_timeouts_user ON chat_timeouts(user_id);
CREATE INDEX idx_chat_timeouts_expires_at ON chat_timeouts(expires_at);

-- ============================================
-- TABLE: moderation_actions
-- ============================================
CREATE TABLE moderation_actions (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    moderator_user_id INTEGER NOT NULL,
    target_user_id INTEGER,
    action_type VARCHAR(50) NOT NULL, -- 'ban', 'timeout', 'delete_message', 'clear_chat', 'slow_mode', 'followers_only'
    action_reason TEXT,
    action_data JSONB,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_moderation_actions_channel ON moderation_actions(channel_user_id);
CREATE INDEX idx_moderation_actions_moderator ON moderation_actions(moderator_user_id);
CREATE INDEX idx_moderation_actions_target ON moderation_actions(target_user_id);
CREATE INDEX idx_moderation_actions_type ON moderation_actions(action_type);
CREATE INDEX idx_moderation_actions_performed_at ON moderation_actions(performed_at);

-- ============================================
-- TABLE: chat_settings
-- ============================================
CREATE TABLE chat_settings (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER UNIQUE NOT NULL,
    slow_mode_seconds INTEGER DEFAULT 0,
    followers_only_minutes INTEGER DEFAULT 0, -- 0 = désactivé
    subscribers_only BOOLEAN DEFAULT FALSE,
    emote_only BOOLEAN DEFAULT FALSE,
    unique_chat BOOLEAN DEFAULT FALSE,
    links_allowed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_settings_channel ON chat_settings(channel_user_id);

-- ============================================
-- TABLE: automod_rules
-- ============================================
CREATE TABLE automod_rules (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL, -- 'blocked_words', 'spam_detection', 'caps_limit', 'link_filter'
    rule_config JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_automod_rules_channel ON automod_rules(channel_user_id);
CREATE INDEX idx_automod_rules_type ON automod_rules(rule_type);
CREATE INDEX idx_automod_rules_is_active ON automod_rules(is_active);

-- ============================================
-- TABLE: automod_violations
-- ============================================
CREATE TABLE automod_violations (
    id SERIAL PRIMARY KEY,
    channel_user_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rule_id INTEGER REFERENCES automod_rules(id) ON DELETE SET NULL,
    message_id INTEGER REFERENCES chat_messages(id) ON DELETE SET NULL,
    violation_type VARCHAR(50) NOT NULL,
    action_taken VARCHAR(50), -- 'blocked', 'timeout', 'warning'
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_automod_violations_channel ON automod_violations(channel_user_id);
CREATE INDEX idx_automod_violations_user ON automod_violations(user_id);
CREATE INDEX idx_automod_violations_rule ON automod_violations(rule_id);
CREATE INDEX idx_automod_violations_detected_at ON automod_violations(detected_at);

-- ============================================
-- TABLE: chat_badges
-- ============================================
CREATE TABLE chat_badges (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    badge_type VARCHAR(50) NOT NULL, -- 'global', 'channel', 'subscription', 'special'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: user_badges
-- ============================================
CREATE TABLE user_badges (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    channel_user_id INTEGER, -- NULL pour badges globaux
    badge_id INTEGER NOT NULL REFERENCES chat_badges(id) ON DELETE CASCADE,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, channel_user_id, badge_id)
);

CREATE INDEX idx_user_badges_user ON user_badges(user_id);
CREATE INDEX idx_user_badges_channel ON user_badges(channel_user_id);
CREATE INDEX idx_user_badges_badge ON user_badges(badge_id);

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

CREATE TRIGGER update_emotes_updated_at BEFORE UPDATE ON emotes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_settings_updated_at BEFORE UPDATE ON chat_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_automod_rules_updated_at BEFORE UPDATE ON automod_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VUES
-- ============================================

-- Vue: Messages actifs par stream
CREATE VIEW active_chat_messages AS
SELECT 
    cm.*
FROM chat_messages cm
WHERE cm.is_deleted = false
ORDER BY cm.created_at DESC;

-- Vue: Modérateurs actifs
CREATE VIEW active_moderators AS
SELECT 
    m.*
FROM moderators m
WHERE m.is_active = true;

-- Vue: Bans actifs
CREATE VIEW active_bans AS
SELECT 
    cb.*
FROM chat_bans cb
WHERE cb.is_active = true 
  AND (cb.is_permanent = true OR cb.expires_at > CURRENT_TIMESTAMP);
