source "https://rubygems.org"

group :test do
  gem "rake"
  # ruby 2.4 requires at least puppt 4.10.2 (ssl bug PUP-7383)
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 4.10'
  gem "rspec"
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem 'rubocop'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'librarian-puppet'

  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
  gem 'puppet-lint-resource_reference_syntax'
  gem 'semantic_puppet'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem 'puppet-blacksmith', '< 4.0.0'
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
end
