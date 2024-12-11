module.exports = [
  {
    languageOptions: {
      ecmaVersion: 'latest'
    },
    plugins: {
      prettier: require('eslint-plugin-prettier')
    },
    rules: {
      'prettier/prettier': [
        'warn',
        {
          singleQuote: true,
          tabWidth: 2,
          trailingComma: 'none',
          maxLineLength: 120
        }
      ]
    }
  }
];
