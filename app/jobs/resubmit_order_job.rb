class ResubmitOrderJob < ProgressJob::Base
	def initialize(order_id)
		@order_id = order_id
	end

	def perform

		begin

			order_from_model = Order.where(id: @order_id).first

			shop = Shop.where(shopify_domain: order_from_model.shop_domain).first
			intl_shipping = (shop.chose_china_post == "No" || shop.chose_china_post.blank?) ? "UPS" : "China Post"

			sku = ""
	    	if order_from_model.gender != "Male,Female"
		    	if order_from_model.gender == "male" || order_from_model.gender == "Male"
		    		sku = "#{order_from_model.sku}-Male"
		    	else
		    		sku = "#{order_from_model.sku}-Female"
		    	end
		    else
		    	sku = order_from_model.sku
		    end

		    packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order_from_model.name)] : ["",""]

		    shop_from_api = nil
			begin
				shop_from_api = ShopifyAPI::Shop.current 
			rescue Exception => e

			end
			
			order = [];
			order[0] = "";
			order[1] = order_from_model.country == "US" ? "USPS" : intl_shipping
			order[2] = @order_id
			order[3] = order_from_model.created_at
			order[4] = order_from_model.shop_name
			order[5] = order_from_model.shop_domain
			order[6] = order_from_model.gender
			order[7] = order_from_model.product_name
			order[8] = order_from_model.front_design
			order[9] = order_from_model.back_design
			order[10] = order_from_model.front_ref
			order[11] = order_from_model.back_ref
			order[12] = "In-Production"
			order[13] = update_color_names(sku)
			order[14] = order_from_model.light_or_dark
			order[15] = order_from_model.quantity
			order[16] = order_from_model.name
			order[17] = order_from_model.address1
			order[18] = order_from_model.address2
			order[19] = order_from_model.company
			order[20] = order_from_model.city
			order[21] = order_from_model.zip
			order[22] = order_from_model.province
			order[23] = order_from_model.country

			order[24] = packing_slip[0]
			order[25] = packing_slip[1]
			order[26] = shop.non_plastic
			order[27] = shop.remove_tag
			order[28] = shop_from_api.blank? ? "" : shop_from_api.address1
			order[29] = shop_from_api.blank? ? "" : shop_from_api.address2
			order[30] = shop_from_api.blank? ? "" : shop_from_api.city
			order[31] = shop_from_api.blank? ? "" : shop_from_api.zip
			order[32] = shop_from_api.blank? ? "" : shop_from_api.province
			order[33] = shop_from_api.blank? ? "" : shop_from_api.country_name

			ResubmitOrderMailer.order_email(order).deliver_now

		rescue Exception => e
	    	job_title = "resubmit_order_job.rb"
		    log_data_1 = e.message
		    log_data_2 = e.backtrace

		    ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    	end
	end

	def update_color_names(sku)
		if sku.include?("Light Gray")
			return sku.sub("Light Gray", "Sport Gray")
		elsif sku.include?("Gray")
			return sku.sub("Gray", "Dark Heather")
		elsif sku.include?("Green")
			return sku.sub("Green", "Irish Green")
		elsif sku.include?("Orange") && sku.include?("Female")
			return sku.sub("Orange", "Heather Orange")
		else
			return sku
		end

	end
end