# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
require "stamps"

Stamps.configure do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de
  config.integration_id = "698b2f76-8f72-4359-b04f-1ca8f761aa68"
  config.username       = "swapidy1"
  config.password       = "postage1"
  config.endpoint       = 'https://swsim.testing.stamps.com/swsim/swsimv24.asmx'.freeze
  config.namespace      = 'http://stamps.com/xml/namespace/2012/05/swsim/swsimv24'.freeze
  config.log_messages   = true
  config.return_address  = {  :full_name    => 'Swapidy Inc.',
                              :address1     => '2310 Rock Street Apt 38',
                              :address2     => '',
                              :city         => 'Mountain View',
                              :state        => 'CA',
                              :zip_code     => '94043',
                              :phone_number => ''
                            }
  
end
