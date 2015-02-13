source 'https://rubygems.org'

gem 'rails', '4.0.11'

gem 'activeadmin',                      github: 'activeadmin'
gem 'pg', '~> 0.17.1'
gem 'schema_plus', '~> 1.5'
########
gem 'protected_attributes'
########
gem 'devise', '~> 3.3'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'
# gem 'omniauth-openid', '~> 1.0.1'
# gem 'cancan', '1.6.10'
gem 'cancan', git: 'git://github.com/rosa-abf/cancan.git', tag: '1.6.10-abf'

gem 'ancestry', '~> 2.1'
gem 'paperclip', '~> 4.2'
gem 'resque', '~> 1.25'
gem 'resque-status', '~> 0.4'
gem 'resque_mailer', '~> 2.2'
gem 'resque-scheduler', '~> 2.5.4'
gem 'perform_later', git: 'git://github.com/KensoDev/perform_later.git' # should be after resque_mailer
gem 'russian', '~> 0.6.0'
gem 'highline', '~> 1.6.20'
gem 'state_machine', '~> 1.2'
gem 'redis-rails', '~> 4.0'

gem 'grack', git: 'git://github.com/rosa-abf/grack.git', require: 'git_http'
gem 'grit', git: 'git://github.com/rosa-abf/grit.git', tag: '2.6.16'
gem 'charlock_holmes', '~> 0.7'
gem 'github-linguist', '3.1.5', require: 'linguist'
gem 'diff-display', '~> 0.0.1'

# Wiki
gem "gollum-lib", '~> 3.0'
gem "redcarpet", '~> 3.1'
gem 'creole'
gem 'rdiscount'
# gem 'org-ruby'
gem 'RedCloth'
gem 'wikicloth'

gem 'newrelic_rpm'
gem 'whenever', '~> 0.9.0', require: false

gem 'jbuilder', '~> 2.2'
gem 'rails3-jquery-autocomplete'
gem 'sprockets', '2.11.0'
gem 'will_paginate', '~> 3.0'
gem 'meta-tags', '~> 2.0', require: 'meta_tags'
gem "haml-rails", '~> 0.5'
gem 'jquery-rails', '~> 2.3'
gem 'jquery-migrate-rails'
gem 'ruby-haml-js', '~> 0.0.5'
gem 'slim'
gem 'simple_form', '3.1.0.rc2'
gem 'friendly_id', '~> 5.0'

gem 'rack-throttle', '~> 0.3.0'
gem 'rest-client', '~> 1.7'
gem 'ohm', '~> 1.3.2' # Ohm 2 breaks the compatibility with previous versions.
gem 'ohm-expire', '~> 0.1.3'

gem 'ffi', '~> 1.9.3'

gem 'attr_encrypted', '~> 1.3'
gem "gemoji", "~> 2.1"

# AngularJS related stuff
gem 'underscore-rails'
gem 'angularjs-rails', '~> 1.2.15'
gem 'ng-rails-csrf'
gem 'momentjs-rails'
gem 'angular-i18n', '0.1.2'
gem 'js-routes'
gem 'soundmanager-rails'
gem 'angular-ui-bootstrap-rails'
gem 'angular-rails-templates'
gem 'ngmin-rails'

gem 'time_diff'

gem 'sass-rails', '~> 4.0'
gem 'coffee-rails', '~> 4.1'
gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-rails', '~> 4.2'
gem 'zeroclipboard-rails', '~> 0.1.0'

gem 'compass-rails', '~> 2.0'
gem 'uglifier', '~> 2.5'
gem 'therubyracer', '~> 0.12.1', platforms: [:mri, :rbx]
gem 'therubyrhino', '~> 2.0', platforms: :jruby
gem 'sitemap_generator'

gem 'codemirror-rails', '~> 4.5'


group :production do
  gem "airbrake", '~> 3.1'
  #gem 'bluepill', '~> 0.0.60', require: false
  gem 'puma'
end

group :development do
  gem 'mailcatcher' # 'letter_opener'
  gem 'rails3-generators'
  gem 'hirb'
  gem 'shotgun'
  # deploy
  gem 'capistrano', require: false
  gem 'rvm-capistrano', require: false
  gem 'cape', require: false
  gem 'capistrano_colors', require: false
  # Better Errors & RailsPanel
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'localeapp'
  gem 'skype'
  #gem 'ruby-dbus' if RUBY_PLATFORM =~ /linux/i # Error at deploy
end

group :development, :test do
  gem 'rspec-rails', '~> 2.14.1'
end

group :test do
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'rr',                 '~> 1.1.2'
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'mock_redis',         '~> 0.11'
  gem 'webmock'
  gem 'rake'
  gem 'test_after_commit'
  gem 'timecop'
end
