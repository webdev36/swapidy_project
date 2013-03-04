require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminDeliveryOrder

end

module RailsAdmin
  module Config
    module Actions
      class Delivery < Base

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-step-forward'
        end
        
        register_instance_option :controller do
          Proc.new do
            #@objects = Order.where("id in (?)", params[:bulk_ids])
            @objects = [@object]
 
            # Update field statues to :completed
            @objects.each do |order|
              next if order.status == Order::STATUES[:delivery]
              order.update_attribute(:status, Order::STATUES[:delivery])
              order.create_notification_to_delivery
            end
 
            flash[:success] = "#{@model_config.label} successfully delivery."
            redirect_to back_or_index
          end
        end
      end
    end
  end
end