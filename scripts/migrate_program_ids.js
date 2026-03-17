/**
 * Migration Script: Backfill programId on existing participant user documents
 *
 * What it does:
 *  1. Reads all documents in the `programs` collection and builds a map of
 *     known subsidy strings → programId (Firestore doc ID).
 *  2. Reads all participant user documents (those with role == 'participant'
 *     or that have an initialReportId).
 *  3. For each participant, reads their `initialReports` document to get the
 *     saved `subsidy` string.
 *  4. Matches that string to a program doc ID using the map.
 *  5. Writes `programId` back to the user document.
 *
 * Usage:
 *   1. Place your Firebase service account JSON at the path below.
 *   2. Run: node scripts/migrate_program_ids.js
 */

const admin = require('firebase-admin');

// ─── CONFIGURE THIS ────────────────────────────────────────────────────────────
const SERVICE_ACCOUNT_PATH = './serviceAccount.json'; // path to your service account key
// ───────────────────────────────────────────────────────────────────────────────

const serviceAccount = require(SERVICE_ACCOUNT_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function main() {
  console.log('Starting programId migration...\n');

  // ── Step 1: Load programs and map each code → programId ─────────────────────
  const programsSnap = await db.collection('programs').get();

  /**
   * Known subsidy strings stored in existing initialReports (from hardcoded list).
   * The script matches by checking if the stored subsidy STARTS WITH the program code.
   * This is reliable because all old values begin with the code prefix.
   */
  /** @type {Map<string, string>} key = code (lowercase), value = programId */
  const codeToId = new Map();

  programsSnap.forEach((doc) => {
    const code = (doc.data().code ?? '').toLowerCase().trim();
    if (code) {
      codeToId.set(code, doc.id);
      console.log(`  Program: [${doc.id}] code="${code}"`);
    }
  });

  console.log(`\nLoaded ${codeToId.size} programs.\n`);

  /**
   * resolveMatch: Given a raw subsidy string, find the matching programId
   * by checking if the subsidy string starts with any known code prefix.
   */
  function resolveMatch(subsidyRaw) {
    const s = subsidyRaw.toLowerCase().trim();
    for (const [code, id] of codeToId.entries()) {
      // Match: subsidy starts with the code (handles both "_" and " -" separators)
      if (s.startsWith(code)) return id;
    }
    return null;
  }

  // ── Step 2: Get all users that have an initialReportId set ──────────────────
  const usersSnap = await db
    .collection('users')
    .where('initialReportId', '!=', null)
    .get();

  console.log(`Found ${usersSnap.size} users with an initial report.\n`);

  let updated = 0;
  let skipped = 0;
  let noMatch = 0;

  for (const userDoc of usersSnap.docs) {
    const userData = userDoc.data();
    const userId = userDoc.id;

    // Skip if already has a programId
    if (userData.programId) {
      console.log(`  SKIP [${userId}] — already has programId: ${userData.programId}`);
      skipped++;
      continue;
    }

    const initialReportId = userData.initialReportId;
    if (!initialReportId) {
      skipped++;
      continue;
    }

    // ── Step 3: Read the initialReport to get the subsidy string ───────────────
    const reportDoc = await db.collection('initialReports').doc(initialReportId).get();
    if (!reportDoc.exists) {
      console.log(`  WARN [${userId}] — initialReport not found: ${initialReportId}`);
      skipped++;
      continue;
    }

    const subsidyRaw = (reportDoc.data().subsidy ?? '').toLowerCase().trim();
    if (!subsidyRaw) {
      console.log(`  WARN [${userId}] — empty subsidy field in report`);
      skipped++;
      continue;
    }

    // ── Step 4: Match subsidy string to a programId ────────────────────────────
    let matchedProgramId = null;

    // Try direct match first
    if (subsidyToId.has(subsidyRaw)) {
      matchedProgramId = subsidyToId.get(subsidyRaw);
    } else {
      // Try partial match — check if the subsidy contains any known code
      for (const [key, id] of subsidyToId.entries()) {
        if (subsidyRaw.includes(key) || key.includes(subsidyRaw)) {
          matchedProgramId = id;
          break;
        }
      }
    }

    if (!matchedProgramId) {
      console.log(`  NO MATCH [${userId}] — subsidy: "${subsidyRaw.slice(0, 60)}..."`);
      noMatch++;
      continue;
    }

    // ── Step 5: Write programId back to the user document ─────────────────────
    await db.collection('users').doc(userId).update({ programId: matchedProgramId });
    console.log(`  UPDATED [${userId}] → programId: ${matchedProgramId}`);
    updated++;
  }

  console.log('\n──────────────────────────────────────');
  console.log(`Migration complete:`);
  console.log(`  ✅ Updated : ${updated}`);
  console.log(`  ⏭  Skipped : ${skipped}`);
  console.log(`  ❌ No match: ${noMatch}`);
  console.log('──────────────────────────────────────\n');
}

main().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
