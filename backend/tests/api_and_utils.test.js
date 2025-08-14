import request from "supertest";
import app, { sum, isPositive } from "../src/index.js";

describe("API /api/health", () => {
  test("returns 200", async () => {
    const res = await request(app).get("/api/health");
    expect(res.statusCode).toBe(200);
  });

  test("returns status and time", async () => {
    const res = await request(app).get("/api/health");
    expect(res.body).toHaveProperty("status", "ok");
    expect(res.body).toHaveProperty("time");
  });
});

describe("API /api/echo/:msg", () => {
  test("echoes path param", async () => {
    const res = await request(app).get("/api/echo/hello");
    expect(res.body).toEqual({ echo: "hello" });
  });
});

describe("utils", () => {
  test("sum adds numbers", () => {
    expect(sum(2, 3)).toBe(5);
  });
  test("isPositive detects positives", () => {
    expect(isPositive(7)).toBe(true);
    expect(isPositive(-1)).toBe(false);
  });
});
