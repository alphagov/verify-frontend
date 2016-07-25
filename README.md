# verify-frontend

[![Build Status](https://travis-ci.org/alphagov/verify-frontend.svg?branch=master)](https://travis-ci.org/alphagov/verify-frontend)

A new frontend for GOV.UK Verify

## Installing the application

Once you’ve cloned this then `bundle` will install the requirements.

## Running the application

You can start the application without having any of the closed source components installed with:

`./startup.sh --stub-api`

This will start the frontend server running on http://localhost:50300/ and a stubbed API server on http://localhost:50190.

To start a journey on the front end visit http://localhost:50300/test-saml and click `saml-post`.

If you're on the Verify team and have the rest of the federation running locally you should omit the `--stub-api` argument
and start your journey from the test-rp.

## Running the tests

`./pre-commit.sh`

This will [lint the application code](https://github.com/alphagov/govuk-lint) and run the tests.
