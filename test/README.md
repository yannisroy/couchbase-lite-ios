How to run these tests:

First edit `config.js` to point to your build of LiteServ (found via "Products" in Xcode).
Then cd into this directory (`test`).

Get the dependencies with `npm install`. (It reads `package.json` to know what to get.)

Make a tmp directory `mkdir tmp`

Run the tests with `npm test`.

To run a particular test, try `node phalanx-test.js`

NPM test will pick up any file that matches `*-test.js`.
