source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.11'



# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'
gem 'devise'
gem "recaptcha", :require => "recaptcha/rails"
#gem 'galetahub-simple_captcha', :require => 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git'

gem 'simple_form'
gem 'haml'
gem 'paperclip'
gem 'stripe'
gem 'active_shipping'
gem 'carmen-rails'
gem 'wicked_pdf'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'rails_admin'
gem 'rails_admin_import'
gem 'savon', '0.8.6'
gem 'httpi', '0.7.9'
gem 'multi_json', '~> 1.0'

gem 'delayed_job_active_record'

#gem 'rack-timeout'
#gem 'resque'
#gem 'stamps'
#gem 'active_shipping'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

#gem 'jquery-rails'
group :production do
  #gem 'stamps'
  gem 'thin'
  gem 'pg'
  gem "wkhtmltopdf-heroku", :git => 'git://github.com/camdez/wkhtmltopdf-heroku.git'
  gem 'rmagick'
  gem 'aws-sdk'
  gem 'memcachier'
  gem 'dalli'
end

group :development, :test do
  gem 'mailcatcher'
  gem 'sqlite3'
  gem "wkhtmltopdf"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
