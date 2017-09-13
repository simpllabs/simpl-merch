ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.scope = "read_orders, write_orders, read_products, write_products, read_script_tags, write_script_tags"
  config.embedded_app = true

  config.webhooks = [
    {topic: 'orders/create', address: "#{ENV['APP_URL']}/custom_webhooks/orders_create"},
    {topic: 'orders/cancelled', address: "#{ENV['APP_URL']}/custom_webhooks/orders_cancel"},
	  {topic: 'app/uninstalled', address: "#{ENV['APP_URL']}/custom_webhooks/app_uninstalled"}
  ]

  config.after_authenticate_job = { job: InstalledAppJob }
  config.scripttags = [
    {event: 'onload', src: "https://app.rocketees.com/assets/img_size.js"}
  ]
  
end
