[![Build Status](https://travis-ci.com/alphagov/verify-frontend.svg?branch=master)](https://travis-ci.com/alphagov/verify-frontend)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2161f0de613c449dac77fbd77b8d9703)](https://www.codacy.com/app/alphagov/verify-frontend?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=alphagov/verify-frontend&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/2161f0de613c449dac77fbd77b8d9703)](https://www.codacy.com/app/alphagov/verify-frontend?utm_source=github.com&utm_medium=referral&utm_content=alphagov/verify-frontend&utm_campaign=Badge_Coverage)

# verify-frontend

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

If you need to run the javascript-enabled tests that require a browser, you will need to have Chrome installed. The stable release of Chrome should work.

## Editing .travis.yml

If you plan to edit this file please enable the pre-commit check which lints it, preventing mistakes.
To do so, first install [pre-commit](http://pre-commit.com) and then run `pre-commit install`.
On an OSX system this amounts to:

```bash
brew install pre-commit
pre-commit install
```

## Deploying the application
The application is deployed using our [CI/CD pipeline](https://deployer.tools.signin.service.gov.uk/teams/main/pipelines/deploy-verify-hub?groups=build-apps&groups=default). 
Any changes merged to master are automatically deployed. This repo has an active branch protection for `master`. Any changes need to be raised via PR and approved by two other developers.

## PR reviews
When a PR is raised, it's automatically tested using Travis (runs the ./pre-commit.sh script on the branch and against master) which is configured in the [.travis file](/.travis). The test results are shown directly on the PR. 

In addition to the Travis tests we have also enabled Codacy to check coding style. Again, the results are shown within the PR. Codacy is configured using the [.rubocop.yml file](/.rubocop.yml).

The PR is also deployed to Heroku as [a review app](https://devcenter.heroku.com/articles/github-integration-review-apps). The app is destroyed when the PR is closed/merged or after 5 days of inactivity. It uses docker to run both the Rails app and the stub API server. The Heroku deployment is configured using the 4 files:
* `Dockerfile.heroku` - to configure the docker image of frontend
* `heroku.yml` - Heroku [deployment manifest](https://devcenter.heroku.com/articles/build-docker-images-heroku-yml) 
* `app.json` - Heroku [application manifest](https://devcenter.heroku.com/articles/app-json-schema)
* `heroku-startup.sh` - startup script used to start the app and api, on the port supplied by Heroku

To view or rebuild a Heroku review app [sign into Heroku](https://id.heroku.com/login) using the credentials stored in `verify-blackbox-passwords`. The file inside blackbox is called `heroku-verify-build-bot`. Once logged in it will bring up the dashbaord, click on `verify-frontend`. On the left is the column for review apps based on PR's raised and the option under them to open or create a review app.

## Cross GOV.UK Domain Google Analytics

To track user journeys across the whole of GOV.UK, including Verify, Google Analytics code has been introduced to the Verify Frontend.

We will occasionally be asked to add domains to the list of domains for which cross domain tracking is enabled. This list is injected through the `CROSS_GOV_GOOGLE_ANALYTICS_DOMAIN_LIST`
environment variable, which is set in the [`verify-infrastructure-config` repository](https://github.com/alphagov/verify-infrastructure-config/blob/master/terraform/deployments/prod/hub/site.tf)
by setting the `cross_gov_ga_domain_names` variable in the `site.tf` for the relevant environment.

# GOV.UK Design System 3

[GOV.UK frontend](https://github.com/alphagov/govuk-frontend) is included in the repository under 
`lib/node_modules`.  This is installed using `npm`.
Should you have to update the GOV.UK frontend in the future you'll need to run npm within the lib directory and 
commit the results. e.g.

```
git checkout -b <some_branch_name>
cd ./lib
npm update
git add .
git commit
push
```
