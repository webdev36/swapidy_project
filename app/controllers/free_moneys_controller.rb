class FreeMoneysController < ApplicationController
  
  before_filter :require_login, :only => :create

  def create
    if(params[:email] == "") 
      @free_money = FreeHoney.new
      respond_to do |format|
        format.js {
          @error_messages = "Please enter valid email!"
          @return_content = render_to_string(:partial => "/free_moneys/new")
        }
      end
      return
    end
    
    @free_money = FreeHoney.new(:receiver_email => params[:email] )
    @free_money.sender = current_user
    if @free_money.valid?
      @free_money.save
      @success_message = "Well done! You successfully sent FREE Money."
    else
      @error_messages = @free_money.errors.messages[@free_money.errors.messages.keys.last].last
    end

    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/free_moneys/new")
      }
    end
  end

  def confirm
    @free_money = FreeHoney.find_by_token_key params[:token]
    if @free_money && @free_money.confirm
      #sign_in(@free_money.receiver)
      session[:token] = params[:token]
      redirect_to "/free_moneys/confirm_complete"
    else
      redirect_to "/free_moneys/invalid_token"
    end
  end
  
  def confirm_complete
    @free_money = FreeHoney.find_by_token_key session[:token]
    if @free_money
      render "confirm_success"
    else
      redirect_to "/"
    end
  end
  
  def invalid_token
    
  end

end
