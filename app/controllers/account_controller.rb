class AccountController < ShopifyApp::AuthenticatedController
  before_action :set_s3_direct_post

  def add_payment_info

    #@webhook = ShopifyAPI::Webhook.first
    #@webhook.address = "https://653cf117.ngrok.io/custom_webhooks/orders_create"
    #@webhook.save

    #@products= ShopifyAPI::Product.where(vendor: "rocketees").sort_by(&:created_at).reverse.first.handle

    @rac_def = ShopifyAPI::RecurringApplicationCharge.where("return_url like ?", "%#{'captain-bargain.myshopify.com'}%")

    @shop = Shop.where(shopify_domain: ShopifyAPI::Shop.current.myshopify_domain).first

    if params[:card_token].present? 
      begin 
  	  customer = Stripe::Customer.create(
    		  description: "Stripe customer object for: #{ShopifyAPI::Shop.current.myshopify_domain}",
    		  source: params[:card_token],
          metadata: {send_receipts: "No"}
    		)
    		
        @shop.email = ShopifyAPI::Shop.current.email
    		@shop.stripe_customer_id = customer.id
    		@shop.save
      rescue Stripe::CardError => e
        flash[:notice] = " #{e.message}"
        redirect_to '/account'
      end
    end

    @stripe_customer_id = @shop.stripe_customer_id
    @active = @stripe_customer_id.present?

    @customer = Stripe::Customer.retrieve(@stripe_customer_id) if @stripe_customer_id.present?

    path = URI.parse(URI.encode(@shop.packing_slip_logo)).path if @shop.packing_slip_logo.present?
    @logo_filename = File.basename(path) if @shop.packing_slip_logo.present?

  end

  def delete_or_update_customer
    shop = Shop.where(shopify_domain: ShopifyAPI::Shop.current.myshopify_domain).first
    stripe_customer_id = shop.stripe_customer_id

    if params[:update_btn]
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      #customer.metadata = {send_receipts: params[:send_receipts], china_post: params[:china_post]}
      #customer.save

      shop.send_receipts = params[:send_receipts]
      shop.chose_china_post = params[:china_post]

      card = customer.sources.retrieve(customer.sources.data[0].id)
      card.address_line1 = params[:billing_address]
      card.name = params[:company_name]
      card.address_city = params[:city]
      card.address_state = params[:province]
      card.address_zip = params[:zip]
      card.address_country = params[:country]
      card.save
      if params[:packing_slip] == "Yes"
        #if already have a saved logo in bucket/logos, delete it before saving new one
        if shop.packing_slip_logo.present?
          existing_logo = S3_BUCKET.object(URI.parse(URI.encode(shop.packing_slip_logo)).path[1..-1])
          existing_logo.delete
        end

        shop.packing_slip = "Yes"
        shop.packing_slip_logo = params[:packing_slip_logo].sub("tmp","logos") if params[:packing_slip_logo].present?
        shop.packing_slip_message = params[:packing_slip_message]

        path = URI.parse(URI.encode(params[:packing_slip_logo])).path

        source = S3_BUCKET.object(path[1..-1])
        target = S3_BUCKET.put_object(key: "logos/#{path[5..-1]}", acl: "public-read-write")
        source.move_to(target) if params[:packing_slip_logo].present?
      else
        shop.packing_slip = "No"
      end

      shop.save

      flash[:notice] = "Your account was updated successfully."

    else
      #delete customer from stripe
      cu = Stripe::Customer.retrieve(stripe_customer_id)
      cu.delete

      #set customer_stripe_id to null
      shop.stripe_customer_id = nil
      shop.save

    end
  
  	redirect_to '/account'
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "tmp/#{session[:uuid]}/${filename}", success_action_status: '201', acl: 'public-read')
  end


end
