# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'fileutils'

Rails.application.load_tasks

task spec: ['lint:ruby', 'lint:sass']
task default: [:spec, 'jasmine:ci']
