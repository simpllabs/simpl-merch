class NewOrderJob < ProgressJob::Base
  def initialize(domain, params, trying_again)
    @domain = domain
    @params = params
    @trying_again = trying_again
  end

  def perform

    begin

        if @trying_again == true

            token = Shop.where(shopify_domain: @domain).first.shopify_token
            session = ShopifyAPI::Session.new(@domain, token)
            ShopifyAPI::Base.activate_session(session)

            orders = ShopifyAPI::Order.all
            num = @params
            order_params = 0
            orders.each do |order|
                if order.order_number.to_i == 32873 #num.to_i
                    order_params = order
                end
            end

            #raise "order_params: #{order_params}"

            shopify_product_id = nil
            order_params.line_items.each do |line_item|
                tee = Tee.where(shopify_product_id: line_item.product_id).first

                shopify_product_id = line_item.product_id
                if line_item.vendor == "rocketees" || line_item.vendor == "Rocketees"
                    order = Order.new
                    order.shop_domain = @domain
                    order.shopify_order_id = order_params.id
                    order.shopify_line_item_id = line_item.id
                    order.payment_status = order_params.financial_status
                    order.fulfillment_status = "Pending"
                    order.sku = line_item.sku
                    order.store_order_number = order_params.order_number
                    order.multicolor = tee.multicolor

                    parsed_lod = JSON.parse(tee.light_or_dark) if tee.light_or_dark.present?
                    color = line_item.sku.split('-').last.downcase

                    order.light_or_dark = parsed_lod[color] if tee.light_or_dark.present?
                    order.quantity = line_item.quantity
                    order.price = line_item.price
                    order.name = order_params.shipping_address.name
                    order.processed = false
                    order.address1 = order_params.shipping_address.address1
                    order.address2 = order_params.shipping_address.address2
                    order.company = order_params.shipping_address.company
                    order.city = order_params.shipping_address.city
                    order.zip = order_params.shipping_address.zip
                    order.province = order_params.shipping_address.province
                    order.country = order_params.shipping_address.country
                    order.front_design = tee.tee_front_url
                    order.back_design = tee.tee_back_url
                    order.front_ref = tee.tee_front_ref
                    order.back_ref = tee.tee_back_ref
                    order.gender = tee.gender
                    order.tee_id = tee.id
                    order.product_name = line_item.name
                    order.price = line_item.price.to_s
                    order.save
                end
            end

        else
            shopify_product_id = nil
            @params[:line_items].each do |line_item|
                tee = Tee.where(shopify_product_id: line_item[:product_id]).first

                shopify_product_id = line_item[:product_id]
                if line_item[:vendor] == "rocketees" || line_item[:vendor] == "Rocketees"
                    order = Order.new
                    order.shop_domain = @domain
                    order.shopify_order_id = @params[:id]
                    order.shopify_line_item_id = line_item[:id]
                    order.payment_status = @params[:financial_status]
                    order.fulfillment_status = "Pending"
                    order.sku = line_item[:sku]
                    order.store_order_number = @params[:order_number]
                    order.multicolor = tee.multicolor

                    parsed_lod = JSON.parse(tee.light_or_dark) if tee.light_or_dark.present?
                    color = line_item[:sku].split('-').last.downcase

                    order.light_or_dark = parsed_lod[color] if tee.light_or_dark.present?
                    order.quantity = line_item[:quantity]
                    order.price = line_item[:price]
                    order.name = @params[:shipping_address][:name]
                    order.processed = false
                    order.address1 = @params[:shipping_address][:address1]
                    order.address2 = @params[:shipping_address][:address2]
                    order.company = @params[:shipping_address][:company]
                    order.city = @params[:shipping_address][:city]
                    order.zip = @params[:shipping_address][:zip]
                    order.province = @params[:shipping_address][:province]
                    order.country = @params[:shipping_address][:country]
                    order.front_design = tee.tee_front_url
                    order.back_design = tee.tee_back_url
                    order.front_ref = tee.tee_front_ref
                    order.back_ref = tee.tee_back_ref
                    order.gender = tee.gender
                    order.tee_id = tee.id
                    order.product_name = line_item[:name]
                    order.price = line_item[:price].to_s
                    order.save
                end
            end
        end
        
    rescue Exception => e
        if @trying_again
            job_title = "new_order_job.rb STORE: #{@domain}, ORDER: #{@params}, shopify_product_id: #{shopify_product_id}"
        else
            job_title = "new_order_job.rb STORE: #{@domain}, ORDER: #{@params[:order_number]}"
        end
        
        log_data_1 = e.message
        log_data_2 = e.backtrace

        ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end
  end
end