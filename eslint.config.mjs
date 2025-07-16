import common from "eslint-config-neon/common";
import node from "eslint-config-neon/node";
import prettier from "eslint-config-neon/prettier";
import typescript from "eslint-config-neon/typescript";

const config = [
  {
    ignores: ["eslint.config.mjs", "node_modules/**", "dist/**"],
  },
  ...common,
  ...node,
  ...typescript,
  {
    languageOptions: {
      parserOptions: {
        project: "./tsconfig.json",
      },
    },
  },
  ...prettier,
];

export default config;
