require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminDeclineOrder

end

module RailsAdmin
  module Config
    module Actions
      class Decline < Base

        #register_instance_option :bulkable? do
        #  true
        #end
        
        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-thumbs-down'
        end
        
        register_instance_option :controller do
          Proc.new do
            #@objects = Order.where("id in (?)", params[:bulk_ids])
            @objects = [@object]
            # Update field statues to :declined
            @objects.each do |order|
              next if order.status == Order::STATUES[:declined]
              order.update_attribute(:status, Order::STATUES[:declined])
              order.create_notification_to_decline
            end
            flash[:success] = "#{@model_config.label} successfully declined."
            redirect_to back_or_index
          end
        end
      end
    end
  end
end