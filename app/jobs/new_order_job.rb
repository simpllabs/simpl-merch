class NewOrderJob < ProgressJob::Base
  def initialize(domain, params)
    @domain = domain
    @params = params
  end

  def perform

    session = ShopifyAPI::Session.new(@domain, @token)
    ShopifyAPI::Base.activate_session(session)

    @params[:line_items].each do |line_item|
      tee = Tee.where(shopify_product_id: line_item[:product_id]).first

      if line_item[:vendor] == "rocketees"
        order = Order.new
        order.shop_domain = @domain
        order.shopify_order_id = @params[:id]
        order.shopify_line_item_id = line_item[:id]
        order.payment_status = @params[:financial_status]
        order.fulfillment_status = "Pending"
        order.sku = line_item[:sku]

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
end