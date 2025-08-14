import { computeBmi } from "../src/index.js";

test("BMI categories", () => {
  expect(computeBmi(50, 170).category).toBe("Underweight"); // 17.3
  expect(computeBmi(65, 170).category).toBe("Normal");      // 22.5
  expect(computeBmi(80, 170).category).toBe("Overweight");  // 27.7
  expect(computeBmi(100, 170).category).toBe("Obese");      // 34.6
});
