import js from "@eslint/js";
import stylistic from '@stylistic/eslint-plugin';

export default [
    js.configs.recommended,
    {
        ignores: ["app/assets/builds/*"]
    },
    {
        plugins: {
          '@stylistic': stylistic
        },
        rules: {
            "no-unused-vars": "warn",
            "no-undef": "warn"
        }
    },
    {
        files: ["bun.config.js"],
        rules: {
            "no-undef": "off"
        }
    }
];

//
// Switch to the below configuration when moving to TypeScript.
//

// import eslint from '@eslint/js';
// import stylistic from '@stylistic/eslint-plugin';
// import tseslint from 'typescript-eslint';
// 
// export default eslint.config(
    // eslint.configs.recommended,
    // ...tseslint.configs.strictTypeChecked,
    // ...tseslint.configs.stylisticTypeChecked,
    // {
        // plugins: {
            // '@stylistic': stylistic
        // },
        // languageOptions: {
            // parserOptions: {
                // project: true
            // }
        // },
        // ESLint
        // rules: {}
    // },
    // TypeScript
    // {
        // rules: {}
    // },
    // Stylistic
    // {
        // rules: {}
    // }
// );