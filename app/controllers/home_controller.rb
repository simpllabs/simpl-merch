class HomeController < ShopifyApp::AuthenticatedController
    def index
        #@products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
        session[:colors] = ["Black", "Gray", "SportGray", "White"]
        session[:sizes] = ["XS", "S", "M", "L", "XL", "2XL", "3XL"]
        session[:front_name] = ""
        session[:back_name] = ""
        session[:front_pos] = [0,0]
        session[:back_pos] = [0,0]
        session[:front_size] = [0,0]
        session[:back_size] = [0,0]
        session[:published] = false
        session[:gender] = nil
        session[:uuid] = SecureRandom.uuid
        session[:free_design] = false
        session[:light_or_dark] = nil
        session[:dark_exists] = false
        session[:multicolor] = nil

        @pending = Order.where(shop_domain: ShopifyAPI::Shop.current.myshopify_domain, fulfillment_status: "Pending").count
        @in_production = Order.where(shop_domain: ShopifyAPI::Shop.current.myshopify_domain, fulfillment_status: "In-Production").count
        @shipped = Order.where(shop_domain: ShopifyAPI::Shop.current.myshopify_domain, fulfillment_status: "Shipped").count
        @cancelled = Order.where(shop_domain: ShopifyAPI::Shop.current.myshopify_domain, fulfillment_status: "Cancelled").count

        create_recurring_application_charge

        @design_library = []
        @niches = []

        Dir.foreach('app/assets/images/free-designs/') do |item|
          @niches.push(item)
        end

        @niches = @niches[3..-1]

        @niches.each do |niche|
          Dir.chdir("app/assets/images/") do 
            Dir["free-designs/#{niche}/*"].each do |fname|
              @design_library.push("#{ActionController::Base.helpers.asset_path(fname)}") if fname.include?("thumbnail")
            end
          end
        end

        #@design_library = []
        #S3_BUCKET.objects(prefix: "free-designs").each do |obj|
        #    @design_library.push("#{S3_BUCKET.url}#{obj.key}") if obj.key.include?("thumbnail")
        #end
    end

    def create_recurring_application_charge
        unless ShopifyAPI::RecurringApplicationCharge.current
            recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
                    name: "Rocketees",
                    price: 25,
                    return_url: "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps\/#{ENV['SHOPIFY_CLIENT_API_KEY']}\/activatecharge",
                    test: true,
                    trial_days: 7,
                    capped_amount: 25,
                    terms: "$25 charged monthly")

            if recurring_application_charge.save
              session[:confirmation_url] = recurring_application_charge.confirmation_url
              fullpage_redirect_to recurring_application_charge.confirmation_url
            else
              session[:confirmation_url] = "failed"
            end
        end
    end

    def activatecharge
        @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
        if @recurring_application_charge.status == 'accepted'
            @recurring_application_charge.activate
            fullpage_redirect_to "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps\/#{ENV['SHOPIFY_CLIENT_API_KEY']}"
        else 
            #redirect_to the shop's admin
            fullpage_redirect_to "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps"
        end
    end
end
