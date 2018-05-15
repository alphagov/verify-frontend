#!/usr/bin/env bash

. scripts/deploy.sh

export RAILS_ENV=test

for focus in fdescribe fcontext fit fspecify fexample; do
  FILES=$(git diff -G"^\s*$focus" --name-only | wc -l)
  if [ $FILES -gt 0 ] 
  then
    echo ""
    tput setaf 1; echo "You forgot to remove a $focus in the following files:"; tput sgr 0
    git diff --name-only -G"^\s*$focus"
    echo ""
    STATUS=1
    funky_fail_banner
    exit $STATUS
  fi
done

bundle check || bundle install
bundle exec rake
success=$((success || $?))

# Stub API tests
BUNDLE_GEMFILE=stub/api/Gemfile bundle
BUNDLE_GEMFILE=stub/api/Gemfile bundle exec rspec --pattern stub/api/**/*_spec.rb
success=$((success || $?))

if [ -t 1 ]; then
  if [ $success -eq 0 ]
  then
    funky_pass_banner
  else
    funky_fail_banner
  fi
fi
exit $success
