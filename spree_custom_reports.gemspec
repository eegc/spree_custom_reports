# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_custom_reports'
  s.version     = '1.0.0'
  s.summary     = 'Custom reports for Spree 3.0'
  s.description = 'Add reports in admin controllers for Spree 3.0'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Enrique Garcia'
  s.email     = 'engarcia.cas@gmail.com'

  s.license = 'MIT'

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.10'

  s.add_development_dependency 'capybara', '~> 2.6'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'sass-rails', '~> 5.0.0'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
