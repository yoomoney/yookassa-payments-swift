source "https://rubygems.org"

gem 'cocoapods', '~> 1.10.0'
gem 'fastlane'
gem 'babelyoda', :git => "ssh://git@bitbucket.yamoney.ru/mt/babelyoda.git"
gem 'xcpretty-yandex-money-formatter', '~> 1.0.9'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
