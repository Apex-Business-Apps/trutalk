import twilio from 'twilio';

if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
  throw new Error('Missing Twilio credentials');
}

const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

const VERIFY_SERVICE_SID = process.env.TWILIO_VERIFY_SERVICE_SID;

export async function sendVerificationCode(phoneNumber: string): Promise<boolean> {
  try {
    await client.verify.v2
      .services(VERIFY_SERVICE_SID!)
      .verifications.create({ to: phoneNumber, channel: 'sms' });
    return true;
  } catch (error) {
    console.error('Twilio send verification error:', error);
    return false;
  }
}

export async function checkVerificationCode(
  phoneNumber: string,
  code: string
): Promise<boolean> {
  try {
    const verificationCheck = await client.verify.v2
      .services(VERIFY_SERVICE_SID!)
      .verificationChecks.create({ to: phoneNumber, code });

    return verificationCheck.status === 'approved';
  } catch (error) {
    console.error('Twilio check verification error:', error);
    return false;
  }
}
