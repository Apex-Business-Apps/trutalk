module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/packages', '<rootDir>/apps'],
  testMatch: ['**/__tests__/**/*.test.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'packages/**/src/**/*.ts',
    'apps/**/src/**/*.ts',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/dist/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  moduleNameMapper: {
    '^@trutalk/shared/(.*)$': '<rootDir>/packages/shared/src/$1',
    '^@trutalk/backend/(.*)$': '<rootDir>/packages/backend/src/$1',
    '^@trutalk/ai/(.*)$': '<rootDir>/packages/ai/src/$1',
  },
};
