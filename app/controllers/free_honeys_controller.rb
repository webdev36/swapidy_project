class FreeHoneysController < ApplicationController
  
  before_filter :require_login, :only => :create

  def create
    if(params[:emails] == "") 
      @free_honey = FreeHoney.new
      respond_to do |format|
        format.js {
          @error_messages = "Please enter valid email!"
          @return_content = render_to_string(:partial => "/free_honeys/new")
        }
      end
      return
    end
    emails = params[:emails].split(";") if params[:emails] && !params[:emails].blank?

    begin
      FreeHoney.transaction do
        emails.each do |email|
          @free_honey = FreeHoney.new(:receiver_email => email)
          @free_honey.sender = current_user
          if @free_honey.valid?
            @free_honey.save
          else
            raise "#{@free_honey.errors.full_messages.join(". ")}"
          end
        end
        @free_honey = FreeHoney.new
      end
    rescue Exception => e
      @error_messages = e.message
      @free_honey = FreeHoney.new(:receiver_email => params[:emails])
    end

    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/free_honeys/new")
      }
    end
  end

  def confirm
    @free_honey = FreeHoney.find_by_token_key params[:token]
    if @free_honey && @free_honey.confirm
      #sign_in(@free_honey.receiver)
      session[:token] = params[:token]
      redirect_to "/free_honeys/confirm_complete"
    else
      redirect_to "/free_honeys/invalid_token"
    end
  end
  
  def confirm_complete
    @free_honey = FreeHoney.find_by_token_key session[:token]
    if @free_honey
      render "confirm_success"
    else
      redirect_to "/"
    end
  end
  
  def invalid_token
    
  end

end
