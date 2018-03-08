class PackingslipController < ApplicationController
  def message
  	domain = "#{params[:storename]}.myshopify.com"
  	@message = Shop.where(shopify_domain: domain).first.packing_slip_message if Shop.where(shopify_domain: domain).present?
  end
end
