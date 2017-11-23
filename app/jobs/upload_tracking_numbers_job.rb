class UploadTrackingNumbersJob < ProgressJob::Base
  def initialize(file_path)
    @file_path = file_path
  end

  def perform
    begin

      CSV.foreach(@file_path) do |order|
        if order[9] == "In-Production"
          session = ShopifyAPI::Session.new(order[3], Shop.where(shopify_domain: "#{order[3]}").first.shopify_token)
          ShopifyAPI::Base.activate_session(session)

          tracking_num = order[0]
          if order[0].include?(",")
            tracking_num.slice!(0)
          end

          tracking_url = order[1] == "USPS" ? "https://tools.usps.com/go/TrackConfirmAction.action?tLabels=#{tracking_num}" : "https://track.aftership.com/china-post/#{tracking_num}"

          order_from_model = Order.where(id: "#{order[2]}").first
          
          shipment_hash = {
            tracking_company: "#{order[1]}",
            status: "success",
            tracking_numbers: ["#{tracking_num}"],
            tracking_urls: ["#{tracking_url}"],
            line_items: [{id: "#{order_from_model.shopify_line_item_id}", fulfillment_status: "fulfilled"}],
            notify_customer: false,
            order_id: "#{order_from_model.shopify_order_id}"
          }

          ShopifyAPI::Fulfillment.create(shipment_hash)
          order_from_model.fulfillment_status = "Shipped"
          order_from_model.save
          sleep(3)
        end
      end

      #open file and iterate through excel rows
      #check if there's a way to do a bulk tracking number upload API call, if not slow calls down so don't reach API call limit
    rescue Exception => e
      job_title = "upload_tracking_numbers_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end
  end
end