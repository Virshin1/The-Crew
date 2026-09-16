import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore as getFirestoreSdk } from 'firebase-admin/firestore';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

let firestoreInstance = null;
let isInitialized = false;

/**
 * Initialize Firebase Admin SDK
 * Tries the following sources in order:
 * 1. Explicit path in process.env.FIREBASE_SERVICE_ACCOUNT_KEY
 * 2. Default local file: backend/serviceAccountKey.json
 * 3. Environment variable FIREBASE_CONFIG or GOOGLE_APPLICATION_CREDENTIALS
 * 4. Emulator if FIRESTORE_EMULATOR_HOST is set
 * 5. Default credentials
 */
export function initFirebase() {
  if (isInitialized) {
    return firestoreInstance;
  }

  try {
    const customKeyPath = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
    const defaultKeyPath = path.join(__dirname, '../serviceAccountKey.json');

    const keyPath = customKeyPath && fs.existsSync(customKeyPath)
      ? customKeyPath
      : fs.existsSync(defaultKeyPath)
        ? defaultKeyPath
        : null;

    if (keyPath) {
      const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
      initializeApp({
        credential: cert(serviceAccount),
      });
      console.log(`🔥 Firebase Admin initialized with service account: ${path.basename(keyPath)} (${serviceAccount.project_id})`);
    } else if (process.env.FIRESTORE_EMULATOR_HOST) {
      initializeApp({
        projectId: process.env.FIREBASE_PROJECT_ID || 'the-crew-dev',
      });
      console.log(`🔥 Firebase Admin initialized with Firestore Emulator (${process.env.FIRESTORE_EMULATOR_HOST})`);
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS || process.env.FIREBASE_CONFIG) {
      initializeApp({
        credential: applicationDefault(),
      });
      console.log('🔥 Firebase Admin initialized with Application Default Credentials');
    } else {
      console.warn('⚠️ No Firebase serviceAccountKey.json found and no credentials environment variable configured.');
      return null;
    }

    firestoreInstance = getFirestoreSdk();
    // Configure settings for optimal latency
    firestoreInstance.settings({ ignoreUndefinedProperties: true });
    isInitialized = true;
    return firestoreInstance;
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Admin:', error.message);
    return null;
  }
}

export function getFirestore() {
  if (!firestoreInstance) {
    return initFirebase();
  }
  return firestoreInstance;
}

export function isFirebaseReady() {
  return firestoreInstance !== null;
}

export default getFirestore;

