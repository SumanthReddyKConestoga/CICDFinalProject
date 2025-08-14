// backend/src/db.js
import mysql from "mysql2/promise";

const {
  DB_HOST = "db",
  DB_USER = "appuser",
  DB_PASSWORD = "Secret123!",
  DB_NAME = "appdb",
} = process.env;

export async function createPool() {
  return mysql.createPool({
    host: DB_HOST,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  });
}

async function columnExists(pool, column) {
  const [rows] = await pool.query(
    `SELECT COUNT(*) AS cnt
       FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = ?
        AND TABLE_NAME   = 'age_events'
        AND COLUMN_NAME  = ?`,
    [DB_NAME, column]
  );
  return Number(rows?.[0]?.cnt) > 0;
}

async function ensureColumn(pool, column, ddl) {
  if (!(await columnExists(pool, column))) {
    await pool.query(`ALTER TABLE age_events ADD COLUMN ${ddl}`);
  }
}

export async function initSchema(pool) {
  // base table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS age_events (
      id INT PRIMARY KEY AUTO_INCREMENT,
      name VARCHAR(100) NOT NULL,
      dob DATE NOT NULL,
      years INT NOT NULL,
      months INT NOT NULL,
      days INT NOT NULL,
      calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // add BMI columns only if missing (compatible with older MySQL)
  await ensureColumn(pool, "weight_kg", "weight_kg DECIMAL(6,2) NULL");
  await ensureColumn(pool, "height_cm", "height_cm DECIMAL(6,2) NULL");
  await ensureColumn(pool, "bmi", "bmi DECIMAL(6,2) NULL");
  await ensureColumn(pool, "bmi_category", "bmi_category VARCHAR(32) NULL");
}

/** Wait for DB and ensure schema */
export async function waitForDb(maxTries = 20, delayMs = 3000) {
  let lastErr;
  for (let i = 1; i <= maxTries; i++) {
    try {
      const pool = await createPool();
      await initSchema(pool);
      return pool;
    } catch (err) {
      lastErr = err;
      await new Promise((r) => setTimeout(r, delayMs));
    }
  }
  throw lastErr;
}
