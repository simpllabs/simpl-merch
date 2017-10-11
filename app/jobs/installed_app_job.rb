class InstalledAppJob < ActiveJob::Base

  def perform(params)
    begin

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
    rescue Exception => e
      job_title = "installed_app_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end

  end
end