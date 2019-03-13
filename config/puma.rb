#!/usr/bin/env puma

require 'prometheus/client'
require 'prometheus/client/data_stores/direct_file_store'

environment 'production'

pidfile 'tmp/puma.pid'
state_path 'tmp/puma.state'
stdout_redirect 'log/puma.stdout', 'log/puma.stderr', true

metrics_dir = Dir.mktmpdir('frontend-metrics')

on_worker_boot do
  Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(dir: metrics_dir)
end

bind 'unix://tmp/puma.sock'

workers 2 unless Gem.win_platform?
