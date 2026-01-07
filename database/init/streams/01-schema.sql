-- ============================================
-- STREAMS SERVICE DATABASE
-- ============================================
-- Gère les streams, VODs, clips, catégories

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: categories
-- ============================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_is_active ON categories(is_active);

-- ============================================
-- TABLE: tags
-- ============================================
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tags_slug ON tags(slug);

-- ============================================
-- TABLE: streams
-- ============================================
CREATE TABLE streams (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    user_id INTEGER NOT NULL, -- Référence externe au users service
    category_id INTEGER REFERENCES categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_live BOOLEAN DEFAULT FALSE,
    viewer_count INTEGER DEFAULT 0,
    peak_viewer_count INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    stream_key VARCHAR(255) UNIQUE,
    thumbnail_url VARCHAR(500),
    language VARCHAR(10) DEFAULT 'en',
    is_mature BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_streams_user_id ON streams(user_id);
CREATE INDEX idx_streams_category_id ON streams(category_id);
CREATE INDEX idx_streams_is_live ON streams(is_live);
CREATE INDEX idx_streams_started_at ON streams(started_at);
CREATE INDEX idx_streams_viewer_count ON streams(viewer_count);

-- ============================================
-- TABLE: stream_tags
-- ============================================
CREATE TABLE stream_tags (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stream_id, tag_id)
);

CREATE INDEX idx_stream_tags_stream_id ON stream_tags(stream_id);
CREATE INDEX idx_stream_tags_tag_id ON stream_tags(tag_id);

-- ============================================
-- TABLE: stream_category_history
-- ============================================
CREATE TABLE stream_category_history (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP
);

CREATE INDEX idx_stream_category_history_stream_id ON stream_category_history(stream_id);
CREATE INDEX idx_stream_category_history_category_id ON stream_category_history(category_id);

-- ============================================
-- TABLE: vods (Video On Demand)
-- ============================================
CREATE TABLE vods (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    stream_id INTEGER REFERENCES streams(id) ON DELETE SET NULL,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration_seconds INTEGER,
    view_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    recorded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_vods_stream_id ON vods(stream_id);
CREATE INDEX idx_vods_user_id ON vods(user_id);
CREATE INDEX idx_vods_is_published ON vods(is_published);
CREATE INDEX idx_vods_view_count ON vods(view_count);
CREATE INDEX idx_vods_recorded_at ON vods(recorded_at);

-- ============================================
-- TABLE: clips
-- ============================================
CREATE TABLE clips (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    stream_id INTEGER REFERENCES streams(id) ON DELETE SET NULL,
    vod_id INTEGER REFERENCES vods(id) ON DELETE SET NULL,
    creator_user_id INTEGER NOT NULL,
    streamer_user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    clip_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration_seconds INTEGER NOT NULL,
    view_count INTEGER DEFAULT 0,
    offset_seconds INTEGER, -- Position dans le VOD/stream
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_clips_stream_id ON clips(stream_id);
CREATE INDEX idx_clips_vod_id ON clips(vod_id);
CREATE INDEX idx_clips_creator_user_id ON clips(creator_user_id);
CREATE INDEX idx_clips_streamer_user_id ON clips(streamer_user_id);
CREATE INDEX idx_clips_view_count ON clips(view_count);
CREATE INDEX idx_clips_created_at ON clips(created_at);

-- ============================================
-- TABLE: stream_raids
-- ============================================
CREATE TABLE stream_raids (
    id SERIAL PRIMARY KEY,
    source_stream_id INTEGER NOT NULL REFERENCES streams(id),
    target_stream_id INTEGER NOT NULL REFERENCES streams(id),
    raider_user_id INTEGER NOT NULL,
    viewer_count INTEGER DEFAULT 0,
    raided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (source_stream_id != target_stream_id)
);

CREATE INDEX idx_stream_raids_source ON stream_raids(source_stream_id);
CREATE INDEX idx_stream_raids_target ON stream_raids(target_stream_id);
CREATE INDEX idx_stream_raids_raider ON stream_raids(raider_user_id);

-- ============================================
-- TABLE: stream_events
-- ============================================
CREATE TABLE stream_events (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- 'follow', 'subscription', 'donation', 'raid', 'host'
    event_user_id INTEGER,
    event_data JSONB,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stream_events_stream_id ON stream_events(stream_id);
CREATE INDEX idx_stream_events_type ON stream_events(event_type);
CREATE INDEX idx_stream_events_occurred_at ON stream_events(occurred_at);

-- ============================================
-- TABLE: polls
-- ============================================
CREATE TABLE polls (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    duration_seconds INTEGER DEFAULT 60,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_polls_stream_id ON polls(stream_id);
CREATE INDEX idx_polls_is_active ON polls(is_active);

-- ============================================
-- TABLE: poll_options
-- ============================================
CREATE TABLE poll_options (
    id SERIAL PRIMARY KEY,
    poll_id INTEGER NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    option_text VARCHAR(255) NOT NULL,
    vote_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_poll_options_poll_id ON poll_options(poll_id);

-- ============================================
-- TABLE: poll_votes
-- ============================================
CREATE TABLE poll_votes (
    id SERIAL PRIMARY KEY,
    poll_id INTEGER NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    option_id INTEGER NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL,
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(poll_id, user_id)
);

CREATE INDEX idx_poll_votes_poll_id ON poll_votes(poll_id);
CREATE INDEX idx_poll_votes_option_id ON poll_votes(option_id);
CREATE INDEX idx_poll_votes_user_id ON poll_votes(user_id);

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

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_streams_updated_at BEFORE UPDATE ON streams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vods_updated_at BEFORE UPDATE ON vods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clips_updated_at BEFORE UPDATE ON clips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VUES
-- ============================================

-- Vue: Streams en direct
CREATE VIEW live_streams AS
SELECT 
    s.*,
    c.name as category_name,
    c.slug as category_slug
FROM streams s
LEFT JOIN categories c ON s.category_id = c.id
WHERE s.is_live = true
ORDER BY s.viewer_count DESC;

-- Vue: Top clips
CREATE VIEW top_clips AS
SELECT 
    c.*,
    s.title as stream_title
FROM clips c
LEFT JOIN streams s ON c.stream_id = s.id
WHERE c.deleted_at IS NULL
ORDER BY c.view_count DESC, c.created_at DESC;
