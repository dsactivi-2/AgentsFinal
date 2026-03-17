-- =============================================================================
-- Social AI Stack — PostgreSQL Schema
-- =============================================================================
-- Erstellt via: psql -U postgres -d social_ai -f schema.sql
-- Oder via bootstrap.sh automatisch
-- =============================================================================

-- Erweiterungen
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- messages — Alle eingehenden und ausgehenden Nachrichten
-- =============================================================================
CREATE TABLE IF NOT EXISTS messages (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform      VARCHAR(32)  NOT NULL CHECK (platform IN ('messenger', 'instagram', 'whatsapp', 'telegram', 'test')),
    psid          VARCHAR(128) NOT NULL,
    direction     VARCHAR(8)   NOT NULL CHECK (direction IN ('in', 'out')),
    content       TEXT         NOT NULL,
    content_type  VARCHAR(32)  NOT NULL DEFAULT 'text' CHECK (content_type IN ('text', 'image', 'audio', 'video', 'file', 'sticker')),
    meta_message_id VARCHAR(256),
    request_id    VARCHAR(64),
    processed     BOOLEAN      NOT NULL DEFAULT FALSE,
    error         TEXT,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_psid ON messages(psid);
CREATE INDEX IF NOT EXISTS idx_messages_platform ON messages(platform);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_direction ON messages(direction);
CREATE INDEX IF NOT EXISTS idx_messages_meta_id ON messages(meta_message_id) WHERE meta_message_id IS NOT NULL;

-- =============================================================================
-- sessions — Aktive Nutzersitzungen und deren Zustand
-- =============================================================================
CREATE TABLE IF NOT EXISTS sessions (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    psid          VARCHAR(128) NOT NULL,
    platform      VARCHAR(32)  NOT NULL CHECK (platform IN ('messenger', 'instagram', 'whatsapp', 'telegram', 'test')),
    state         VARCHAR(64)  NOT NULL DEFAULT 'active' CHECK (state IN ('active', 'idle', 'escalated', 'closed')),
    language      VARCHAR(8)   NOT NULL DEFAULT 'de' CHECK (language IN ('de', 'en', 'bs', 'sr', 'hr', 'other')),
    escalated     BOOLEAN      NOT NULL DEFAULT FALSE,
    escalation_id UUID,
    context       JSONB        NOT NULL DEFAULT '{}',
    message_count INTEGER      NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_message_at TIMESTAMPTZ,
    closed_at     TIMESTAMPTZ,

    CONSTRAINT sessions_psid_platform_unique UNIQUE (psid, platform)
);

CREATE INDEX IF NOT EXISTS idx_sessions_psid ON sessions(psid);
CREATE INDEX IF NOT EXISTS idx_sessions_state ON sessions(state);
CREATE INDEX IF NOT EXISTS idx_sessions_platform ON sessions(platform);
CREATE INDEX IF NOT EXISTS idx_sessions_updated_at ON sessions(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_escalated ON sessions(escalated) WHERE escalated = TRUE;

-- Auto-Update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_sessions_updated_at
    BEFORE UPDATE ON sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- escalations — Eskalationen an menschliche Mitarbeiter
-- =============================================================================
CREATE TABLE IF NOT EXISTS escalations (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id    UUID         NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    psid          VARCHAR(128) NOT NULL,
    platform      VARCHAR(32)  NOT NULL,
    reason        VARCHAR(256) NOT NULL,
    reason_code   VARCHAR(64)  CHECK (reason_code IN ('user_request', 'sentiment_negative', 'complexity_high', 'policy_violation', 'legal', 'technical_error', 'other')),
    context_snapshot JSONB     NOT NULL DEFAULT '{}',
    assigned_to   VARCHAR(128),
    resolved      BOOLEAN      NOT NULL DEFAULT FALSE,
    resolved_at   TIMESTAMPTZ,
    resolution_note TEXT,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_escalations_session_id ON escalations(session_id);
CREATE INDEX IF NOT EXISTS idx_escalations_psid ON escalations(psid);
CREATE INDEX IF NOT EXISTS idx_escalations_resolved ON escalations(resolved);
CREATE INDEX IF NOT EXISTS idx_escalations_created_at ON escalations(created_at DESC);

-- =============================================================================
-- consent — DSGVO-Einwilligungen und Opt-out-Status
-- =============================================================================
CREATE TABLE IF NOT EXISTS consent (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    psid          VARCHAR(128) NOT NULL,
    platform      VARCHAR(32)  NOT NULL,
    opted_out     BOOLEAN      NOT NULL DEFAULT FALSE,
    opted_out_at  TIMESTAMPTZ,
    opt_in_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    data_deletion_requested BOOLEAN NOT NULL DEFAULT FALSE,
    data_deletion_at TIMESTAMPTZ,
    ip_hash       VARCHAR(64),
    notes         TEXT,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT consent_psid_platform_unique UNIQUE (psid, platform)
);

CREATE INDEX IF NOT EXISTS idx_consent_psid ON consent(psid);
CREATE INDEX IF NOT EXISTS idx_consent_opted_out ON consent(opted_out);
CREATE INDEX IF NOT EXISTS idx_consent_platform ON consent(platform);

CREATE TRIGGER update_consent_updated_at
    BEFORE UPDATE ON consent
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- campaign_learnings — Performance-Learnings für Content-Optimierung
-- =============================================================================
CREATE TABLE IF NOT EXISTS campaign_learnings (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hook          VARCHAR(256) NOT NULL,
    cta           VARCHAR(256),
    content_type  VARCHAR(64)  CHECK (content_type IN ('text', 'image', 'video', 'carousel', 'story', 'reel')),
    timing        VARCHAR(64),
    timing_hour   SMALLINT     CHECK (timing_hour BETWEEN 0 AND 23),
    timing_day    VARCHAR(16)  CHECK (timing_day IN ('monday','tuesday','wednesday','thursday','friday','saturday','sunday')),
    language      VARCHAR(8)   NOT NULL DEFAULT 'de',
    platform      VARCHAR(32)  NOT NULL DEFAULT 'instagram',
    score         NUMERIC(5,2) NOT NULL DEFAULT 0.0 CHECK (score BETWEEN -100.0 AND 100.0),
    reach         INTEGER      DEFAULT 0,
    impressions   INTEGER      DEFAULT 0,
    engagements   INTEGER      DEFAULT 0,
    engagement_rate NUMERIC(5,2) DEFAULT 0.0,
    tags          TEXT[]       DEFAULT '{}',
    raw_data      JSONB        NOT NULL DEFAULT '{}',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_learnings_score ON campaign_learnings(score DESC);
CREATE INDEX IF NOT EXISTS idx_learnings_platform ON campaign_learnings(platform);
CREATE INDEX IF NOT EXISTS idx_learnings_language ON campaign_learnings(language);
CREATE INDEX IF NOT EXISTS idx_learnings_timing_hour ON campaign_learnings(timing_hour);
CREATE INDEX IF NOT EXISTS idx_learnings_content_type ON campaign_learnings(content_type);
CREATE INDEX IF NOT EXISTS idx_learnings_created_at ON campaign_learnings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_learnings_tags ON campaign_learnings USING GIN(tags);

-- =============================================================================
-- scheduled_posts — Geplante und veröffentlichte Posts
-- =============================================================================
CREATE TABLE IF NOT EXISTS scheduled_posts (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform      VARCHAR(32)  NOT NULL,
    content       TEXT         NOT NULL,
    media_urls    TEXT[]       DEFAULT '{}',
    hashtags      TEXT[]       DEFAULT '{}',
    scheduled_at  TIMESTAMPTZ  NOT NULL,
    published_at  TIMESTAMPTZ,
    status        VARCHAR(32)  NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'published', 'failed', 'cancelled')),
    external_id   VARCHAR(256),
    campaign_id   VARCHAR(128),
    language      VARCHAR(8)   NOT NULL DEFAULT 'de',
    approved_by   VARCHAR(128),
    approved_at   TIMESTAMPTZ,
    error_message TEXT,
    metadata      JSONB        NOT NULL DEFAULT '{}',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_status ON scheduled_posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_scheduled_at ON scheduled_posts(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_posts_platform ON scheduled_posts(platform);
CREATE INDEX IF NOT EXISTS idx_posts_campaign_id ON scheduled_posts(campaign_id) WHERE campaign_id IS NOT NULL;

CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON scheduled_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- leads — Warme Leads für automatisches Follow-up-Nurturing
-- =============================================================================
CREATE TABLE IF NOT EXISTS leads (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    psid             VARCHAR(128)  NOT NULL,
    platform         VARCHAR(32)   NOT NULL CHECK (platform IN ('messenger', 'instagram', 'whatsapp', 'telegram', 'test')),
    status           VARCHAR(32)   NOT NULL DEFAULT 'warm' CHECK (status IN ('warm', 'cold', 'responded', 'converted', 'opted_out')),
    language         VARCHAR(8)    NOT NULL DEFAULT 'de' CHECK (language IN ('de', 'en', 'bs', 'sr', 'hr', 'other')),
    followup_count   SMALLINT      NOT NULL DEFAULT 0 CHECK (followup_count BETWEEN 0 AND 3),
    first_contact_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    last_followup_at TIMESTAMPTZ,
    next_followup_at TIMESTAMPTZ,
    responded_at     TIMESTAMPTZ,
    context          JSONB         NOT NULL DEFAULT '{}',
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT leads_psid_platform_unique UNIQUE (psid, platform)
);

CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_next_followup ON leads(next_followup_at) WHERE status = 'warm';
CREATE INDEX IF NOT EXISTS idx_leads_psid ON leads(psid);
CREATE INDEX IF NOT EXISTS idx_leads_platform ON leads(platform);

CREATE TRIGGER update_leads_updated_at
    BEFORE UPDATE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- lead_followups — Log aller gesendeten Follow-up-Nachrichten
-- =============================================================================
CREATE TABLE IF NOT EXISTS lead_followups (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id          UUID          NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    step             SMALLINT      NOT NULL CHECK (step BETWEEN 1 AND 3),
    message_content  TEXT          NOT NULL,
    sent_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    delivered        BOOLEAN       NOT NULL DEFAULT FALSE,
    reviewer_approved BOOLEAN      NOT NULL DEFAULT TRUE,
    error            TEXT,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lead_followups_lead_id ON lead_followups(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_followups_sent_at ON lead_followups(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_lead_followups_delivered ON lead_followups(delivered) WHERE delivered = FALSE;

-- =============================================================================
-- Kommentare / Abschluss
-- =============================================================================
COMMENT ON TABLE messages IS 'Alle ein- und ausgehenden Nachrichten über alle Plattformen';
COMMENT ON TABLE sessions IS 'Aktive Gesprächssitzungen mit Zustandsmaschine';
COMMENT ON TABLE escalations IS 'Eskalationen an menschliche Mitarbeiter mit DSGVO-konformer Dokumentation';
COMMENT ON TABLE consent IS 'DSGVO-Einwilligungen und Opt-out-Verwaltung pro Nutzer';
COMMENT ON TABLE campaign_learnings IS 'Performance-Learnings für datengetriebene Content-Optimierung';
COMMENT ON TABLE scheduled_posts IS 'Geplante und veröffentlichte Social-Media-Posts via Postiz';
COMMENT ON TABLE leads IS 'Warme Leads mit Follow-up-Timing für automatisches Nurturing';
COMMENT ON TABLE lead_followups IS 'Log aller gesendeten Follow-up-Nachrichten pro Lead';
