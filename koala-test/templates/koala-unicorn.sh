#!/bin/bash

PATH="/home/koala/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

bundle exec unicorn -c config/unicorn.rb -E {{ koala_environment }} -D
