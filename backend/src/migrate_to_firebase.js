#!/usr/bin/env node
import Database from 'better-sqlite3';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { initFirebase, getFirestore } from './firebase.js';
import { DB_PATH } from './config.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const isDryRun = process.argv.includes('--dry-run');

console.log('====================================================');
console.log('🚀 The Crew: SQLite to Firebase Firestore Migrator');
console.log('====================================================');
if (isDryRun) {
  console.log('ℹ️  Running in DRY-RUN mode. No changes will be written to Firebase.\n');
}

// 1. Check SQLite DB
if (!fs.existsSync(DB_PATH)) {
  console.error(`❌ SQLite database not found at ${DB_PATH}`);
  console.error('Please start the server first or run `npm run seed` to generate the initial database.');
  process.exit(1);
}

const sqlite = new Database(DB_PATH, { readonly: true });

// 2. Read SQLite records
const tables = [
  'users',
  'servers',
  'server_members',
  'channels',
  'messages',
  'reactions',
  'direct_messages',
  'notifications',
  'voice_participants',
];

const counts = {};
const records = {};

for (const table of tables) {
  try {
    const rows = sqlite.prepare(`SELECT * FROM ${table}`).all();
    records[table] = rows;
    counts[table] = rows.length;
    console.log(`📦 Found ${rows.length.toString().padStart(4, ' ')} records in table "${table}"`);
  } catch (err) {
    records[table] = [];
    counts[table] = 0;
    console.warn(`⚠️ Table "${table}" could not be read: ${err.message}`);
  }
}

console.log('\n📊 Total records to migrate:', Object.values(counts).reduce((a, b) => a + b, 0));

if (isDryRun) {
  console.log('\n✅ Dry run completed successfully! All SQLite records read and validated.');
  console.log('To migrate these records into Firebase, provide your serviceAccountKey.json and run:');
  console.log('  node src/migrate_to_firebase.js\n');
  process.exit(0);
}

// 3. Connect to Firebase
console.log('\nConnecting to Firebase Firestore...');
const firestore = initFirebase();

if (!firestore) {
  console.error('\n❌ Could not connect to Firebase Firestore.');
  console.error('Please ensure one of the following:');
  console.error('  1. Place your `serviceAccountKey.json` into the `backend/` directory.');
  console.error('  2. Set `FIREBASE_SERVICE_ACCOUNT_KEY=/path/to/serviceAccountKey.json` in your environment.');
  console.error('  3. Set `FIRESTORE_EMULATOR_HOST=localhost:8080` to migrate to local emulator.\n');
  process.exit(1);
}

// 4. Batch write to Firestore
async function migrate() {
  console.log('\nWriting records to Firestore collections...');

  async function batchCommit(collectionName, items, transformFn = item => item, getId = item => item.id) {
    if (!items || items.length === 0) return;

    const CHUNK_SIZE = 400; // Under Firestore 500 limit
    let migratedCount = 0;

    for (let i = 0; i < items.length; i += CHUNK_SIZE) {
      const chunk = items.slice(i, i + CHUNK_SIZE);
      const batch = firestore.batch();

      for (const item of chunk) {
        const id = String(getId(item));
        const docRef = firestore.collection(collectionName).doc(id);
        const data = transformFn({ ...item });
        delete data.id; // Don't duplicate id inside document fields if unnecessary
        batch.set(docRef, data, { merge: true });
      }

      await batch.commit();
      migratedCount += chunk.length;
      process.stdout.write(`  -> Migrated ${migratedCount}/${items.length} to "${collectionName}"\r`);
    }
    console.log(`  ✅ Successfully migrated ${items.length} documents to "${collectionName}"`);
  }

  // Users
  await batchCommit('users', records.users, u => ({
    ...u,
    username_lower: (u.username || '').toLowerCase(),
    email_lower: (u.email || '').toLowerCase(),
  }));

  // Servers
  await batchCommit('servers', records.servers, s => ({
    ...s,
    is_public: s.is_public === 1 || s.is_public === true,
  }));

  // Server Members
  await batchCommit('server_members', records.server_members);

  // Channels
  await batchCommit('channels', records.channels);

  // Messages
  await batchCommit('messages', records.messages, m => ({
    ...m,
    has_media: m.has_media === 1 || m.has_media === true,
  }));

  // Reactions
  await batchCommit('reactions', records.reactions);

  // Direct Messages
  await batchCommit('direct_messages', records.direct_messages, dm => ({
    ...dm,
    is_read: dm.is_read === 1 || dm.is_read === true,
  }));

  // Notifications
  await batchCommit('notifications', records.notifications, n => ({
    ...n,
    is_read: n.is_read === 1 || n.is_read === true,
  }));

  // Voice Participants
  await batchCommit(
    'voice_participants',
    records.voice_participants,
    vp => ({
      ...vp,
      is_speaking: Boolean(vp.is_speaking),
      is_muted: Boolean(vp.is_muted),
      is_streaming: Boolean(vp.is_streaming),
    }),
    vp => `${vp.channel_id}_${vp.user_id}`
  );

  console.log('\n🎉 ALL DATA MIGRATED TO FIREBASE FIRESTORE SUCCESSFULLY!\n');
}

migrate().catch(err => {
  console.error('\n❌ Migration failed with error:', err);
  process.exit(1);
});
