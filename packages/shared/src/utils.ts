// Shared utility functions

export function calculateSimilarity(vector1: number[], vector2: number[]): number {
  // Cosine similarity
  const dotProduct = vector1.reduce((sum, val, i) => sum + val * vector2[i], 0);
  const magnitude1 = Math.sqrt(vector1.reduce((sum, val) => sum + val * val, 0));
  const magnitude2 = Math.sqrt(vector2.reduce((sum, val) => sum + val * val, 0));
  return dotProduct / (magnitude1 * magnitude2);
}

export function generateEchoSummary(transcript: string, maxWords: number = 5): string {
  // Simple implementation - in production, use GPT-4
  const words = transcript.split(' ').slice(0, maxWords);
  return words.join(' ');
}

export function formatDuration(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

export function isStreakActive(lastCallDate: string | null): boolean {
  if (!lastCallDate) return false;
  const last = new Date(lastCallDate);
  const today = new Date();
  const diffDays = Math.floor((today.getTime() - last.getTime()) / (1000 * 60 * 60 * 24));
  return diffDays <= 1;
}

export function calculateLTV(
  totalCalls: number,
  subscriptionTier: string,
  accountAgeMonths: number
): number {
  // Simple LTV calculation
  const callValue = 0.5; // Average revenue per call
  const subscriptionValue = subscriptionTier === 'premium' ? 9.99 : subscriptionTier === 'vip' ? 19.99 : 0;
  const monthlyValue = callValue * (totalCalls / Math.max(accountAgeMonths, 1)) + subscriptionValue;
  const avgLifetimeMonths = 18; // Assumption
  return monthlyValue * avgLifetimeMonths;
}

export function generateReferralCode(userId: string): string {
  // Generate unique 8-character referral code
  return Buffer.from(userId).toString('base64').slice(0, 8).toUpperCase();
}

export function maskPhoneNumber(phoneNumber: string): string {
  // +1234567890 -> +1234***890
  if (phoneNumber.length < 8) return phoneNumber;
  return phoneNumber.slice(0, -6) + '***' + phoneNumber.slice(-3);
}

export function detectLanguageFromCode(languageCode: string): string {
  const languageMap: Record<string, string> = {
    en: 'English',
    es: 'Spanish',
    fr: 'French',
    de: 'German',
    it: 'Italian',
    pt: 'Portuguese',
    ru: 'Russian',
    ja: 'Japanese',
    ko: 'Korean',
    zh: 'Chinese',
    ar: 'Arabic',
    hi: 'Hindi',
    // Add more as needed
  };
  return languageMap[languageCode] || languageCode;
}

export class APIError extends Error {
  constructor(public statusCode: number, message: string, public code?: string) {
    super(message);
    this.name = 'APIError';
  }
}

export function createErrorResponse(error: unknown) {
  if (error instanceof APIError) {
    return {
      success: false,
      error: error.message,
      code: error.code,
      statusCode: error.statusCode,
    };
  }
  return {
    success: false,
    error: 'Internal server error',
    statusCode: 500,
  };
}
