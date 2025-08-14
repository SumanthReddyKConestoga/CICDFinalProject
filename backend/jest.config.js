export default {
  testEnvironment: "node",
  transform: {},
  collectCoverage: true,
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov"],
  roots: ["<rootDir>/tests"],
};
