# 3. AB Testing Using Rails Routes

Date: 12/06/2017

## Status

Accepted

## Context

Prior AB testing involved changing existing model/view/controller files using if/else blocks to distinguish between A or
 B test behaviour. This also involved changing the various tests to accomodate the new B route. This approach made it 
 difficult for a future team to identify and remove the B code. This approach was developed in response to a need to 
 speed up the process of setting up and tearing AB tests in anticipation that a lot of them would be run.

## Decision
Rather than trying to modify files to accommodate B changes, this approach applies changes to cloned copies of files
 that relate to the B behaviour.  A and B routes are defined through a new piece of code in routes.rb, which takes 
 advantage of Rail's constraints.  Cloning any JavaScript files is helped by code(ab_test_selector.js) used in 
 app/javascripts/application.js.erb
 
 Similarly, test files are also cloned and specific B tests are added to the copy.  

## Consequences
In the short term, cloning files to support B behaviour can seem like a lot of duplicative effort.  However, the 
approach of making changes to copied files helps isolate the effect of B code and makes it easier to remove it by
teams who may have little knowledge of the original AB test story.