require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminReminderOrder

end

module RailsAdmin
  module Config
    module Actions
      class Reminder < Base

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-time'
        end
        
        register_instance_option :controller do
          Proc.new do
            if @object.status ==  Order::STATUES[:delivery]
              @object.create_notification_to_reminder
              @object.update_attribute(:status, Order::STATUES[:reminder])
              flash[:success] = "#{@model_config.label} successfully reminder!"
            else
              flash[:error] = "Only delivery orders could be reminder!" 
            end
            redirect_to back_or_index
          end
        end
      end
    end
  end
end