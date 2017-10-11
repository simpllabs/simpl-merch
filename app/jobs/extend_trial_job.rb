class ExtendTrialJob < ProgressJob::Base
  def initialize(shop_domain)
    @shop_domain = shop_domain
  end

  def perform
    begin
      #token = Shop.where(shopify_domain: "6dollartees-dev-store.myshopify.com").first.shopify_token

      #session = ShopifyAPI::Session.new("6dollartees-dev-store.myshopify.com", token)
      #ShopifyAPI::Base.activate_session(session)

      shop = Shop.where(shopify_domain: @shop_domain).first

      token = shop.shopify_token

      session = ShopifyAPI::Session.new(@shop_domain, token)
      ShopifyAPI::Base.activate_session(session)

      install_date = Date.parse ShopifyAPI::RecurringApplicationCharge.current.created_at

      diff = 10 - (Date.today - install_date).to_i

      if diff > 0 
        recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
          name: "Rocketees",
          price: 25,
          return_url: "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps\/#{ENV['SHOPIFY_CLIENT_API_KEY']}\/activatecharge",
          test: true,
          trial_days: diff,
          capped_amount: 25,
          terms: "$25 charged monthly")

        recurring_application_charge.save
      end

      #send this link back to admin area
      shop.trial_extention_link = diff > 0 ? recurring_application_charge.confirmation_url : "Already got 10 day trial"
      shop.save
    rescue Exception => e
      job_title = "extend_trial_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end

  end
end