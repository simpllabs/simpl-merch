class ExportOrdersRangeJob < ProgressJob::Base
  def initialize(range_from, range_to)
    @range_from = range_from
    @range_to = range_to
  end

  def perform
    begin
      	csv_string = CSV.generate do |csv|

      		header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Order Date", "Shop Name", "Shop Domain", "Gender", "Product Name", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
	      	packing_slip = ["Packing Slip Logo URL", "Packing Slip Message", "Non-Plastic Packaging", "Remove Tag", "Shop Shipping Address1", "Shop Shipping Address2", "Shop Shipping City", "Shop Shipping ZIP", "Shop Shipping Province/State", "Shop Shipping Country"]
	      	#header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Shop Domain", "Gender", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
	      	#packing_slip = ["Packing Slip Logo URL", "Packing Slip Message"]
	      	csv << [*header, *packing_slip]

			Order.where(id: @range_from..@range_to).each do |order|
				shop = Shop.where(shopify_domain: order.shop_domain).first
				intl_shipping = (shop.chose_china_post == "No" || shop.chose_china_post.blank?) ? "USPS" : "China Post"

				shop_from_api = nil
				begin
					session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
					ShopifyAPI::Base.activate_session(session)
					shop_from_api = ShopifyAPI::Shop.current 
				rescue Exception => e

				end

				#row = [order.tracking_number, order.country == "United States" ? "USPS" : intl_shipping, order.id, order.shop_domain, order.gender, order.front_design, order.back_design, order.front_ref, order.back_ref, order.fulfillment_status, order.sku, order.light_or_dark, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, order.country]
				#packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order.name)] : ["",""]
				#csv << [*row, *packing_slip]

				row = [order.tracking_number, order.country == "United States" ? "USPS" : intl_shipping, order.id, order.created_at, order.shop_name, order.shop_domain, order.gender, order.product_name, order.front_design, order.back_design, order.front_ref, order.back_ref, order.fulfillment_status, order.sku, order.light_or_dark, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, order.country]
				packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order.name)] : ["",""]
				csv << [*row, *packing_slip, shop.non_plastic, shop.remove_tag, shop_from_api.blank? ? "" : shop_from_api.address1, shop_from_api.blank? ? "" : shop_from_api.address2, shop_from_api.blank? ? "" : shop_from_api.city, shop_from_api.blank? ? "" : shop_from_api.zip, shop_from_api.blank? ? "" : shop_from_api.province, shop_from_api.blank? ? "" : shop_from_api.country_name]

				sleep(3)
			end

	    end #csv_string end

	    #send out email
	    CsvOrdersMailer.csv_file_email(csv_string).deliver_now
    rescue Exception => e
      job_title = "export_orders_range_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end

  end
end