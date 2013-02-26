class OrderNotifier < ActionMailer::Base

  default :from => "\"#{SITE_NAME}\"<system@#{ROOT_URI}>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.authentication_notifier.user_activation.subject
  #
  def start_processing(order, host_with_port = "https://www.swapidy.com")
    @user = order.user
    @order = order
    @shipping_stamp = @order.shipping_stamps.for_sell.first
    mail :to => @user.email, :subject => "Print Shipping Label" do |format|
      format.html # renders send_report.text.erb for body of email
      format.pdf do
        attachments["Order_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "Order_#{@order.id}.pdf",:template => '/reports/order.pdf.erb',:orientation => 'Landscape')
        ) 
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
    @order = order
    mail :to => @user.email, :subject => "Product Declined - Order #{@order.id}"
  end
  
  def reminder(order, shipping_stamp)
    @user = order.user
    @order = order
    @shipping_stamp = shipping_stamp
    #attachments["ShippingLabel_#{@order.id}_#{@shipping_stamp.id}.png"] = File.read(@shipping_stamp.url)
    #mail :to => @user.email, :subject => "Order #{@order.id} Reminder"
    mail :to => @user.email, :subject => "Order #{@order.id} Reminder" do |format|
      format.html # renders send_report.text.erb for body of email
      format.pdf do
        attachments["Order_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "Order_#{@order.id}.pdf",:template => '/reports/order.pdf.erb')
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
    mail :to => @user.email, :subject => "Product verified - Order #{@order.id}"
  end

end
