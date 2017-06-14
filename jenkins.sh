#!/bin/bash -eu

PACKAGE_BASE="front"
GIT_BRANCH_NAME="${GIT_BRANCH_NAME:-master}"

if test "$GIT_BRANCH_NAME" != "master"; then
  echo "Building for branch $GIT_BRANCH_NAME"
  PACKAGE_NAME="${PACKAGE_BASE}-${GIT_BRANCH_NAME}"
else
  PACKAGE_NAME="$PACKAGE_BASE"
fi

bundle
export HEADLESS=true
export DISPLAY=:0
./pre-commit.sh
echo ${BUILD_NUMBER} > .build-number
SECRET_KEY_BASE=no-secret RAILS_ENV=production dotenv bundle exec rake assets:precompile
SECRET_KEY_BASE=no-secret RAILS_ENV=production dotenv bundle exec rake tmp:clear

# We need to copy the manifest file to the root of the public/assets dir due
# to heroku-buildback hardcoding where the manifest file should be
cp public/assets/${BUILD_NUMBER}/.*.json public/assets/

sed -e "s/$PACKAGE_BASE run/$PACKAGE_NAME run/g" \
    -e "s,log/$PACKAGE_BASE/$PACKAGE_BASE,log/$PACKAGE_NAME/$PACKAGE_NAME,g" \
    -e "s,$PACKAGE_BASE Service,$PACKAGE_NAME Service,g" \
    upstart/front.conf > .tmp; mv .tmp "upstart/${PACKAGE_NAME}.conf"
sed "s/$PACKAGE_BASE/$PACKAGE_NAME/g" packaging/postinst.sh > .tmp; mv .tmp packaging/postinst.sh
sed "s/$PACKAGE_BASE/$PACKAGE_NAME/g" packaging/postrm.sh > .tmp; mv .tmp packaging/postrm.sh

bundle exec pkgr package . --buildpack=https://github.com/heroku/heroku-buildpack-ruby --version="${BUILD_NUMBER}" --iteration=1 --name=${PACKAGE_NAME} --dependencies=front-assets-${BUILD_NUMBER} --env STACK=cedar-14
fpm --name front-assets-${BUILD_NUMBER}\
    --version 1\
    -C public/assets\
    --prefix /opt/front-assets\
    -s dir\
    -t deb\
    ${BUILD_NUMBER}/
