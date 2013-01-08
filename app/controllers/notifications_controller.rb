class NotificationsController < ApplicationController
  
  def index
  end

  def refresh
    respond_to do |format|
      format.js {
        @notifications_menu = render_to_string(:partial => "/layouts/notifications_menu")
      }
    end
  end
  
  def hide
    @notification = current_user.notifications.find paramas[:id]
    @notification.update_attribute(:has_read, true)
    respond_to do |format|
      format.js {}
    end
  end

end
