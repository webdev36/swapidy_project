class OrderNotifier < ActionMailer::Base
  default :from => "\"#{SITE_NAME}\"<system@#{ROOT_URI}>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.authentication_notifier.user_activation.subject
  #
  def confirm_to_sell(user, order)
    @user = user
    @order = order
    @product = order.product
    mail :to => @user.email, :subject => "Order information to sell" do |format|
      format.text # renders send_report.text.erb for body of email
      format.pdf do
        attachments["TradeInsOrder_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "TradeInsOrder_#{@order.id}.pdf",:template => '/reports/order_to_sell.pdf.erb')
        )
      end
    end
  end
  
  def confirm_to_buy(user, order)
    @user = user
    @order = order
    @product = order.product
    mail :to => @user.email, :subject => "Order information to buy" do |format|
      format.text # renders send_report.text.erb for body of email
      format.pdf do
        attachments["PurchaseOrder_#{@order.id}.pdf"] = WickedPdf.new.pdf_from_string(
          render_to_string(:pdf => "PurchaseOrder_#{@order.id}.pdf", :template => '/reports/order_to_buy.pdf.erb')
        )
      end
    end
  end

end
