class UploadTrackingNumbersJob < ProgressJob::Base
  def initialize(params)
    @params = params
  end

  def perform

    token = Shop.where(shopify_domain: params[:shop_domain]).first.shopify_token

    session = ShopifyAPI::Session.new(params[:shop_domain], token)
    ShopifyAPI::Base.activate_session(session)

    rac_def = ShopifyAPI::RecurringApplicationCharge

  end
end