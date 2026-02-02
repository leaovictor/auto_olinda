
import * as functions from 'firebase-functions';

export const successResponse = (data: any) => {
  return { success: true, data };
};

export const errorResponse = (code: functions.https.FunctionsErrorCode, message: string, details?: any) => {
  throw new functions.https.HttpsError(code, message, details);
};
