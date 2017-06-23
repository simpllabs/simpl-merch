ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = "b8aa87575bc271fc4d37c45144bffcec"
  config.secret = "fbd1e309106755cfd034ee6d21c44a91"
  config.scope = "read_orders, read_products"
  config.embedded_app = true
end
