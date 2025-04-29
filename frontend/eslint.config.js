import babelParser from '@babel/eslint-parser';

export default [
  {
    files: ['**/*.{js,ts,vue}'],
    languageOptions: {
      parser: babelParser,
      parserOptions: {
        requireConfigFile: false,
        babelOptions: {
          presets: ['@babel/preset-env'],
        },
      },
    },
    rules: {
      'semi': ['error', 'always'],  // セミコロンを必須に
      'quotes': ['error', 'single'],  // シングルクォートを必須に
    },
  },
];
