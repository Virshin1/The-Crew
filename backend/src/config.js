import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const PORT = process.env.PORT || 3000;
export const JWT_SECRET = process.env.JWT_SECRET || 'the_crew_super_secret_cyberpunk_jwt_key_2026';
export const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../database.sqlite');
export const DB_DRIVER = process.env.DB_DRIVER || 'sqlite';
export const FIREBASE_SERVICE_ACCOUNT_KEY = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || path.join(__dirname, '../serviceAccountKey.json');
export const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
