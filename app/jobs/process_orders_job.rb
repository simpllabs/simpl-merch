class ProcessOrdersJob < ProgressJob::Base
	def initialize

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

  	# run everyday 11:59 pm MST
  	def perform

    begin
    	
    	orders = []
	    csv_string = CSV.generate do |csv|

	      	header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Order Date", "Shop Name", "Shop Domain", "Gender", "Product Name", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
	      	packing_slip = ["Packing Slip Logo URL", "Packing Slip Message", "Non-Plastic Packaging", "Remove Tag", "Shop Shipping Address1", "Shop Shipping Address2", "Shop Shipping City", "Shop Shipping ZIP", "Shop Shipping Province/State", "Shop Shipping Country"]
	      	csv << [*header, *packing_slip]

	      	Shop.where.not(stripe_customer_id: nil).each do |shop|

				session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
				ShopifyAPI::Base.activate_session(session)

				#shop_from_api = ShopifyAPI::Shop.current

				#start by checking if orders with pending payment status have been paid
				Order.where(fulfillment_status: "Pending").each do |order|
				  if order.payment_status == "pending"
				    #Do a Shopify API call to check is still pending
				    payment_status = "pending"
				    begin
				  	  payment_status = ShopifyAPI::Order.find(order.shopify_order_id).financial_status
				    rescue Exception => e
				  	
				    end
				    order.payment_status = payment_status
				    order.save
				  end
				end

				charge_amount = 0
				design_fee = 0
				store_order_numbers = []
				Order.where(fulfillment_status: "Pending").each do |order|
				  
				  # Don't process order if its payment status is pending
				  if order.payment_status != "pending"

				    #tee = Tee.where(id: order.tee_id).first
				    #if !tee.one_time_fee_charged
				    #  design_fee += 3 
				    #  tee.one_time_fee_charged = true
				    #end
				    #if !tee.back_one_time_fee_charged
				    #  design_fee += 3 
				    #  tee.back_one_time_fee_charged = true
				    #end
				    #tee.save

				    base_cost = 6

				    #charge 2XL+ extra fees
				    if order.sku.include?("Female")
				    	base_cost = base_cost + 1.3 if order.product_name.include?("2XL /")
				    	base_cost = base_cost + 2.0 if order.product_name.include?("3XL /")
				    else
				    	base_cost = base_cost + 1.66 if order.product_name.include?("2XL /")
				    	base_cost = base_cost + 2.96 if order.product_name.include?("3XL /")
				    end

				    #if order.gender == "Male,Female"
				    #	base_cost = 6 if order.sku.include?("Male")
				    #	base_cost = 6 if order.sku.include?("Female")
				    #else
				    #	base_cost = order.gender == "male" || order.gender == "Male" ? 6 : 6
				    #end

				    if order.back_design.present? && order.front_design.present? 
				    	base_cost = base_cost + 1
				    end
				    
				    #base_cost = order.multicolor == 'yes' ? base_cost + 1.5 : base_cost

				    
				    is_US = order.country.include?("United States") || order.country.include?("US")

				    chose_china_post = shop.chose_china_post == "Yes"

				    if is_US
				    	if store_order_numbers.include?(order.store_order_number)
				    		base_cost = base_cost + 1.5
				    	else
				    		base_cost = base_cost + 3
				    	end
				    else
				    	if store_order_numbers.include?(order.store_order_number)
				    		base_cost = base_cost + 6
				    	else
				    		base_cost = base_cost + 8
				    	end
				    	#if chose_china_post
					    #  	base_cost = base_cost + 8 #used to be 4.5, maybe bring back down when can do $6 total?
					    #else
					    #	base_cost = base_cost + 8
					    #end
				    end

				    if shop.non_plastic == "Yes"
				    	#base_cost = base_cost + 0.5
				    end

				    if shop.remove_tag == "Yes"
				    	#base_cost = base_cost + 0.05
				    end

				    if shop.shopify_domain == order.shop_domain
				    	if store_order_numbers.include?(order.store_order_number)
				      		charge_amount = charge_amount + (order.quantity * base_cost)
				      	else
				      		if order.quantity > 1
				      			charge_amount = charge_amount + base_cost
				      			charge_amount = charge_amount + ((order.quantity - 1) * (base_cost - (is_US ? 1.5 : 2)))
				      		else
				      			charge_amount = charge_amount + (order.quantity * base_cost)
				      		end
				      	end
				    end
				  end

				  store_order_numbers.push(order.store_order_number)

				end

				charge_amount = charge_amount + design_fee
				charge_amount = charge_amount + (charge_amount * 0.03) + 0.3 #Stripe fees
				charge_amount = charge_amount * 100 #set total to cents

				status = "In-Production"

				if charge_amount > 0

				  begin
				    charge = Stripe::Charge.create(
				      :amount => charge_amount.to_i,
				      :currency => "usd",
				      :customer => shop.stripe_customer_id,
				      :receipt_email => shop.send_receipts == "Yes" ? shop.email : nil
				    )
				  rescue Stripe::APIConnectionError => e
				    status = "#APIConnectionError: #{e.message}"
				  rescue Stripe::CardError => e
				    status = "#CardError: #{e.message}"
				    #send shop owner email here saying their card is invalid, say will try again in 10 hour intervals 3 times
				  rescue Stripe::AuthenticationError => e
				    status = "#AuthenticationError: #{e.message}"
				  rescue Stripe::InvalidRequestError => e
				    status = "#InvalidRequestError: #{e.message}"
				  rescue Stripe::StripeError => e
				    status = "#StripeError: #{e.message}"
				  rescue Stripe::APIError => e
				    status = "#APIError: #{e.message}"
				  rescue Stripe::ValidationError => e
				    status = "#ValidationError: #{e.message}"
				  end

				  intl_shipping = (shop.chose_china_post == "No" || shop.chose_china_post.blank?) ? "UPS" : "China Post"

				  shop_from_api = nil
				  begin
				  	shop_from_api = ShopifyAPI::Shop.current 
				  rescue Exception => e

				  end

				  Order.where(fulfillment_status: "Pending").each do |order|
				    if shop.shopify_domain == order.shop_domain && order.payment_status != "pending"

				    	sku = ""
				    	if order.gender != "Male,Female"
					    	if order.gender == "male" || order.gender == "Male"
					    		sku = "#{order.sku}-Male"
					    	else
					    		sku = "#{order.sku}-Female"
					    	end
					    else
					    	sku = order.sku
					    end

						row = ["", order.country == "US" ? "USPS" : intl_shipping, order.id, order.created_at, order.shop_name, order.shop_domain, order.gender, order.product_name, order.front_design, order.back_design, order.front_ref, order.back_ref, status, update_color_names(sku), order.light_or_dark, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, order.country]
						packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order.name)] : ["",""]
						csv << [*row, *packing_slip, shop.non_plastic, shop.remove_tag, shop_from_api.blank? ? "" : shop_from_api.address1, shop_from_api.blank? ? "" : shop_from_api.address2, shop_from_api.blank? ? "" : shop_from_api.city, shop_from_api.blank? ? "" : shop_from_api.zip, shop_from_api.blank? ? "" : shop_from_api.province, shop_from_api.blank? ? "" : shop_from_api.country_name]
						order.processed = true
						order.fulfillment_status = status == "In-Production" ? status : "Pending"
						order.save

						sleep(3)

						orders.push(order) if status == "In-Production"
				    end
				  end
				end
		    end #shop each end

	    end #csv_string end

	    #send out email
	    CsvOrdersMailer.csv_file_email(csv_string).deliver_now
	    send_email_per_order(csv_string)

	    #update inventory
    	#orders.each do |order|
    	#	updateInvetoryTables(order.gender, order.quantity, order.sku)
    	#end

    rescue Exception => e
    	job_title = "process_orders_job.rb"
	    log_data_1 = e.message
	    log_data_2 = e.backtrace

	    ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end

  end

  def send_email_per_order(csv_string)
  	orders = []
  	CSV.parse(csv_string, {headers: true}) do |order|
  		if order[12] == "In-Production" && order[1] != "China Post"
	  		PerOrderMailer.order_email(order).deliver_now
	  	end
	  	if order[12] != "In-Production" && order[12] != "Pending"
	  		email = Shop.where(shopify_domain: order[5]).first.email
	  		FailedProcessingCardMailer.failed_card_email(email, order[12], Order.where(id: order[2]).first.store_order_number).deliver_now
	  	end
	  	if order[1] == "China Post"
	  		orders.push(order)
	  	end
	  	
        sleep(3)
    end

    csv_string2 = CSV.generate do |csv|
      	header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Order Date", "Shop Name", "Shop Domain", "Gender", "Product Name", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
      	packing_slip = ["Packing Slip Logo URL", "Packing Slip Message", "Non-Plastic Packaging", "Remove Tag", "Shop Shipping Address1", "Shop Shipping Address2", "Shop Shipping City", "Shop Shipping ZIP", "Shop Shipping Province/State", "Shop Shipping Country"]
      	csv << [*header, *packing_slip]

      	orders.each do |order|
      		csv << order
      	end
    end
    CsvOrdersMailer.csv_file_email(csv_string2).deliver_now

    check_if_any_in_same_order(csv_string)
  end

  def check_if_any_in_same_order(csv_string)
  	#
  end

  def updateInvetoryTables(gender, quantity, sku)
    sku_convention = sku.split('-').reverse.join('_').downcase

    if gender == "female"
      record = FemaleInventory.all.first
      record["#{sku_convention}"] -= quantity.to_i
      record.save
    else
      record = MaleInventory.all.first
      record["#{sku_convention}"] -= quantity.to_i
      record.save
    end
  end

end






























