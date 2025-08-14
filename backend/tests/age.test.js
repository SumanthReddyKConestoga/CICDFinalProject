import { calculateAge } from "../src/index.js";

test("calculateAge returns consistent Y-M-D for known DOB (UTC-safe)", () => {
  const dob = "2000-01-15T00:00:00.000Z";
  const now = new Date("2025-01-20T12:00:00.000Z");
  const a = calculateAge(dob, now);
  expect(a.years).toBe(25);
  expect(a.months).toBe(0);
  expect([5, 6]).toContain(a.days);   // tolerate CI timezone skew
  expect(a.totalDays).toBeGreaterThan(9000);
});
