// pnpm dlx @antfu/eslint-config@latest

const { antfu } = require('@antfu/eslint-config');

module.exports = antfu({
  formatters: true,
}, {
  rules: {
    'style/semi': ['error', 'always'],
    'style/brace-style': ['error', '1tbs'],
    'no-console': 'off',
    'unicorn/prefer-node-protocol': 'off',
    'node/prefer-global/process': 'off',
  },
});
