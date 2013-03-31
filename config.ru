# This file is used by Rack-based servers to start the application.

#require "rack/timeout"
#use Rack::Timeout
#Rack::Timeout.timeout = 50

require ::File.expand_path('../config/environment',  __FILE__)
run Swapidy::Application
