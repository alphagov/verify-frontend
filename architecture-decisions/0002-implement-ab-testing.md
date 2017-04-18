# 2. Implement AB testing

Date: 05/04/2017

## Status

Accepted

## Context

In order to aid the performance team in selecting which views and/or functionalities lead to an increase in user completion rate for verification with IDPs we decided to implement AB testing.

Each AB test is a result of user testing lab feedback and ideas. This is not to replace lab user tests.

Tests will run  until the number of users in both groups reach significance. After tha all code should be torn down.

## Decision

Users involved in AB testing will be put in groups according to the alternative name in the AB test cookie. These are configured in YAML files in Verify Federation Config with the experiment name, alternative names and percentage split. 

Users in each group will have a different journey depending on the alternative in that AB test. Alternative A is always the default current journey.
One would not usually have more than two alternatives. If more than one AB test is running concurrently the performance team must ensure the tests to not compound each other.

We looked into the gem [splitrb](https://github.com/splitrb/split) but that required a Reddis database to be install on all environments. It was decided this was too large an infrastructure effort to make it worthwhile using the gem.

The AB test cookie with the alternative name is dropped in the start page but reported to analytics of the page that displays the difference.

## Consequences

Any changes to the AB test framework is within our capacity to change. 

An ab test hash generated from all the experiments in the ab test cookie is made on initialization.

The ab test module has methods to retrieve the alternative name and report to analytics.
