import request from "supertest";
import app, { calculateAge, computeBmi } from "../src/index.js";

process.env.NODE_ENV = "test";

test("GET /api/health returns ok", async () => {
  const res = await request(app).get("/api/health");
  expect(res.status).toBe(200);
  expect(res.body.status).toBe("ok");
  expect(res.body.time).toBeDefined();
});

test("POST /api/calc returns age + bmi fields", async () => {
  const payload = { name: "Sumanth", dob: "2001-03-06", heightCm: 175, weightKg: 72 };
  const res = await request(app).post("/api/calc").send(payload);
  expect(res.status).toBe(200);
  expect(res.body.name).toBe("Sumanth");
  expect(res.body.dob).toBe("2001-03-06");
  expect(res.body).toHaveProperty("years");
  expect(res.body).toHaveProperty("months");
  expect(res.body).toHaveProperty("days");
  expect(res.body).toHaveProperty("bmi");
  expect(res.body).toHaveProperty("bmiCategory");
});

test("utils compute without HTTP", () => {
  const a = calculateAge("1998-02-01", new Date("2025-02-10T00:00:00Z"));
  expect(a.years).toBe(27);
  expect(a.months).toBe(0);
  expect(a.days).toBe(9);

  const { bmi, category } = computeBmi(85, 158);
  // Your BMI function returns ~34.05 for 85kg/158cm; assert accordingly
  expect(bmi).toBeCloseTo(34.05, 2);
  expect(category).toBe("Obese");
});
