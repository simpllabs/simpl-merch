class UploadTrackingNumberJob < ProgressJob::Base
  def initialize(tracking_number, order_number)
    @tracking_number = tracking_number
    @order_number = order_number
  end

  def perform
    begin

      order = Order.where(id: @order_number).first
      shop = Shop.where(shopify_domain: order.shop_domain).first

      if order.fulfillment_status == "In-Production"
        session = ShopifyAPI::Session.new(order.shop_domain, Shop.where(shopify_domain: "#{order.shop_domain}").first.shopify_token)
        ShopifyAPI::Base.activate_session(session)

        intl_shipping = (shop.chose_china_post == "No" || shop.chose_china_post.blank?) ? "UPS" : "China Post"
        intl_shipping = order.country == "United States" ? "USPS" : intl_shipping

        tracking_url = intl_shipping == "USPS" ? "https://tools.usps.com/go/TrackConfirmAction.action?tLabels=#{@tracking_number}" : "https://track.aftership.com/china-post/#{@tracking_number}"
        
        shipment_hash = {
          tracking_company: "#{intl_shipping}",
          status: "success",
          tracking_numbers: ["#{@tracking_number}"],
          tracking_urls: ["#{tracking_url}"],
          line_items: [{id: "#{order.shopify_line_item_id}", fulfillment_status: "fulfilled"}],
          notify_customer: false,
          order_id: "#{order.shopify_order_id}"
        }

        ShopifyAPI::Fulfillment.create(shipment_hash)
        order.fulfillment_status = "Shipped"
        order.tracking_number = @tracking_number
        order.save
        sleep(3)
      end

      #open file and iterate through excel rows
      #check if there's a way to do a bulk tracking number upload API call, if not slow calls down so don't reach API call limit
    rescue Exception => e
      job_title = "upload_tracking_number_job.rb, order_number: #{@order_number}, tracking_number: #{@tracking_number}"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end
  end
end