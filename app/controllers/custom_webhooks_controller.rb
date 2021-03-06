class CustomWebhooksController < ApplicationController
  include ShopifyApp::WebhookVerification

  def orders_create
  	Delayed::Job.enqueue NewOrderJob.new(shop_domain, params, false)
    head :ok
  end

  def orders_cancel
  	Delayed::Job.enqueue CancelOrderJob.new(shop_domain, params)
    head :ok
  end

  def app_uninstalled
  	Delayed::Job.enqueue AppUninstalledJob.new(shop_domain, params)
    head :ok
  end

end