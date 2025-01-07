import eslint from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';
import tseslint from 'typescript-eslint';

export default [
    eslint.configs.recommended,
    ...tseslint.configs.strictTypeChecked,
    ...tseslint.configs.stylisticTypeChecked,
    {
        ignores: ["app/assets/builds/*", "bun.config.js"]
    },
    {
        plugins: {
            '@stylistic': stylistic
        },
        languageOptions: {
            parserOptions: {
                project: true
            }
        },
    },
    // ESLint
    {
        rules: {}
    },
    // TypeScript
    {
        rules: {}
    },
    // Stylistic
    {
        rules: {}
    }
];