import eslint from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';
import tseslint from 'typescript-eslint';

export default [
    eslint.configs.recommended,
    ...tseslint.configs.strictTypeChecked,
    ...tseslint.configs.stylisticTypeChecked,
    {
        ignores: [
            "app/assets/builds/**",
            "app/views/pwa/**",
            "*.js"
        ]
    },
    {
        plugins: {
            '@stylistic': stylistic
        },
        languageOptions: {
            parserOptions: {
                project: true,
            }
        },
    },
    // ESLint
    {
        files: ["app/javascript/**.js"],
        rules: {}
    },
    // TypeScript
    {
        files: ["app/javascript/**.ts"],
        rules: {}
    },
    // Stylistic
    {
        rules: {}
    },
    {
        files: [
            "spec/javascript/**/*"
        ],
        rules: {
            '@typescript-eslint/no-unsafe-call': 'off',
            '@typescript-eslint/no-unsafe-member-access': 'off',
            '@typescript-eslint/no-unsafe-assignment': 'off'
        }
    }
];