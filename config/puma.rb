#!/usr/bin/env puma

environment 'production'

pidfile 'tmp/puma.pid'
state_path 'tmp/puma.state'
stdout_redirect 'log/puma.stdout', 'log/puma.stderr', true

bind 'unix://tmp/puma.sock'


workers 2 unless Gem.win_platform?