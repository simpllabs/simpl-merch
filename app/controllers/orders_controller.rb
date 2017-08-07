class OrdersController < ShopifyApp::AuthenticatedController
  def order_export

  	@days_open = (Shop.where(shopify_domain: ShopifyAPI::Shop.current.myshopify_domain).first.created_at - Time.zone.now).to_i / 1.day
  	@today = Time.zone.now

  end

  def process_order_export
  	flash[:notice] = 'Orders export sent to your email.'

  	Delayed::Job.enqueue ExportOrdersJob.new(params, ShopifyAPI::Shop.current.myshopify_domain, Shop.where(shopify_domain: "#{ShopifyAPI::Shop.current.myshopify_domain}").first.shopify_token, Shop.where(shopify_domain: "#{ShopifyAPI::Shop.current.myshopify_domain}").first.email) 
  	redirect_to '/orders'
  end
end

