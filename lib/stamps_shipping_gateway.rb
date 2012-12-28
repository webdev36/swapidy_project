require 'stamps'

#This module would be included into Order class/module
module StampsShippingGateway
  
  PURCHASE_AMOUNT = 10.0 #purchase $10 if it dont have enought Stamps account's balance
  PACKAGE_TYPE = "Package"
  PRIORITY_MAIL_SERVICE_TYPE = 'US-PM' #USPS Priority Mail
  DELIVERY_CONFIRMATION_TYPE = 'US-A-DC'
  INSUFFICIENT_POSTAGE_ERROR = "Insufficient Postage"
  DUE_DAYS_NUMBER = 2

  def verify_shipping_address
    @logger = Logger.new("log/stamps_shipping.log")
    @logger.info "-------- check address: #{Time.now}------"
    address = Stamps.clean_address(:address => {  :full_name => [shipping_first_name, shipping_last_name].join(" "), 
                                                  :address1 => shipping_address, 
                                                  :address2 => shipping_optional_address, 
                                                  :city => shipping_city, 
                                                  :state => shipping_state, 
                                                  :zip_code  => shipping_zip_code })
    @logger.info address
    @logger.info "-------- END ------"
    return true if address[:address_match]
    self.candidate_addresses = address[:candidate_addresses][:address] if address[:candidate_addresses]
    return false
  end

  def purchase_postage
    @logger = Logger.new("log/stamps_shipping.log")
    @logger.info "-------- purchase_postage: #{Time.now}------"
    
    current_account = Stamps.account
    @logger.info current_account
    
    current_control_total = current_account[:postage_balance][:control_total].to_f rescue 0.0
    result = Stamps.purchase_postage(:amount => PURCHASE_AMOUNT, :control_total => current_control_total)
    
    @logger.info result
    @logger.info "-------- END ------"
  end

  def test_shipping
    @logger = Logger.new("log/stamps_shipping.log")
    @logger.info "-------- #{Time.now}------"
    
    to_address = get_company_address
    
    from_address = Stamps.clean_address(:address => { :full_name => 'Littlelines', :address1 => '1601 Willow Road', :city => 'Menlo Park', :state => 'CA', :zip_code  => '94025' })
    @logger.info "from_address[:address]: #{from_address}"
    @logger.info "from_address[:address_match]: #{from_address[:address_match]}"
    @logger.info "from_address[:city_state_zip_ok]: #{from_address[:city_state_zip_ok]}"
    @logger.info "from_address[:candidate_addresses]: #{from_address[:candidate_addresses] ? "true": "false"}"
    @logger.info("---")
    create_shipping_stamp(from_address, to_address, '94025')
    
    
    from_address = Stamps.clean_address(:address => { :full_name => 'Swapidy client', :address1 => '4795 W. Pebble Beach Dr.', :city => 'Wadsworth', :state => 'IL', :zip_code  => '60083' })
    @logger.info "from_address[:address]: #{from_address}"
    @logger.info "from_address[:address_match]: #{from_address[:address_match]}"
    @logger.info "from_address[:city_state_zip_ok]: #{from_address[:city_state_zip_ok]}"
    @logger.info "from_address[:candidate_addresses]: #{from_address[:candidate_addresses] ? "true": "false"}"
    @logger.info("---")
    create_shipping_stamp(from_address, to_address, '60083')
    
    
    from_address = Stamps.clean_address(:address => { :full_name => 'Swapidy client', :address1 => '5420 Belmont Ct.', :city => 'Libertyville', :state => 'IL', :zip_code  => '60048' })
    @logger.info "from_address[:address]: #{from_address}"
    @logger.info "from_address[:address_match]: #{from_address[:address_match]}"
    @logger.info "from_address[:city_state_zip_ok]: #{from_address[:city_state_zip_ok]}"
    @logger.info "from_address[:candidate_addresses]: #{from_address[:candidate_addresses] ? "true": "false"}"
    
    @logger.info("---")
    create_shipping_stamp(from_address, to_address, '60048')
    
    
    @logger.info "-------- END ------"
    return
  end

  def create_shipping_label
    client_address = Stamps.clean_address(:address => { :address1 => shipping_address,
                                    :city => shipping_city,
                                    :state => shipping_state,
                                    :zip_code => shipping_zip_code,
                                    :country  => shipping_country
                                  })
    return create_shipping_stamp(client_address[:address], get_company_address)
  end
  
  def create_shipping_order
    client_address = Stamps.clean_address(:address => { :address1 => shipping_address,
                                    :city => shipping_city,
                                    :state => shipping_state,
                                    :zip_code => shipping_zip_code,
                                    :country  => shipping_country
                                  })
    return create_shipping_stamp( get_company_address, 
                                  client_address[:address])
  end
  
  private
  
    def create_shipping_stamp(from_address, to_address)
    package = { :from_zip_code => from_address[:zip_code],
                :to_zip_code   => to_address[:zip_code], 
                :weight_lb     => weight_lb, 
                :ship_date     => (Date.today + DUE_DAYS_NUMBER.days).strftime('%Y-%m-%d'),
                :package_type  => PACKAGE_TYPE,
                :service_type  => PRIORITY_MAIL_SERVICE_TYPE, 
                :add_ons       => {
                  :add_on => [
                    { :type => DELIVERY_CONFIRMATION_TYPE }
                  ]
                }
              }

    rates = Stamps.get_rates(package) 
    if !rates[:valid?].nil? && rates[:valid?] == false && rates[:errors] 
      if rates[:errors].first == INSUFFICIENT_POSTAGE_ERROR
        purchase_postage
        sleep(8) #Sleep 8s to wait Stamps.com for payment
        rates = Stamps.get_rates(package)
        raise rates[:errors] if !rates[:valid?].nil? && rates[:valid?] == false && rates[:errors] 
      else
        raise rates[:errors]
      end
    end
    
    stamp = Stamps.create!(:transaction_id  => self.id,
                           #:tracking_number => "234343434343",
                           :rate => rates.first, 
                           :to => to_address, 
                           :from => from_address
                         )
    raise stamp[:errors] if !stamp[:valid?].nil? && stamp[:valid?] == false && stamp[:errors]

    return stamp
  end
  
  private
  
    def get_company_address
      to_address = Stamps.clean_address(:address => { :full_name => 'Swapidy', :address1 => '2310 Rock Street Apt 38', :city => 'Mountain View', :state => 'CA', :zip_code  => '94043' })
#      @logger.info "company_address[address]: #{to_address}"
#      @logger.info "company_address[:address_match]: #{to_address[:address_match]}"
#      @logger.info "company_address[:city_state_zip_ok]: #{to_address[:city_state_zip_ok]}"
#      @logger.info("---")
      return to_address[:address]
    end

end
