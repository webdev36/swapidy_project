require 'stamps'

#This module would be included into Order class/module
module StampsShippingGateway
  
  PURCHASE_AMOUNT = 100.0 #purchase $100 if it dont have enough Stamps account's balance
  PACKAGE_TYPE = "Package"
  PRIORITY_MAIL_SERVICE_TYPE = 'US-PM' #USPS Priority Mail
  DELIVERY_CONFIRMATION_TYPE = 'US-A-DC'
  INSUFFICIENT_POSTAGE_ERROR = "Insufficient Postage"
  DUE_DAYS_NUMBER = 2

  def verify_shipping_address
    #@logger = Logger.new("log/stamps_shipping.log")
    #@logger.info "-------- check address: #{Time.now}------"
    address = get_client_address
    #@logger.info address
    #@logger.info "-------- END ------"
    return true if address[:address_match]
    self.candidate_addresses = address[:candidate_addresses][:address] if address[:candidate_addresses]
    return true if address[:city_state_zip_ok] && is_candidate_address && is_candidate_address.to_s == "true"
    return false
  end

  def purchase_postage
    @logger = Logger.new("log/stamps_shipping.log")
    @logger.info "-------- purchase_postage: #{Time.now}------"
    
    current_account = Stamps.account
    #@logger.info current_account
    
    current_control_total = current_account[:postage_balance][:control_total].to_f rescue 0.0
    result = Stamps.purchase_postage(:amount => PURCHASE_AMOUNT, :control_total => current_control_total)
    
    #@logger.info result
    @logger.info "-------- END ------"
  end

  def test_shipping
    #@logger = Logger.new("log/stamps_shipping.log")
    #@logger.info "-------- #{Time.now}------"
    
    to_address = get_company_address
    
    #from_address = Stamps.clean_address(:address => { :full_name => 'Littlelines', :address1 => '1601 Willow Road', :city => 'Menlo Park', :state => 'CA', :zip_code  => '94025' })
    #@logger.info "from_address[:address]: #{from_address}"
    #@logger.info "from_address[:address_match]: #{from_address[:address_match]}"
    #@logger.info "from_address[:city_state_zip_ok]: #{from_address[:city_state_zip_ok]}"
    #@logger.info "from_address[:candidate_addresses]: #{from_address[:candidate_addresses] ? "true": "false"}"
    #@logger.info("---")
    #create_shipping_stamp(from_address, to_address, '94025')
    
    
    #from_address = Stamps.clean_address(:address => { :full_name => 'Swapidy client', :address1 => '4795 W. Pebble Beach Dr.', :city => 'Wadsworth', :state => 'IL', :zip_code  => '60083' })
    #@logger.info "from_address[:address]: #{from_address}"
    #@logger.info "from_address[:address_match]: #{from_address[:address_match]}"
    #@logger.info "from_address[:city_state_zip_ok]: #{from_address[:city_state_zip_ok]}"
    #@logger.info "from_address[:candidate_addresses]: #{from_address[:candidate_addresses] ? "true": "false"}"
    #@logger.info("---")
    #create_shipping_stamp(from_address, to_address, '60083')
    
    
    from_address = Stamps.clean_address(:address => { :full_name => 'Swapidy client', :address1 => '5420 Belmont Ct.', :city => 'Libertyville', :state => 'IL', :zip_code  => '60048' })
    #@logger.info "from_address[:address]: #{from_address}"
    #@logger.info "from_address[:address_match]: #{from_address[:address_match]}"
    #@logger.info "from_address[:city_state_zip_ok]: #{from_address[:city_state_zip_ok]}"
    #@logger.info "from_address[:candidate_addresses]: #{from_address[:candidate_addresses] ? "true": "false"}"
    
    #@logger.info("---")
    create_shipping_stamp(from_address[:address], to_address)
    #@logger.info "-------- END ------"
    return
  end

  def create_stamp(weigth_lb, for_type = :for_sell)
    client_address = get_client_address
    if for_type == :for_sell
      return create_shipping_stamp(weigth_lb, client_address[:address], get_company_address)
    else
      #return create_shipping_stamp(weigth_lb, get_company_address, client_address[:address])
      return create_shipping_stamp(weigth_lb, client_address[:address], get_company_address)
    end
  end
  
  private  
    def create_shipping_stamp(weight_lb, from_address, to_address)      
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
      
      stamp = Stamps.create!(:transaction_id  => (self.id || (Order.last.id + 1)).to_s, :rate => package, :to => to_address, :from => from_address)
      
      unless valid_stamp?(stamp)
        if stamp[:errors].first == INSUFFICIENT_POSTAGE_ERROR
          purchase_postage
          sleep(9) #Sleep 8s to wait Stamps.com for payment
          stamp = Stamps.create!(:transaction_id  => (self.id || (Order.last.id + 1)).to_s, :rate => package, :to => to_address, :from => from_address)
          raise stamp[:errors] unless valid_stamp?(stamp)
        else
          raise stamp[:errors]
        end
      end                     
      return stamp
    end
  
    def get_company_address
      to_address = Stamps.clean_address(:address => { :full_name => SwapidySetting.get("COMPANY_NAME"), 
                                                      :address1 => SwapidySetting.get("COMPANY_ADDRESS"), 
                                                      :city => SwapidySetting.get("COMPANY_CITY"), 
                                                      :state => SwapidySetting.get("COMPANY_STATE"), 
                                                      :zip_code  => SwapidySetting.get("COMPANY_ZIP_CODE") })
      return to_address[:address]
    end
    
    def get_client_address
      return @get_client_address if @get_client_address
      @get_client_address = Stamps.clean_address(:address => {  :full_name => [shipping_first_name, shipping_last_name].join(" "), 
                                                  :address1 => shipping_address, 
                                                  :address2 => shipping_optional_address, 
                                                  :city => shipping_city, 
                                                  :state => shipping_state, 
                                                  :zip_code  => shipping_zip_code })
    end
    
    def valid_stamp? stamps
      return false if stamps.class.name != "Array" && !stamps[:valid?].nil? && stamps[:valid?].to_s == "false" && stamps[:errors]
      return true 
    end

end
