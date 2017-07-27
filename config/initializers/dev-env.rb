unless Rails.env.production?
  ENV['SHOPIFY_CLIENT_API_KEY'] = 'b8aa87575bc271fc4d37c45144bffcec'
  ENV['SHOPIFY_CLIENT_API_SECRET'] = 'fbd1e309106755cfd034ee6d21c44a91'
end