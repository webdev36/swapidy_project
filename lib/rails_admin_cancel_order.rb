require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminCancelOrder

end

module RailsAdmin
  module Config
    module Actions
      class Cancel < Base

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-stop'
        end
        
        register_instance_option :controller do
          Proc.new do
            #@objects = Order.where("id in (?)", params[:bulk_ids])
            @objects = [@object]
 
            # Update field statues to :declined
            @objects.each do |order|
              order.update_attribute(:status, Order::STATUES[:cancelled])
              order.create_notification_to_cancel
            end
 
            flash[:success] = "#{@model_config.label} successfully cancelled."
            redirect_to back_or_index
          end
        end
      end
    end
  end
end