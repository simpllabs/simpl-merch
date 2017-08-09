class InstalledAppJob < ActiveJob::Base

  def perform(params)

  	token = Shop.where(shopify_domain: params[:shop_domain]).first.shopify_token

  	session = ShopifyAPI::Session.new(shop_domain, token)
    ShopifyAPI::Base.activate_session(session)

    name = ShopifyAPI::Shop.current.shop_owner.partition(" ").first
    email = ShopifyAPI::Shop.current.email

  	#Send out welcome email
    FirstInstallMailer.welcome_email(name, email).deliver_now
  end
end