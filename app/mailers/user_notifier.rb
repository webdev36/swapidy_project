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
    mail :to => @user.email, :subject => "Welcome to Swapidy"
  end

  def free_money_sent(free_honey)
    @free_honey = free_honey
    mail :to => @free_honey.receiver_email, :subject => "Free Money"
  end
  
  def free_money_completed(free_honey)
    @free_honey = free_honey
    mail :to => @free_honey.receiver_email, :subject => "Free Money Received"
  end
  
  def free_money_reward(free_honey)
    @free_honey = free_honey
    mail :to =>@free_honey.sender.email, :subject => "Free Money Reward"
  end
  
  def redeem_completed(redeem_code, user)
    @redeem_code = redeem_code
    @user = user
    mail :to => @user.email, :subject => "Free Money Received"
  end
  
  def contact_us(admin_email, contact)
    @contact = contact
    mail :to => admin_email, :subject => "Swapidy Contact: #{contact[:subject]}"
  end

end
