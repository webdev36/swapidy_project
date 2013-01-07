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
            #@objects = Order.where("id in (?)", params[:bulk_ids])
            @objects = [@object]
 
            # Update field statues to :declined
            @objects.each do |order|
              if order.is_trade_ins? || order.status ==  Order::STATUES[:pending]
                order.create_notification_to_reminder
              end
            end
 
            flash[:success] = "#{@model_config.label} successfully reminder."
            redirect_to back_or_index
          end
        end
      end
    end
  end
end