Recaptcha.configure do |config|
  if Rails.env == 'production'
    config.public_key  = "6LeP5NsSAAAAAOa42wNDfrUtmUKyxUKdZ1yn-h1G"
    config.private_key = "6LeP5NsSAAAAABhjwEuWc7LjWXrU7_p-cyENsG0z"
    #config.proxy = 'http://myproxy.com.au:8080'
  else
    #Please run "rails s -p 80" to test
    config.public_key  = '6LcM5dsSAAAAANxB0i4fIVn9ZweRz5Y_X46BmwUO'
    config.private_key = '6LcM5dsSAAAAAFgEI1IwhAl8SwR7EmvjMLe_ttBv'
    #config.proxy = 'http://myproxy.com.au:8080'
  end
end