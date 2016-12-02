#!/bin/bash

PATH="/home/koala/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd /var/www/koala.svsticky.nl
bundle exec unicorn -c config/unicorn.rb -E {{ koala_environment }} -D
