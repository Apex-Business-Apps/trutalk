import { z } from 'zod';

// Validation schemas using Zod
export const phoneNumberSchema = z.string().regex(/^\+[1-9]\d{1,14}$/, 'Invalid phone number format');

export const verifyPhoneSchema = z.object({
  phone_number: phoneNumberSchema,
  verification_code: z.string().length(6).optional(),
});

export const transcribeSchema = z.object({
  voice_clip_id: z.string().uuid(),
  audio_url: z.string().url(),
});

export const vectorizeSchema = z.object({
  voice_clip_id: z.string().uuid(),
  transcription: z.string().min(1).max(5000),
});

export const findMatchSchema = z.object({
  user_id: z.string().uuid(),
  voice_clip_id: z.string().uuid(),
});

export const startCallSchema = z.object({
  match_id: z.string().uuid(),
  user_id: z.string().uuid(),
});

export const createEchoSchema = z.object({
  call_id: z.string().uuid(),
  user_id: z.string().uuid(),
  summary: z.string().min(1).max(100),
  full_transcript: z.string().optional(),
});

export const createForumPostSchema = z.object({
  user_id: z.string().uuid(),
  title: z.string().min(5).max(200),
  body: z.string().min(10).max(10000),
  category: z.enum(['tips', 'stories', 'support', 'feedback']),
});

export const updateUserProfileSchema = z.object({
  display_name: z.string().min(2).max(50).optional(),
  bio: z.string().max(500).optional(),
  age: z.number().int().min(18).max(120).optional(),
  gender: z.enum(['male', 'female', 'non-binary', 'other']).optional(),
  preferred_languages: z.array(z.string()).min(1).optional(),
});
