# verify-frontend

[![Build Status](https://travis-ci.org/alphagov/verify-frontend.svg?branch=master)](https://travis-ci.org/alphagov/verify-frontend)

A new frontend for GOV.UK Verify

## Installing the application

Once you’ve cloned this then `bundle` will install the requirements.

## Running the application

`./startup.sh`

This will start the server running on http://localhost:50300/ .

Without cookies this won’t do much; for the time being you’ll need to start a journey on the existing system until you get to the old frontend’s start page. This will give you the cookies you need for localhost.

If you don’t have ida-sample-rp running you can get to the start page on the new frontend by visiting http://localhost:50300/test-saml and clicking on saml-post.

## Running the tests

`./pre-commit.sh`

This will (lint the application code)[https://github.com/alphagov/govuk-lint] and run the tests.
