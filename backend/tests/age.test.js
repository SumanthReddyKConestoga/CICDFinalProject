// backend/tests/age.test.js
import { calculateAge } from "../src/index.js";

test("calculateAge for a known DOB", () => {
  const now = new Date("2025-08-14T00:00:00Z");
  const { years, months } = calculateAge("2000-08-14", now);
  expect(years).toBe(25);
  expect(months).toBe(0);
});

test("rejects invalid DOB", () => {
  expect(() => calculateAge("not-a-date")).toThrow();
});
