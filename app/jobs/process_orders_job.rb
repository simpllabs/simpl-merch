 class ProcessOrdersJob < ProgressJob::Base
  def initialize

  end

  # run everyday 11:59 pm MST
  def perform

    begin
    	
    	orders = []
	    csv_string = CSV.generate do |csv|

	      	header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Order Date", "Product Name", "Shop Domain", "Shop Name", "Gender", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
	      	packing_slip = ["Packing Slip Logo URL", "Packing Slip Message"]
	      	csv << [*header, *packing_slip]

	      	Shop.where.not(stripe_customer_id: nil).each do |shop|

				session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
				ShopifyAPI::Base.activate_session(session)

				#start by checking if orders with pending payment status have been paid
				Order.where(fulfillment_status: "Pending").each do |order|
				  if order.payment_status == "pending"
				    #Do a Shopify API call to check is still pending
				    payment_status = ShopifyAPI::Order.find(order.shopify_order_id).financial_status
				    order.payment_status = payment_status
				    order.save
				  end
				end

				charge_amount = 0
				design_fee = 0
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

				    base_cost = order.gender == "male" ? 5 : 5.5
				    #base_cost = order.back_design.present? ? 7 : 6
				    #base_cost = order.multicolor == 'yes' ? base_cost + 1.5 : base_cost

				    is_US = order.country.include?("United States")
				    chose_china_post = shop.chose_china_post == "Yes"

				    if is_US
				    	base_cost = base_cost + 3
				    else
				    	if chose_china_post
					      	base_cost = base_cost + 4.5
					    else
					    	base_cost = base_cost + 7
					    end
				    end

				    if shop.shopify_domain == order.shop_domain
				      charge_amount = charge_amount + (order.quantity * base_cost)
				    end
				  end

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

				  Order.where(fulfillment_status: "Pending").each do |order|
				    if shop.shopify_domain == order.shop_domain && order.payment_status != "pending"
				      row = ["", order.country == "United States" ? "USPS" : intl_shipping, order.id, order.created_at, order.product_name, order.shop_domain, order.shop_name, order.gender, order.front_design, order.back_design, order.front_ref, order.back_ref, status, order.sku, order.light_or_dark, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, order.country]
				      packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order.name)] : ["",""]
				      csv << [*row, *packing_slip]
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






























