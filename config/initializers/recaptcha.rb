Recaptcha.configure do |config|
  if Rails.env == 'production'
    config.public_key  = ENV['RECAPTCHA_PUBLIC_KEY']
    config.private_key = ENV['RECAPTCHA_PRIVATE_KEY']
    #config.proxy = 'http://myproxy.com.au:8080'
  else
    #Please run "rails s -p 80" to test
    config.public_key  = '6LcqFt8SAAAAAAQ8Se-_AdiUIs7loP78Qje11td0'
    config.private_key = '6LcqFt8SAAAAAF1rjumfXddh9II2HFARIPqH0Bx0'
    #config.proxy = 'http://myproxy.com.au:8080'
  end
end
