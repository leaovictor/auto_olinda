import { HttpsError, FunctionsErrorCode } from 'firebase-functions/v2/https';

export const successResponse = (data: any) => {
  return { success: true, data };
};

export const errorResponse = (code: FunctionsErrorCode, message: string, details?: any) => {
  throw new HttpsError(code, message, details);
};
