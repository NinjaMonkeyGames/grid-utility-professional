import js from "@eslint/js";
import tseslint from "typescript-eslint";
import eslintPluginJsonc from "eslint-plugin-jsonc";
import * as jsoncParser from "jsonc-eslint-parser";
import jsonSchemaValidator from "eslint-plugin-json-schema-validator";

export default [
  // Global ignore patterns
  {
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
      "**/.next/**"
    ]
  },

  // JavaScript Recommended Config
  js.configs.recommended,

  // TypeScript Recommended Configs
  ...tseslint.configs.recommended,

  // JSON / JSONC Recommended Configs
  ...eslintPluginJsonc.configs["flat/recommended-with-jsonc"],

  // Custom configuration for JSON/JSONC & Schema Validation
  {
    files: ["**/*.json", "**/*.jsonc"],
    languageOptions: {
      parser: jsoncParser
    },
    plugins: {
      "json-schema-validator": jsonSchemaValidator
    },
    rules: {
      "json-schema-validator/no-invalid": "error"
    }
  },

  // Turn off schema validation for package.json to prevent remote $ref resolution errors
  {
    files: ["**/package.json"],
    rules: {
      "json-schema-validator/no-invalid": "off"
    }
  },

  // Base JavaScript & TypeScript Custom Rules
  {
    files: ["**/*.js", "**/*.ts", "**/*.tsx"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        process: "readonly",
        console: "readonly",
        module: "readonly",
        require: "readonly",
        __dirname: "readonly",
        __filename: "readonly"
      }
    },
    rules: {
      "no-unused-vars": "off",
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
      "no-console": "off",
      "prefer-const": "error",
      "eqeqeq": ["error", "always"]
    }
  }
];