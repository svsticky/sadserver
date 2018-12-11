# {{ ansible_managed }}

#!/bin/sh

# This script needs to be called with two variables
# $1 - Contentful space ID
# $2 - Contentful access token

cd /var/www/static-sticky/

git clone git@github.com:svsticky/static-sticky.git {{ canonical_hostname }}
cd static-sticky

echo CONTENTFUL_SPACE_ID=$2> .env
echo CONTENTFUL_ACCESS_TOKEN=$3>> .env
# probably we don't want to copy the keys in the .env file manually
# for now we asume this is the case

npm install
npm run build

# cleanup
cd ..
rm -rf static-sticky