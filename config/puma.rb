#!/usr/bin/env puma

environment 'development'

pidfile 'tmp/puma.pid'
state_path 'tmp/puma.state'
stdout_redirect 'log/puma.stdout', 'log/puma.stderr', true

bind 'unix://tmp/puma.sock'
bind 'tcp://127.0.0.1:50300'

workers 2 unless Gem.win_platform?
