class InstalledAppJob < ActiveJob::Base

  def perform(params)

  	shop = Shop.where(shopify_domain: params[:shop_domain]).first
  	token = shop.shopify_token

  	session = ShopifyAPI::Session.new(params[:shop_domain], token)
    ShopifyAPI::Base.activate_session(session)

    name = ShopifyAPI::Shop.current.shop_owner.partition(" ").first
    email = ShopifyAPI::Shop.current.email

  	#Send out welcome email
    FirstInstallMailer.welcome_email(name, email).deliver_now if shop.install_email_sent.blank?
    shop.install_email_sent = true
    shop.save

    ShopifyAPI::ScriptTag.create({:src => "https://app.rocketees.com/img_size.js", :event => 'onload'})
  end
end