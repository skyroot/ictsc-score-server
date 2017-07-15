module.exports = {
  root: true,
  parser: 'babel-eslint',
  parserOptions: {
    sourceType: 'module'
  },
  // https://github.com/feross/standard/blob/master/RULES.md#javascript-standard-style
  extends: 'standard',
  // required to lint *.vue files
  plugins: [
    'html'
  ],
  // add your custom rules here
  'rules': {
    // allow paren-less arrow functions
    'arrow-parens': 0,
    // allow async-await
    'generator-star-spacing': 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    'semi': 0,
    'comma-dangle': 0,
    'no-multiple-empty-lines': 0,
    'quotes': 1,
    'no-unused-vars': 1,
    'no-throw-literal': 0,
    'camelcase': 0,
  },

  "env": {
    "jasmine": true
  },
  "globals": {
  },
}