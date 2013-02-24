class UserNotifier < ActionMailer::Base
  default :from => "\"#{SITE_NAME}\"<system@#{ROOT_URI}>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.authentication_notifier.user_activation.subject
  #
  def signup_greeting(user, mode = :normal_signup)
    @user = user
    @need_password = (mode == :free_money_signup)
    swapidy_sendmail :to => @user.email, :subject => "Welcome to Swapidy"
  end

  def free_money_sent(free_money)
    @free_money = free_money
    swapidy_sendmail :to => @free_money.receiver_email, :subject => "Free Money"
  end
  
  def free_money_completed(free_money)
    @free_money = free_money
    swapidy_sendmail :to => @free_money.receiver_email, :subject => "Free Money Received"
  end
  
  def free_money_reward(free_money)
    @free_money = free_money
    swapidy_sendmail :to =>@free_money.sender.email, :subject => "Free Money Reward"
  end
  
  def redeem_completed(redeem_code, user)
    @redeem_code = redeem_code
    @user = user
    swapidy_sendmail :to => @user.email, :subject => "Free Money Received"
  end
  
  def contact_us(admin_email, contact)
    @contact = contact
    swapidy_sendmail :to => admin_email, :subject => "Swapidy Contact: #{contact[:subject]}"
  end
  
  def brand_email(email, title, content)
    @content = content
    swapidy_sendmail :to => email, :subject => title
  end
  
  private

    def swapidy_sendmail hash_params
      if Rails.env == 'production' && (ENV['SWAPIDY_VERSION'].nil? || ENV['SWAPIDY_VERSION'] != 'swapidy')
        mail :to => "adam@swapidy.com, pulkit@swapidy.com, hai.bth@gmail.com", :subject => "#{hash_params[:subject]} - To: #{hash_params[:to]}"
      else
        mail :to => hash_params[:to], :subject => hash_params[:subject]
      end
    end

end
