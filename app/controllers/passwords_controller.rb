class PasswordsController < Devise::PasswordsController
  
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      redirect_to "/password_success"
    else
      respond_with(resource)
    end
  end

  def change_password

  end

end