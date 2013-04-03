class OrderNotifier < ActionMailer::Base

  default :from => "\"#{SITE_NAME}\"<system@#{ROOT_URI}>"
  ADMIN_EMAIL = "adam@swapidy.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.authentication_notifier.user_activation.subject
  #
  def start_processing(order, shop_type, host_with_port = "https://www.swapidy.com")
    @user = order.user
    @order = order
    @shop_type = shop_type
    subject = "Ship your product"
    if shop_type == "sell"
      @shipping_stamp = @order.shipping_stamps.for_sell.first
      subject = "Ship your product"
    elsif shop_type == "buy"
      @shipping_stamp = @order.shipping_stamps.for_buy.first
      subject = "Swapidy Order Complete!"
    else
      @shipping_stamp = @order.shipping_stamps.for_buy.first
      subject = "Swapidy Swap Next Steps!"
    end
    mail :to => @user.email, :subject => subject do |format|
      format.html # renders send_report.text.erb for body of email
      format.pdf do
        if shop_type != "buy"
          attachments["Order_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
            render_to_string(:pdf => "Order_#{@order.id}.pdf",:template => '/reports/order.pdf.erb',:orientation => 'Landscape')
          ) 
        end
      end
    end
  end
  
  def start_processing_for_admin(order, shop_type, host_with_port = "https://www.swapidy.com")
    @user = order.user
    @order = order
    if shop_type == "sell"
      @shipping_stamp = @order.shipping_stamps.for_sell.first
    else
      @shipping_stamp = @order.shipping_stamps.for_buy.first
    end      
    mail :to => ADMIN_EMAIL, :subject => "Admin: Swapidy Order Processing #{@user.email}" do |format|
      format.html # renders send_report.text.erb for body of email
      format.pdf do
        if shop_type != "buy"
          attachments["Order_#{@order.id}_for_deliver.pdf"] = WickedPdf.new.pdf_from_string(
            render_to_string(:pdf => "Order_#{@order.id}.pdf",:template => '/reports/order_for_deliver.pdf.erb')
          )
        end
      end
    end
  end
  
  def confirm_to_buy(order, shipping_stamp, host_with_port = "https://www.swapidy.com")
    @host_with_port = host_with_port
    @user = order.user
    @order = order
    @product = order.product
    @shipping_stamp = shipping_stamp
    mail :to => @user.email, :subject => "New Order" do |format|
      format.html # renders send_report.text.erb for body of email
      format.pdf do
        attachments["PurchaseOrder_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "PurchaseOrder_#{@order.id}.pdf", :template => '/reports/order_to_buy.pdf.erb')
        )
      end
    end
  end
  
  def order_cancel(order)
    @user = order.user
    @order = order
    mail :to => @user.email, :subject => "Order #{@order.id} Cancelled"
  end
  
  def product_declined(order)
    @user = order.user
     Rails.logger.info "Test #{@user.to_s}"
    @order = order
    mail :to => @user.email, :subject => "Product Declined - Order #{@order.id}"
  end
  
  def admin_noticed(order)
    @admin = User.where(:is_admin => true).first
    Rails.logger.info "Test #{@admin.to_s}"
    @order = order
    mail :to => @admin.email, :subject => "Product Declined - Order #{@order.id}"
  end
  
  def reminder(order, shipping_stamp)
    @user = order.user
    @order = order
    @trade_ins_stamp = shipping_stamp
    #attachments["ShippingLabel_#{@order.id}_#{@shipping_stamp.id}.png"] = File.read(@shipping_stamp.url)
    #mail :to => @user.email, :subject => "Order #{@order.id} Reminder"
    mail :to => @user.email, :subject => "Order #{@order.id} Reminder" do |format|
      format.html # renders send_report.text.erb for body of email
      format.pdf do
        attachments["Order_#{@order.id}_reminder.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "Order_#{@order.id}.pdf",:template => '/reports/order_to_sell.pdf.erb')
        )
      end
    end
  end

  def tracking_number(order)
    @user = order.user
    @order = order
    mail :to => @user.email, :subject => "Tracking Number - Order #{@order.id}"
  end
  
  def trade_ins_complete(order)
    @user = order.user
    @order = order
    mail :to => @user.email, :subject => "Product Verified - Order #{@order.id}"
  end
  
  def product_delived(order, trade_ins_stamp)
    @user = order.user
    @order = order
    @trade_ins_stamp = trade_ins_stamp
    mail :to => @user.email, :subject => "Order #{@order.id} Delivery" do |format|
    format.html # renders send_report.text.erb for body of email
      format.pdf do
        attachments["Order_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "Order_#{@order.id}.pdf",:template => '/reports/order_to_sell.pdf.erb')
        )
      end
    end
  end
end
