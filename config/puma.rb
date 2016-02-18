#!/usr/bin/env puma

environment 'production'

pidfile 'tmp/puma.pid'
state_path 'tmp/puma.state'
stdout_redirect 'log/puma.stdout', 'log/puma.stderr', true

bind 'unix://tmp/puma.sock'
bind 'tcp://127.0.0.1:50301'

workers 2

activate_control_app 'unix://tmp/pumactl.sock', { no_token: true }
