class CancelOrderJob < ProgressJob::Base
  def initialize(domain, params)
    @domain = domain
    @params = params
  end

  def perform
    begin

      Order.where(shopify_order_id: "#{@params[:id]}").each do |order|
    		if order.fulfillment_status == "Pending"
    			order.fulfillment_status = "Cancelled"
    			order.save
    		end 
      end
    rescue Exception => e
      job_title = "cancel_order_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end
  end
end