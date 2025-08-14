// backend/src/index.js
import express from "express";
import cors from "cors";
import { config } from "dotenv";
config();

import { waitForDb } from "./db.js";

const app = express();
app.use(cors());
app.use(express.json());

/** ---------- Age calculation ---------- */
export function calculateAge(dobISO, now = new Date()) {
  const dob = new Date(dobISO);
  if (Number.isNaN(dob.getTime())) throw new Error("Invalid DOB");
  let years = now.getFullYear() - dob.getFullYear();
  let months = now.getMonth() - dob.getMonth();
  let days = now.getDate() - dob.getDate();

  if (days < 0) {
    const prevMonthDays = new Date(now.getFullYear(), now.getMonth(), 0).getDate();
    days += prevMonthDays;
    months -= 1;
  }
  if (months < 0) {
    months += 12;
    years -= 1;
  }

  const diffMs = now - dob;
  const totalDays = Math.floor(diffMs / 86400000);
  const totalHours = Math.floor(diffMs / 3600000);
  const totalMinutes = Math.floor(diffMs / 60000);
  const totalSeconds = Math.floor(diffMs / 1000);

  return { years, months, days, totalDays, totalHours, totalMinutes, totalSeconds };
}

/** ---------- BMI calculation ---------- */
export function computeBmi(weightKg, heightCm) {
  const w = Number(weightKg);
  const h = Number(heightCm);
  if (!w || !h || w <= 0 || h <= 0) return { bmi: null, category: null };

  const m = h / 100;
  const bmi = +(w / (m * m)).toFixed(2);

  let category;
  if (bmi < 18.5) category = "Underweight";
  else if (bmi < 25) category = "Normal";
  else if (bmi < 30) category = "Overweight";
  else category = "Obese";

  return { bmi, category };
}

/** ---------- Health ---------- */
app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", time: new Date().toISOString() });
});

/** ---------- DB pool (pre-warm, non-blocking) ---------- */
let poolPromise = null;
if (process.env.NODE_ENV !== "test") {
  poolPromise = waitForDb().catch((e) => {
    console.error("DB warmup failed:", e.message);
    return null;
  });
}

/** ---------- Calculate + (async) persist ---------- */
app.post("/api/calc", async (req, res) => {
  try {
    const { name = "Guest", dob, weightKg, heightCm } = req.body || {};
    const age = calculateAge(dob);
    const { bmi, category } = computeBmi(weightKg, heightCm);

    // respond immediately — no DB await
    res.json({ name, dob, weightKg, heightCm, ...age, bmi, bmiCategory: category });

    // fire-and-forget persistence (does not block response)
    if (process.env.NODE_ENV !== "test" && poolPromise) {
      (async () => {
        try {
          const pool = await poolPromise;
          if (!pool) return;
          await pool.query(
            `INSERT INTO age_events
             (name, dob, years, months, days, weight_kg, height_cm, bmi, bmi_category)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [name, dob, age.years, age.months, age.days, weightKg ?? null, heightCm ?? null, bmi ?? null, category ?? null]
          );
        } catch (dbErr) {
          console.error("DB insert failed:", dbErr.message);
        }
      })();
    }
  } catch (err) {
    res.status(400).json({ error: err.message || "Bad Request" });
  }
});

/** ---------- Recent history (await OK here) ---------- */
app.get("/api/calc", async (_req, res) => {
  try {
    if (process.env.NODE_ENV === "test") return res.json([]);
    const pool = poolPromise ? await poolPromise : null;
    if (!pool) return res.json([]);
    const [rows] = await pool.query(
      `SELECT id, name, dob, years, months, days, weight_kg, height_cm, bmi, bmi_category, calculated_at
       FROM age_events ORDER BY calculated_at DESC LIMIT 10`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: "DB error" });
  }
});

const port = process.env.APP_PORT || 3000;
if (process.env.NODE_ENV !== "test") {
  app.listen(port, () => console.log(`API listening on ${port}`));
}

export default app;
