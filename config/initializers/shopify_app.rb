ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.scope = "read_orders, write_orders, read_products, write_products"
  config.embedded_app = true

  config.webhooks = [
    {topic: 'orders/create', address: 'https://653cf117.ngrok.io/custom_webhooks/orders_create'},
    {topic: 'orders/cancelled', address: 'https://653cf117.ngrok.io/custom_webhooks/orders_cancel'},
	  {topic: 'app/uninstalled', address: 'https://653cf117.ngrok.io/custom_webhooks/app_uninstalled'}
  ]
  
end
