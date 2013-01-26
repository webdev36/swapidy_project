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
            if @object.is_trade_ins? || @object.status ==  Order::STATUES[:pending]
              @object.create_notification_to_reminder
              flash[:success] = "#{@model_config.label} successfully reminder!"
            else
              flash[:error] = "Only Trade-Ins could not be reminder!" 
            end
 
            redirect_to back_or_index
          end
        end
      end
    end
  end
end