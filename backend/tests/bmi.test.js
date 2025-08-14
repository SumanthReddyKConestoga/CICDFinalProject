import { computeBmi } from "../src/index.js";

test("BMI categorization — normal", () => {
  const { bmi, category } = computeBmi(70, 175);
  expect(bmi).toBeCloseTo(22.86, 2);
  expect(category).toBe("Normal");
});

test("BMI categorization — obese", () => {
  const { bmi, category } = computeBmi(120, 170);
  expect(bmi).toBeCloseTo(41.52, 2);
  expect(category).toBe("Obese");
});
