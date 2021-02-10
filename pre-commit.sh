#!/usr/bin/env bash

show_help() {
  cat << EOF
Usage:

  Options:
    -c, --chrome    Tell this script to run tests using chrome driver

    -h, --help      Show's this help message
EOF
}

CHROME=false

while [ "$1" != "" ]; do
    case $1 in
        -c | --chrome)          CHROME=true
                                ;;
        -h | --help)            show_help
                                exit 0
                                ;;
        * )                     echo -e "Unknown option $1...\n"
                                show_help
                                exit 1
    esac
    shift
done

. scripts/deploy.sh

if [[ ! $(git secrets 2>/dev/null) ]]; then
  echo "⚠️ This repository should be checked against leaked AWS credentials ⚠️"
  echo "We highly recommend you run the following:"
  echo "   brew install git-secrets"
  echo "then to set up the git-secrets to run on each commit:"
  echo "   git secrets --install"
  echo "   git secrets --register-aws"
  echo " === !!! !!! !!! === "
else
  for hook in .git/hooks/commit-msg .git/hooks/pre-commit .git/hooks/prepare-commit-msg; do
    if ! grep -q "git secrets" $hook; then
      git secrets --install -f
    fi
  done
  git secrets --register-aws
fi

if [[ $CHROME == "true" ]]; then
  browser=chrome
else
  browser=firefox
fi

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
success=$?

# Stub API tests
BUNDLE_GEMFILE=stub/api/Gemfile bundle
BUNDLE_GEMFILE=stub/api/Gemfile BROWSER=$browser bundle exec rspec --pattern stub/api/**/*_spec.rb
success=$((success || $?))

rm -Rf coverage/

if [ -t 1 ]; then
  if [ $success -eq 0 ]
  then
    funky_pass_banner
  else
    funky_fail_banner
  fi
fi
exit $success
