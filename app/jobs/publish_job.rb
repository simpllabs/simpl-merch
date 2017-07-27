require "base64"

class PublishJob < ProgressJob::Base
  def initialize(progress_max, params, data, domain, token, tee)
    @progress_max = progress_max
    @params = params
    @data = data
    @domain = domain
    @token = token
    @tee = tee
  end

  def perform
    #0. Start new Shopify API session with token
    session = ShopifyAPI::Session.new(@domain, @token)
    ShopifyAPI::Base.activate_session(session)

    #1. Create main product
    update_stage('Generating product...')
    new_tee = ShopifyAPI::Product.new
    new_tee.title = @params[:product_title]
    new_tee.body_html = @params[:product_description]
    new_tee.vendor = "rocketees"
    new_tee.options = [{"name" => "Size"}, {"name" => "Color"}]
    new_tee.tags = @params[:product_tags]

    #2. Create all the variants
    update_progress(step: 10)
    update_stage('Generating variants...')
    variants = []
    @data[:colors].each do |c|
      @data[:sizes].each do |s|
        variants.push({
            "option1" => s,
            "option2" => c,
            "position" => "1",
            "price" => @params[:product_price].to_f.round(2),
            "sku" => "#{s}-#{c}"
          })
      end
    end
    new_tee.variants = variants
    new_tee.save
    
    @tee.shopify_product_id = new_tee.id
    @tee.save # Store product id in Tee table row

    collection = ShopifyAPI::CustomCollection.find(:all, :params => { :title => @params[:add_to_collection] }).first if !@params[:add_to_collection].include?("- None -")
    collection.add_product(new_tee) if !@params[:add_to_collection].include?("- None -")
    collection.save if !@params[:add_to_collection].include?("- None -")

    # 3. Resize designs
    update_progress(step: 10)
    front_w = (@data[:front_size][0].to_i*1.96).round
    front_h = (@data[:front_size][1].to_i*1.96).round
    back_w = (@data[:back_size][0].to_i*1.96).round
    back_h = (@data[:back_size][1].to_i*1.96).round

    front_design = MiniMagick::Image.open("app/assets/images/tmp/#{@data[:uuid]}_#{File.basename(@data[:front_name])}")
    front_design.resize("#{front_w}")

    back_design = nil
    if @data[:back_name].present?
      back_design = MiniMagick::Image.open("app/assets/images/tmp/#{@data[:uuid]}_#{File.basename(@data[:back_name])}")
      back_design.resize("#{back_w}") 
    end

    # 4. Iterate through colors and create images with overlay (with displacement on the folds)
    # => Store all mockups in S3 /tmp, and delete afterwards
    update_progress(step: 10)
    update_stage('Generating product images...')
    progress_count = (70/@data[:colors].count).round
    progress_count = (70/@data[:colors].count/2).round if @data[:back_name].present?
    pre_f = @data[:gender] == "male" ? "" : "f_"

    front_x = (@data[:front_pos][0].to_i*1.96).round
    front_y = (@data[:front_pos][1].to_i*1.96).round

    back_x = (@data[:back_pos][0].to_i*1.96).round
    back_y = (@data[:back_pos][1].to_i*1.96).round

    mockup_f_done = nil
    mockup_b_done = nil
    result_f = nil
    result_b = nil

    f_uuid = SecureRandom.uuid
    b_uuid = SecureRandom.uuid

    @data[:colors].each do |color|

      mockup_f  = MiniMagick::Image.open("app/assets/images/#{pre_f}#{color.downcase}_mockup_f.png")
      mockup_b  = MiniMagick::Image.open("app/assets/images/#{pre_f}#{color.downcase}_mockup_b.png") if @data[:back_name].present?

      if result_f.blank? 
        FileUtils.mkdir("app/assets/images/tmp/#{f_uuid}/")
        FileUtils.cp('bin/tshirt', "app/assets/images/tmp/#{f_uuid}/")
        FileUtils.cp('bin/tshirtwarp', "app/assets/images/tmp/#{f_uuid}/")
        text = File.read("app/assets/images/tmp/#{f_uuid}/tshirtwarp")

        Dir.chdir("app/assets/images/tmp/#{f_uuid}/") do 
          result_f = `./tshirt -r #{front_w}x#{front_h}+#{front_y}+#{front_x} -s 0 -E #{front_design.path} #{mockup_f.path} ../#{f_uuid}_#{color.downcase}.png`
        end
        
        replace = text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).gsub(/-- REPLACE IN CODE WITH REGEX --/, result_f)
        File.open("app/assets/images/tmp/#{f_uuid}/tshirtwarp", "w") {|file| file.puts replace}
      else
        Dir.chdir("app/assets/images/tmp/#{f_uuid}/") do 
          `./tshirtwarp ./lighting.png ./displace.png #{front_design.path} #{mockup_f.path} ../#{f_uuid}_#{color.downcase}.png`
        end
      end

      mockup_f_done = MiniMagick::Image.new("app/assets/images/tmp/#{f_uuid}_#{color.downcase}.png")

      variants_all = ShopifyAPI::Variant.find(:all, params: {product_id: new_tee.id}) # This is an array of ShopifyAPI::Variant objects
      variants_one_color = []
      variants_all.each do |v| 
        variants_one_color.push(v.id) if v.option2 == color
      end
      new_tee_img_f = ShopifyAPI::Image.new(:product_id => new_tee.id) 
      new_tee_img_f.attach_image(mockup_f_done.to_blob)
      new_tee_img_f.variant_ids = variants_one_color
      new_tee_img_f.save

      update_progress(step: progress_count)

      if @data[:back_name].present?
        if result_b.blank? 
          FileUtils.mkdir("app/assets/images/tmp/#{b_uuid}/")
          FileUtils.cp('bin/tshirt', "app/assets/images/tmp/#{b_uuid}/")
          FileUtils.cp('bin/tshirtwarp', "app/assets/images/tmp/#{b_uuid}/")
          text = File.read("app/assets/images/tmp/#{b_uuid}/tshirtwarp")

          Dir.chdir("app/assets/images/tmp/#{b_uuid}/") do 
            result_b = `./tshirt -r #{back_w}x#{back_h}+#{back_y}+#{back_x} -s 0 -E #{back_design.path} #{mockup_b.path} ../B#{b_uuid}_#{color.downcase}.png`
          end

          replace = text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).gsub(/-- REPLACE IN CODE WITH REGEX --/, result_b)
          File.open("app/assets/images/tmp/#{b_uuid}/tshirtwarp", "w") {|file| file.puts replace}
        else
          Dir.chdir("app/assets/images/tmp/#{b_uuid}/") do 
            `./tshirtwarp ./lighting.png ./displace.png #{back_design.path} #{mockup_b.path} ../B#{b_uuid}_#{color.downcase}.png`
          end
        end

        mockup_b_done = MiniMagick::Image.new("app/assets/images/tmp/B#{b_uuid}_#{color.downcase}.png")
        new_tee_img_b = ShopifyAPI::Image.new(:product_id => new_tee.id)
        new_tee_img_b.attach_image(mockup_b_done.to_blob)
        new_tee_img_b.save

        update_progress(step: progress_count)
      end


    end

    update_progress_max(100)
    update_progress_max(step: 100)
    update_stage('Successfully published!')

    #DO THIS AFTER 100% ON FRONT-END

    #5. Store reference images based on last mockups
    S3_BUCKET.put_object(body: mockup_f_done.to_blob, key: "designs/REF-#{@data[:ref_uuid]}", acl: "public-read-write")
    S3_BUCKET.put_object(body: mockup_b_done.to_blob, key: "designs/REF-B-#{@data[:ref_uuid]}", acl: "public-read-write") if @data[:back_name].present?

    #6. Save designs to S3, and delete local ones
    obj = S3_BUCKET.put_object(key: "designs/#{@data[:uuid]}_#{@data[:front_name]}", acl: "public-read-write")
    obj.upload_file("app/assets/images/tmp/#{@data[:uuid]}_#{@data[:front_name]}")
    FileUtils.rm_rf("app/assets/images/tmp/#{f_uuid}/")
    
    if @data[:back_name].present?
      obj = S3_BUCKET.put_object(key: "designs/B#{@data[:uuid]}_#{@data[:back_name]}", acl: "public-read-write")
      obj.upload_file("app/assets/images/tmp/#{@data[:uuid]}_#{@data[:back_name]}")
      FileUtils.rm_rf("app/assets/images/tmp/#{b_uuid}/")
      FileUtils.rm("app/assets/images/tmp/#{@data[:uuid]}_#{@data[:back_name]}") if @data[:back_name] != @data[:front_name]
    end

    # Delete here in case b is also using this one
    FileUtils.rm("app/assets/images/tmp/#{@data[:uuid]}_#{@data[:front_name]}")

    @data[:colors].each do |color|
      FileUtils.rm("app/assets/images/tmp/#{f_uuid}_#{color.downcase}.png")
      FileUtils.rm("app/assets/images/tmp/B#{b_uuid}_#{color.downcase}.png") if @data[:back_name].present?
    end

    

  end
end