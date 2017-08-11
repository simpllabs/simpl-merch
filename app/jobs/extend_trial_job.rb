class UploadTrackingNumbersJob < ProgressJob::Base
  def initialize(params)
    @params = params
  end

  def perform

    #token = Shop.where(shopify_domain: "6dollartees-dev-store.myshopify.com").first.shopify_token

    #session = ShopifyAPI::Session.new("6dollartees-dev-store.myshopify.com", token)
    #ShopifyAPI::Base.activate_session(session)

    shop = Shop.where(shopify_domain: params[:shop_domain]).first

    token = shop.shopify_token

    session = ShopifyAPI::Session.new(params[:shop_domain], token)
    ShopifyAPI::Base.activate_session(session)

    install_date = Date.parse ShopifyAPI::RecurringApplicationCharge.current.created_at

    diff = 10 - (Date.today - install_date).to_i

    recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
      name: "Rocketees",
      price: 25,
      return_url: "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps\/#{ENV['SHOPIFY_CLIENT_API_KEY']}\/activatecharge",
      test: true,
      trial_days: diff,
      capped_amount: 25,
      terms: "$25 charged monthly")

    recurring_application_charge.save

    #send this link back to admin area
    shop.trial_extention_link = recurring_application_charge.confirmation_url
    shop.save

  end
end