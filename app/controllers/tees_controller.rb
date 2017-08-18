class TeesController < ShopifyApp::AuthenticatedController
  before_action :set_tee, only: [:show, :edit, :update, :destroy]

  #POST tees/new/review
  def review

    #if returning from publish page, redirect to new tee right away
    if params[:commit].blank?
      reset_tee_session
      fullpage_redirect_to "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps\/#{ENV['SHOPIFY_CLIENT_API_KEY']}\/tees/new/?gender=male" 
    end

    #store params in session
    if params[:commit].present?

      session[:colors] =  [params[:checkbox_black],
                          params[:checkbox_white],
                          params[:checkbox_navy],
                          params[:checkbox_green],
                          params[:checkbox_red]] 

      session[:colors] =  session[:colors].reject { |c| c.blank? }

      session[:sizes] =   [params[:checkbox_xs],
                          params[:checkbox_s],
                          params[:checkbox_m],
                          params[:checkbox_l],
                          params[:checkbox_xl],
                          params[:checkbox_2xl],
                          params[:checkbox_3xl]] 

    session[:sizes] =   session[:sizes].reject { |c| c.blank? }

    end

    session[:front_name] = params[:front_design] if params[:front_design].present?
    session[:back_name] = params[:back_design] if params[:back_design].present?

    session[:front_pos] = params[:front_pos].split(',') if params[:front_pos].present?
    session[:back_pos] = params[:back_pos].split(',') if params[:back_pos].present?

    session[:front_size] = params[:front_size].split(',') if params[:front_size].present?
    session[:back_size] = params[:back_size].split(',') if params[:back_size].present?

    #get collections for dropdown
    @custom_collections = ShopifyAPI::CustomCollection.find(:all, params: { limit: 250 })
    @collections = "<option>- None -</option>"
    @custom_collections.each {|collection| @collections = @collections + "<option>#{collection.title}</option>"}
    @custom_collections = ShopifyAPI::SmartCollection.find(:all, params: { limit: 250 })
    @custom_collections.each {|collection| @collections = @collections + "<option>#{collection.title}</option>"}

    pre_f = session[:gender] == "male" ? "" : "f_"

    @mockup_image_f = pre_f + session[:colors].first.downcase + "_mockup_f.png"
    @mockup_image_b = pre_f + session[:colors].first.downcase + "_mockup_b.png"

    @front_pos_scaled = [0,0]
    @front_pos_scaled[0] = session[:front_pos][0].to_f * 0.627
    @front_pos_scaled[1] = session[:front_pos][1].to_f * 0.627

    @back_pos_scaled = [0,0]
    @back_pos_scaled[0] = session[:back_pos][0].to_f * 0.627
    @back_pos_scaled[1] = session[:back_pos][1].to_f * 0.627

    @front_size_scaled = [0,0]
    @front_size_scaled[0] = session[:front_size][0].to_f * 0.627 
    @front_size_scaled[1] = session[:front_size][1].to_f * 0.627

    @back_size_scaled = [0,0]
    @back_size_scaled[0] = session[:back_size][0].to_f * 0.627 
    @back_size_scaled[1] = session[:back_size][1].to_f * 0.627

    session[:light_or_dark] = params[:light_or_dark]
    parsed_lod = JSON.parse(session[:light_or_dark]) if params[:light_or_dark].present?
    @light_or_dark = parsed_lod[session[:colors].first.downcase] if params[:light_or_dark].present?

    flash[:reviewing] = true

  end

  def reset_tee_session 
    session[:colors] = ["Black", "White"]
    session[:sizes] = ["XS", "S", "M", "L", "XL", "2XL", ""]
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
  end

  def new

    if session[:published]
      reset_tee_session
    end

    unless flash[:reviewing]
      reset_tee_session
      #fullpage_redirect_to "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/apps\/#{ENV['SHOPIFY_CLIENT_API_KEY']}\/"
    end

    @free_design = false
    if params[:img_src].present?
      @free_design = true
      session[:free_design] = true
      session[:img_src] = params[:img_src]

      #copy file into tmp with uuid appended to name
      tmp_uuid = SecureRandom.uuid
      FileUtils.mkdir("#{ENV['STORAGE_URL']}/#{tmp_uuid}/")
      FileUtils.cp("app/assets/images/free-designs/#{session[:img_src]}", "#{ENV['STORAGE_URL']}/#{tmp_uuid}/")
      File.rename("#{ENV['STORAGE_URL']}/#{tmp_uuid}/#{File.basename(session[:img_src])}", "#{ENV['STORAGE_URL']}/#{session[:uuid]}_#{File.basename(session[:img_src])}")

      if Pathname.new("app/assets/images/free-designs/#{session[:img_src].gsub('light', 'dark')}").exist?
        FileUtils.cp("app/assets/images/free-designs/#{session[:img_src].gsub('light', 'dark')}", "#{ENV['STORAGE_URL']}/#{tmp_uuid}/") 
        File.rename("#{ENV['STORAGE_URL']}/#{tmp_uuid}/#{File.basename(session[:img_src].gsub('light', 'dark'))}", "#{ENV['STORAGE_URL']}/#{session[:uuid]}_#{File.basename(session[:img_src].gsub('light', 'dark'))}")
        session[:dark_exists] = true
      end
      
      FileUtils.rmdir("#{ENV['STORAGE_URL']}/#{tmp_uuid}/")

      session[:front_name] = File.basename(session[:img_src])

    end
     
    gon.light_or_dark = session[:light_or_dark]

    session[:gender] = "male" if session[:gender].blank?
    session[:gender] = params[:gender] if params[:gender].present?

    if session[:gender] == "female"
      session[:sizes][4] = ""
    end

    @stripe_customer_id = Shop.where(shopify_domain: ShopifyAPI::Shop.current.myshopify_domain).first.stripe_customer_id
  end

  def view_tee
    product_id = ShopifyAPI::Product.where(vendor: "rocketees").sort_by(&:created_at).reverse.first.id
    fullpage_redirect_to "https:\/\/#{ShopifyAPI::Shop.current.myshopify_domain}\/admin\/products\/#{product_id}\/"
  end

  def increment_publish
    job = Delayed::Job.where(id: params[:id]).first
    job.progress_current = job.progress_current + 1;
    job.save
  end

  def publish
    session[:published] = true

    ref_uuid = SecureRandom.uuid

    #upload tee data into db
    @tee = Tee.new
    @tee.tee_front_url = "#{S3_BUCKET.url}/designs/#{session[:uuid]}_#{session[:front_name]}"
    @tee.tee_back_url = "#{S3_BUCKET.url}/designs/B#{session[:uuid]}_#{session[:back_name]}" if session[:back_name].present?
    @tee.tee_front_ref = "#{S3_BUCKET.url}/designs/REF-#{ref_uuid}"
    @tee.tee_back_ref = "#{S3_BUCKET.url}/designs/REF-B-#{ref_uuid}" if session[:back_name].present?
    @tee.shop_domain = ShopifyAPI::Shop.current.myshopify_domain
    @tee.gender = session[:gender]
    @tee.one_time_fee_charged = session[:free_design]
    @tee.back_one_time_fee_charged = session[:back_name].present? ? false : true
    @tee.light_or_dark = session[:light_or_dark]
    @tee.save

    #store session values
    @data = {}
    @data[:gender] = session[:gender]
    @data[:colors] = session[:colors]
    @data[:sizes] = session[:sizes]
    @data[:front_name] = session[:front_name]
    @data[:back_name] = session[:back_name]
    @data[:tee_front_filename] = session[:tee_front_filename]
    @data[:tee_back_filename] = session[:tee_back_filename]
    @data[:front_pos] = session[:front_pos]
    @data[:back_pos] = session[:back_pos]
    @data[:front_size] = session[:front_size]
    @data[:back_size] = session[:back_size]
    @data[:uuid] = session[:uuid]
    @data[:light_or_dark] = session[:light_or_dark]
    @data[:ref_uuid] = ref_uuid

    #enqueu the publishing of the tee 
    @job = Delayed::Job.enqueue PublishJob.new(100, params, @data, ShopifyAPI::Shop.current.myshopify_domain, Shop.where(shopify_domain: "#{ShopifyAPI::Shop.current.myshopify_domain}").first.shopify_token, @tee) 
    
  end

  def design_upload_callback
    if params[:file].present?
      # Create a new Survey object based on the received parameters...
      tmp_uuid = SecureRandom.uuid
      FileUtils.mkdir("#{ENV['STORAGE_URL']}/#{tmp_uuid}/")
      FileUtils.cp(params[:file].tempfile.path, "#{ENV['STORAGE_URL']}/#{tmp_uuid}/")
      File.rename("#{ENV['STORAGE_URL']}/#{tmp_uuid}/#{File.basename(params[:file].tempfile.path)}", "#{ENV['STORAGE_URL']}/#{session[:uuid]}_#{params[:file].original_filename}")
      FileUtils.rmdir("#{ENV['STORAGE_URL']}/#{tmp_uuid}/")

      #design_uploader = DesignsUploader.new
      #design_uploader.filename("sss#{session[:uuid]}")
      #design_uploader.store!(params[:file].tempfile)

      head :ok

    else
      head :internal_server_error
    end
    
  end

  def return_stored_image
    File.open("#{ENV['STORAGE_URL']}/#{params[:image]}.png", 'rb') do |f|
      send_data f.read, :type => "image/png", :disposition => "inline"
    end
  end


end
