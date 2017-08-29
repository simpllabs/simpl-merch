class CancelOrderJob < ProgressJob::Base
  def initialize(domain, params)
    @domain = domain
    @params = params
  end

  def perform

    Order.where(shopify_order_id: "#{@params[:id]}").each do |order|
  		if order.fulfillment_status == "Pending"
  			order.fulfillment_status = "Cancelled"
  			order.save
  		end 
    end
  end
end