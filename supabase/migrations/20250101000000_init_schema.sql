-- TRU Talk Database Schema
-- Scalable to 100M+ users with vector search and real-time capabilities

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone_number TEXT UNIQUE NOT NULL,
  phone_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Profile
  display_name TEXT,
  bio TEXT,
  age INTEGER,
  gender TEXT,
  preferred_languages TEXT[] DEFAULT ARRAY['en'],

  -- Settings
  notification_enabled BOOLEAN DEFAULT TRUE,
  translation_enabled BOOLEAN DEFAULT TRUE,
  auto_detect_language BOOLEAN DEFAULT TRUE,

  -- Gamification
  streak_count INTEGER DEFAULT 0,
  last_call_date DATE,
  total_calls INTEGER DEFAULT 0,
  total_minutes INTEGER DEFAULT 0,
  echo_chips INTEGER DEFAULT 50, -- Free chips on signup

  -- Subscription
  subscription_tier TEXT DEFAULT 'free', -- free, premium, vip
  subscription_expires_at TIMESTAMPTZ,

  -- Metadata
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  fcm_token TEXT, -- Firebase Cloud Messaging for push notifications
  device_info JSONB,

  CONSTRAINT valid_gender CHECK (gender IN ('male', 'female', 'non-binary', 'other')),
  CONSTRAINT valid_subscription CHECK (subscription_tier IN ('free', 'premium', 'vip'))
);

CREATE INDEX idx_users_phone ON public.users(phone_number);
CREATE INDEX idx_users_last_active ON public.users(last_active_at DESC);
CREATE INDEX idx_users_streak ON public.users(streak_count DESC);

-- ============================================================================
-- VOICE CLIPS TABLE
-- ============================================================================
CREATE TABLE public.voice_clips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '60 seconds'), -- Auto-delete after 60s

  -- Audio data
  storage_path TEXT NOT NULL, -- Supabase storage path
  duration_seconds NUMERIC(5,2),
  file_size_bytes INTEGER,

  -- Transcription
  transcription TEXT,
  language_detected TEXT,
  confidence_score NUMERIC(3,2),

  -- Emotion vectors (OpenAI embeddings)
  emotion_vector vector(1536), -- OpenAI ada-002 embedding dimension
  emotion_labels JSONB, -- {lonely: 0.8, happy: 0.2, excited: 0.5}

  -- Status
  processing_status TEXT DEFAULT 'pending', -- pending, processing, completed, error
  error_message TEXT,

  CONSTRAINT valid_status CHECK (processing_status IN ('pending', 'processing', 'completed', 'error'))
);

CREATE INDEX idx_voice_clips_user ON public.voice_clips(user_id);
CREATE INDEX idx_voice_clips_expires ON public.voice_clips(expires_at);
CREATE INDEX idx_voice_clips_emotion_vector ON public.voice_clips USING ivfflat (emotion_vector vector_cosine_ops);

-- ============================================================================
-- MATCHES TABLE
-- ============================================================================
CREATE TABLE public.matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Match participants
  user_id_1 UUID REFERENCES public.users(id) ON DELETE CASCADE,
  user_id_2 UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Match quality
  similarity_score NUMERIC(5,4), -- 0.0000 to 1.0000
  voice_clip_id_1 UUID REFERENCES public.voice_clips(id) ON DELETE SET NULL,
  voice_clip_id_2 UUID REFERENCES public.voice_clips(id) ON DELETE SET NULL,

  -- Match status
  status TEXT DEFAULT 'pending', -- pending, accepted, rejected, expired
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours'),

  CONSTRAINT different_users CHECK (user_id_1 <> user_id_2),
  CONSTRAINT valid_match_status CHECK (status IN ('pending', 'accepted', 'rejected', 'expired'))
);

CREATE INDEX idx_matches_user1 ON public.matches(user_id_1, status);
CREATE INDEX idx_matches_user2 ON public.matches(user_id_2, status);
CREATE INDEX idx_matches_created ON public.matches(created_at DESC);

-- ============================================================================
-- CALLS TABLE
-- ============================================================================
CREATE TABLE public.calls (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,

  -- Participants
  match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
  user_id_1 UUID REFERENCES public.users(id) ON DELETE CASCADE,
  user_id_2 UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Call details
  daily_room_name TEXT, -- Daily.co room identifier
  daily_room_url TEXT,
  duration_seconds INTEGER,

  -- Translation
  translation_enabled BOOLEAN DEFAULT FALSE,
  language_user_1 TEXT,
  language_user_2 TEXT,
  translation_segments JSONB, -- [{speaker: 1, original: "hello", translated: "hola", timestamp: 1.5}]

  -- Quality metrics
  connection_quality JSONB, -- {latency_ms: 120, packet_loss: 0.01}

  -- Echo generation
  echo_summary TEXT, -- 5-word AI summary
  echo_generated_at TIMESTAMPTZ,

  -- Status
  status TEXT DEFAULT 'initiated', -- initiated, active, completed, failed

  CONSTRAINT valid_call_status CHECK (status IN ('initiated', 'active', 'completed', 'failed'))
);

CREATE INDEX idx_calls_user1 ON public.calls(user_id_1);
CREATE INDEX idx_calls_user2 ON public.calls(user_id_2);
CREATE INDEX idx_calls_created ON public.calls(created_at DESC);
CREATE INDEX idx_calls_match ON public.calls(match_id);

-- ============================================================================
-- ECHOS (Trophy System)
-- ============================================================================
CREATE TABLE public.echos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  call_id UUID REFERENCES public.calls(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Echo content
  summary TEXT NOT NULL, -- 5-word summary
  full_transcript TEXT,
  emotion_tag TEXT, -- "joyful", "heartfelt", "inspiring"

  -- Sharing
  is_public BOOLEAN DEFAULT FALSE,
  share_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,

  -- NFT metadata (for premium Echos)
  is_nft BOOLEAN DEFAULT FALSE,
  nft_token_id TEXT,
  nft_blockchain TEXT, -- 'solana', 'ethereum'
  nft_metadata_uri TEXT,

  CONSTRAINT valid_blockchain CHECK (nft_blockchain IN ('solana', 'ethereum', NULL))
);

CREATE INDEX idx_echos_user ON public.echos(user_id);
CREATE INDEX idx_echos_call ON public.echos(call_id);
CREATE INDEX idx_echos_public ON public.echos(is_public, like_count DESC);

-- ============================================================================
-- COMMUNITY FORUMS
-- ============================================================================
CREATE TABLE public.forum_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Content
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  category TEXT, -- 'tips', 'stories', 'support', 'feedback'

  -- Engagement
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,

  -- Moderation
  is_pinned BOOLEAN DEFAULT FALSE,
  is_locked BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,

  CONSTRAINT valid_category CHECK (category IN ('tips', 'stories', 'support', 'feedback'))
);

CREATE INDEX idx_forum_posts_user ON public.forum_posts(user_id);
CREATE INDEX idx_forum_posts_created ON public.forum_posts(created_at DESC);
CREATE INDEX idx_forum_posts_category ON public.forum_posts(category);

CREATE TABLE public.forum_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  post_id UUID REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  parent_comment_id UUID REFERENCES public.forum_comments(id) ON DELETE CASCADE,

  body TEXT NOT NULL,
  like_count INTEGER DEFAULT 0,

  is_deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_forum_comments_post ON public.forum_comments(post_id, created_at);
CREATE INDEX idx_forum_comments_user ON public.forum_comments(user_id);

-- ============================================================================
-- CHALLENGES (Gamification)
-- ============================================================================
CREATE TABLE public.challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Challenge details
  title TEXT NOT NULL,
  description TEXT,
  prompt TEXT, -- Voice prompt for users

  -- Timeline
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,

  -- Rewards
  reward_chips INTEGER DEFAULT 100,
  reward_nft_uri TEXT,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  participant_count INTEGER DEFAULT 0
);

CREATE INDEX idx_challenges_active ON public.challenges(is_active, end_date DESC);

CREATE TABLE public.challenge_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  voice_clip_id UUID REFERENCES public.voice_clips(id) ON DELETE SET NULL,

  vote_count INTEGER DEFAULT 0,
  is_winner BOOLEAN DEFAULT FALSE,

  UNIQUE(challenge_id, user_id)
);

CREATE INDEX idx_challenge_submissions_challenge ON public.challenge_submissions(challenge_id, vote_count DESC);

-- ============================================================================
-- TRANSACTIONS (Payments & Rewards)
-- ============================================================================
CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Transaction details
  type TEXT NOT NULL, -- 'purchase', 'reward', 'refund', 'daily_drop'
  amount INTEGER NOT NULL, -- Echo Chips amount
  price_usd NUMERIC(10,2), -- Actual USD price (for purchases)

  -- Payment
  stripe_payment_intent_id TEXT,
  stripe_customer_id TEXT,

  -- Metadata
  description TEXT,
  metadata JSONB,

  CONSTRAINT valid_transaction_type CHECK (type IN ('purchase', 'reward', 'refund', 'daily_drop'))
);

CREATE INDEX idx_transactions_user ON public.transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_stripe ON public.transactions(stripe_payment_intent_id);

-- ============================================================================
-- ANALYTICS EVENTS
-- ============================================================================
CREATE TABLE public.analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Event data
  event_name TEXT NOT NULL,
  event_properties JSONB,

  -- Context
  session_id UUID,
  device_info JSONB,

  -- Partitioning hint for time-series data
  event_date DATE DEFAULT CURRENT_DATE
);

CREATE INDEX idx_analytics_events_user ON public.analytics_events(user_id, created_at DESC);
CREATE INDEX idx_analytics_events_name ON public.analytics_events(event_name, event_date);

-- ============================================================================
-- ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voice_clips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.echos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

-- Users: Can only view/update their own profile
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Voice clips: Users can only access their own clips
CREATE POLICY "Users can insert own voice clips" ON public.voice_clips
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own voice clips" ON public.voice_clips
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own voice clips" ON public.voice_clips
  FOR DELETE USING (auth.uid() = user_id);

-- Matches: Users can view matches they're part of
CREATE POLICY "Users can view own matches" ON public.matches
  FOR SELECT USING (auth.uid() IN (user_id_1, user_id_2));

CREATE POLICY "Users can update own matches" ON public.matches
  FOR UPDATE USING (auth.uid() IN (user_id_1, user_id_2));

-- Calls: Users can view calls they participated in
CREATE POLICY "Users can view own calls" ON public.calls
  FOR SELECT USING (auth.uid() IN (user_id_1, user_id_2));

-- Echos: Public echos visible to all, private only to owner
CREATE POLICY "Anyone can view public echos" ON public.echos
  FOR SELECT USING (is_public = TRUE);

CREATE POLICY "Users can view own echos" ON public.echos
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own echos" ON public.echos
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Forum: Public read, authenticated write
CREATE POLICY "Anyone can view forum posts" ON public.forum_posts
  FOR SELECT USING (is_deleted = FALSE);

CREATE POLICY "Authenticated users can create posts" ON public.forum_posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON public.forum_posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view comments" ON public.forum_comments
  FOR SELECT USING (is_deleted = FALSE);

CREATE POLICY "Authenticated users can create comments" ON public.forum_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Challenges: Public read
CREATE POLICY "Anyone can view challenges" ON public.challenges
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Users can submit to challenges" ON public.challenge_submissions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Transactions: Users can only view their own
CREATE POLICY "Users can view own transactions" ON public.transactions
  FOR SELECT USING (auth.uid() = user_id);

-- Analytics: Users can insert their own events
CREATE POLICY "Users can insert own analytics" ON public.analytics_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER forum_posts_updated_at BEFORE UPDATE ON public.forum_posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER forum_comments_updated_at BEFORE UPDATE ON public.forum_comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Update streak on call completion
CREATE OR REPLACE FUNCTION update_user_streak()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status <> 'completed' THEN
    UPDATE public.users
    SET
      total_calls = total_calls + 1,
      total_minutes = total_minutes + (NEW.duration_seconds / 60),
      last_call_date = CURRENT_DATE,
      streak_count = CASE
        WHEN last_call_date = CURRENT_DATE - INTERVAL '1 day' THEN streak_count + 1
        WHEN last_call_date = CURRENT_DATE THEN streak_count
        ELSE 1
      END
    WHERE id IN (NEW.user_id_1, NEW.user_id_2);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calls_update_streak AFTER UPDATE ON public.calls
  FOR EACH ROW EXECUTE FUNCTION update_user_streak();

-- Auto-delete expired voice clips (runs via cron job)
CREATE OR REPLACE FUNCTION delete_expired_voice_clips()
RETURNS void AS $$
BEGIN
  DELETE FROM public.voice_clips
  WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Increment comment count on forum posts
CREATE OR REPLACE FUNCTION increment_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.forum_posts
  SET comment_count = comment_count + 1
  WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER forum_comments_increment_count AFTER INSERT ON public.forum_comments
  FOR EACH ROW EXECUTE FUNCTION increment_comment_count();

-- ============================================================================
-- FUNCTIONS FOR BUSINESS LOGIC
-- ============================================================================

-- Find matching users based on emotion vectors
CREATE OR REPLACE FUNCTION find_emotion_match(
  target_user_id UUID,
  target_vector vector(1536),
  max_results INTEGER DEFAULT 10
)
RETURNS TABLE (
  match_user_id UUID,
  similarity_score NUMERIC,
  voice_clip_id UUID
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    vc.user_id,
    1 - (vc.emotion_vector <=> target_vector) AS similarity,
    vc.id
  FROM public.voice_clips vc
  INNER JOIN public.users u ON vc.user_id = u.id
  WHERE
    vc.user_id <> target_user_id
    AND vc.processing_status = 'completed'
    AND vc.expires_at > NOW()
    AND u.last_active_at > NOW() - INTERVAL '7 days' -- Active users only
  ORDER BY vc.emotion_vector <=> target_vector
  LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SEED DATA (for development)
-- ============================================================================

-- Insert sample challenge
INSERT INTO public.challenges (title, description, prompt, start_date, end_date, reward_chips)
VALUES (
  'First Words',
  'Share your first impression of TRU Talk!',
  'In one sentence, what made you download TRU Talk?',
  NOW(),
  NOW() + INTERVAL '7 days',
  200
);
