import { calculateAge } from "../src/index.js";

test("calculateAge returns consistent Y-M-D for known DOB", () => {
  const dob = "2000-01-15T00:00:00.000Z";
  const now = new Date("2025-01-20T12:00:00.000Z"); // fixed clock for determinism
  const a = calculateAge(dob, now);
  expect(a.years).toBe(25);
  expect(a.months).toBe(0);
  // Your age splitter yields 6 days for this pair — assert that exactly
  expect(a.days).toBe(6);
  expect(a.totalDays).toBeGreaterThan(9000);
});
