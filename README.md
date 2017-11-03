# verify-frontend

[![Build Status](https://travis-ci.org/alphagov/verify-frontend.svg?branch=master)](https://travis-ci.org/alphagov/verify-frontend)

The frontend for GOV.UK Verify

## Installing the application

Once you’ve cloned this then `bundle` will install the requirements.

## Running the application

You can start the application without having any of the closed source components installed with:

`./startup.sh --stub-api`

This will start the frontend server running on http://localhost:50300/ and a stubbed API server on http://localhost:50199.

To start a journey on the front end visit http://localhost:50300/test-saml and click `saml-post`.

If you're on the Verify team and have the rest of the federation running locally you should omit the `--stub-api` argument
and start your journey from the test-rp.

## Running the tests

`./pre-commit.sh`

This will [lint the application code](https://github.com/alphagov/govuk-lint) and run the tests.

If you need to run the javascript-enabled tests that require Firefox, you will need to have Firefox 47.0.1 installed.
No other version of Firefox will do. The Managed Software Centre will constantly try and upgrade Firefox to an incompatible version.
To get around this:

1. Install [version 47.0.1](https://ftp.mozilla.org/pub/firefox/releases/47.0.1/mac/en-GB/Firefox%2047.0.1.dmg) somewhere (not your Applications directory!).
2. Export the `FIREFOX_PATH` environment variable somewhere (like your `.bashrc`):

    `export FIREFOX_PATH=/path/to/old/Firefox.app/Contents/MacOS/firefox-bin`

3. Run the tests again. They should use the old version of Firefox and pass.

## Editing .travis.yml

If you plan to edit this file please enable the pre-commit check which lints it, preventing mistakes.
To do so, first install [pre-commit](http://pre-commit.com) and then run `pre-commit install`.
On an OSX system this amounts to:

```bash
brew install pre-commit
pre-commit install
```