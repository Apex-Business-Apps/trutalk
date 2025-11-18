// Shared TypeScript types for TRU Talk

export interface User {
  id: string;
  phone_number: string;
  phone_verified: boolean;
  created_at: string;
  updated_at: string;
  display_name?: string;
  bio?: string;
  age?: number;
  gender?: 'male' | 'female' | 'non-binary' | 'other';
  preferred_languages: string[];
  notification_enabled: boolean;
  translation_enabled: boolean;
  auto_detect_language: boolean;
  streak_count: number;
  last_call_date?: string;
  total_calls: number;
  total_minutes: number;
  echo_chips: number;
  subscription_tier: 'free' | 'premium' | 'vip';
  subscription_expires_at?: string;
  last_active_at: string;
  fcm_token?: string;
  device_info?: Record<string, any>;
}

export interface VoiceClip {
  id: string;
  user_id: string;
  created_at: string;
  expires_at: string;
  storage_path: string;
  duration_seconds: number;
  file_size_bytes: number;
  transcription?: string;
  language_detected?: string;
  confidence_score?: number;
  emotion_vector?: number[];
  emotion_labels?: EmotionLabels;
  processing_status: 'pending' | 'processing' | 'completed' | 'error';
  error_message?: string;
}

export interface EmotionLabels {
  lonely?: number;
  happy?: number;
  excited?: number;
  sad?: number;
  anxious?: number;
  calm?: number;
  romantic?: number;
  playful?: number;
}

export interface Match {
  id: string;
  created_at: string;
  user_id_1: string;
  user_id_2: string;
  similarity_score: number;
  voice_clip_id_1?: string;
  voice_clip_id_2?: string;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  expires_at: string;
}

export interface Call {
  id: string;
  created_at: string;
  started_at?: string;
  ended_at?: string;
  match_id: string;
  user_id_1: string;
  user_id_2: string;
  daily_room_name?: string;
  daily_room_url?: string;
  duration_seconds?: number;
  translation_enabled: boolean;
  language_user_1?: string;
  language_user_2?: string;
  translation_segments?: TranslationSegment[];
  connection_quality?: ConnectionQuality;
  echo_summary?: string;
  echo_generated_at?: string;
  status: 'initiated' | 'active' | 'completed' | 'failed';
}

export interface TranslationSegment {
  speaker: 1 | 2;
  original: string;
  translated: string;
  timestamp: number;
  language_from: string;
  language_to: string;
}

export interface ConnectionQuality {
  latency_ms: number;
  packet_loss: number;
  jitter_ms: number;
}

export interface Echo {
  id: string;
  created_at: string;
  call_id: string;
  user_id: string;
  summary: string;
  full_transcript?: string;
  emotion_tag?: string;
  is_public: boolean;
  share_count: number;
  like_count: number;
  is_nft: boolean;
  nft_token_id?: string;
  nft_blockchain?: 'solana' | 'ethereum';
  nft_metadata_uri?: string;
}

export interface ForumPost {
  id: string;
  created_at: string;
  updated_at: string;
  user_id: string;
  title: string;
  body: string;
  category: 'tips' | 'stories' | 'support' | 'feedback';
  view_count: number;
  like_count: number;
  comment_count: number;
  is_pinned: boolean;
  is_locked: boolean;
  is_deleted: boolean;
}

export interface ForumComment {
  id: string;
  created_at: string;
  updated_at: string;
  post_id: string;
  user_id: string;
  parent_comment_id?: string;
  body: string;
  like_count: number;
  is_deleted: boolean;
}

export interface Challenge {
  id: string;
  created_at: string;
  title: string;
  description?: string;
  prompt?: string;
  start_date: string;
  end_date: string;
  reward_chips: number;
  reward_nft_uri?: string;
  is_active: boolean;
  participant_count: number;
}

export interface ChallengeSubmission {
  id: string;
  created_at: string;
  challenge_id: string;
  user_id: string;
  voice_clip_id?: string;
  vote_count: number;
  is_winner: boolean;
}

export interface Transaction {
  id: string;
  created_at: string;
  user_id: string;
  type: 'purchase' | 'reward' | 'refund' | 'daily_drop';
  amount: number;
  price_usd?: number;
  stripe_payment_intent_id?: string;
  stripe_customer_id?: string;
  description?: string;
  metadata?: Record<string, any>;
}

export interface AnalyticsEvent {
  id: string;
  created_at: string;
  user_id: string;
  event_name: string;
  event_properties?: Record<string, any>;
  session_id?: string;
  device_info?: Record<string, any>;
  event_date: string;
}

// API Request/Response types
export interface VerifyPhoneRequest {
  phone_number: string;
  verification_code?: string;
}

export interface VerifyPhoneResponse {
  success: boolean;
  user_id?: string;
  token?: string;
  message?: string;
}

export interface TranscribeRequest {
  voice_clip_id: string;
  audio_url: string;
}

export interface TranscribeResponse {
  success: boolean;
  transcription?: string;
  language_detected?: string;
  confidence_score?: number;
  error?: string;
}

export interface VectorizeRequest {
  voice_clip_id: string;
  transcription: string;
}

export interface VectorizeResponse {
  success: boolean;
  emotion_vector?: number[];
  emotion_labels?: EmotionLabels;
  error?: string;
}

export interface FindMatchRequest {
  user_id: string;
  voice_clip_id: string;
}

export interface FindMatchResponse {
  success: boolean;
  match?: Match;
  error?: string;
}

export interface StartCallRequest {
  match_id: string;
  user_id: string;
}

export interface StartCallResponse {
  success: boolean;
  call?: Call;
  room_url?: string;
  error?: string;
}

export interface DailyDropResponse {
  success: boolean;
  users_updated: number;
  chips_distributed: number;
}

// Constants
export const LANGUAGES = [
  { code: 'en', name: 'English' },
  { code: 'es', name: 'Spanish' },
  { code: 'fr', name: 'French' },
  { code: 'de', name: 'German' },
  { code: 'it', name: 'Italian' },
  { code: 'pt', name: 'Portuguese' },
  { code: 'ru', name: 'Russian' },
  { code: 'ja', name: 'Japanese' },
  { code: 'ko', name: 'Korean' },
  { code: 'zh', name: 'Chinese' },
  { code: 'ar', name: 'Arabic' },
  { code: 'hi', name: 'Hindi' },
  { code: 'bn', name: 'Bengali' },
  { code: 'pl', name: 'Polish' },
  { code: 'uk', name: 'Ukrainian' },
  { code: 'tr', name: 'Turkish' },
  { code: 'vi', name: 'Vietnamese' },
  { code: 'th', name: 'Thai' },
  { code: 'nl', name: 'Dutch' },
  { code: 'sv', name: 'Swedish' },
  // ... add 30 more for total 50+
] as const;

export const EMOTION_CATEGORIES = [
  'lonely',
  'happy',
  'excited',
  'sad',
  'anxious',
  'calm',
  'romantic',
  'playful',
] as const;

export const ECHO_CHIP_PRICES = {
  small: { chips: 50, price: 0.99 },
  medium: { chips: 150, price: 2.49 },
  large: { chips: 500, price: 6.99 },
  mega: { chips: 1500, price: 17.99 },
} as const;

export const SUBSCRIPTION_PRICES = {
  premium: { monthly: 9.99, yearly: 79.99 },
  vip: { monthly: 19.99, yearly: 159.99 },
} as const;
