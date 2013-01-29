class PasswordsController < Devise::PasswordsController
  
  def sent_resetpass
    render "change_password"
  end

  
  protected
  
  def after_sending_reset_password_instructions_path_for(resource_name)
    "/sent_resetpass"
  end
end