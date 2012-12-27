require 'stamps'
require "net/http"
require "uri"

module StampsShipping
  
  def verify_shipping_address
    @logger = Logger.new("log/stamps_shipping.log")
    @logger.info "-------- check address: #{Time.now}------"
    address = Stamps.clean_address(:address => {
      :full_name => [shipping_first_name, shipping_last_name].join(" "), 
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
    result = Stamps.purchase_postage
    
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

  def create_shipping_stamp(from_address, to_address, from_zipcode)
    rates = Stamps.get_rates( :from_zip_code => from_zipcode, 
                              :to_zip_code   => '94043', 
                              :weight_lb     => '0.1', 
                              :ship_date     => (Date.today + 6.days).strftime('%Y-%m-%d'),
                              :package_type => "Package",
                              :service_type  => 'US-PM', #USPS Priority Mail
                              :add_ons       => {
                                :add_on => [
                                  { :type => 'US-A-DC' }
                                ]
                              })
    @logger.info rates
    
    des_address = to_address[:address] if to_address[:address_match]
    des_address = to_address[:candidate_addresses][:address].first if !to_address[:address_match] && to_address[:candidate_addresses] 
    
    src_address = from_address[:address] if from_address[:address_match]
    src_address = from_address[:candidate_addresses][:address].first if !from_address[:address_match] && from_address[:candidate_addresses] 
    
    stamp = Stamps.create!(:transaction_id  => "1234567890ABCDEFG",
                           :tracking_number => "234343434343",
                           :rate => { :from_zip_code => from_zipcode,
                                      :to_zip_code   => '94043',
                                      :weight_lb     => '0.1',
                                      :ship_date     => (Date.today + 6.days).strftime('%Y-%m-%d'),
                                      :package_type  => 'Package',
                                      :service_type  => 'US-PM', #USPS Priority Mail
                                      #:cod_value     => 10.00,
                                      :add_ons       => {
                                        :add_on => [
                                          { :type => 'US-A-DC' }
                                        ]
                                      }
                                    }, 
                           :to => des_address || to_address[:address], 
                           :from => src_address || from_address[:address]
                         )
    @logger.info stamp
  end
  
  private
  
    def get_company_address
      to_address = Stamps.clean_address(:address => { :full_name => 'Swapidy', :address1 => '2310 Rock Street Apt 38', :city => 'Mountain View', :state => 'CA', :zip_code  => '94043' })
      @logger.info "company_address[address]: #{to_address}"
      @logger.info "company_address[:address_match]: #{to_address[:address_match]}"
      @logger.info "company_address[:city_state_zip_ok]: #{to_address[:city_state_zip_ok]}"
      @logger.info("---")
      return to_address
    end
end
