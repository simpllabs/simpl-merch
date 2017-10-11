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
    begin
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
      collection.add_product(new_tee) if !@params[:add_to_collection].include?("- None -") && collection.present?
      collection.save if !@params[:add_to_collection].include?("- None -") && collection.present?

      # 3. Resize designs
      update_progress(step: 10)
      front_w = (@data[:front_size][0].to_i*1.96).round
      front_h = (@data[:front_size][1].to_i*1.96).round
      back_w = (@data[:back_size][0].to_i*1.96).round
      back_h = (@data[:back_size][1].to_i*1.96).round


      front_design_light = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{File.basename(@data[:front_name])}")
      front_design_light.resize("#{front_w}")

      front_design_dark = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{File.basename(@data[:front_name].gsub('light', 'dark'))}") if @data[:light_or_dark].include?("dark")
      front_design_dark.resize("#{front_w}") if @data[:light_or_dark].include?("dark")

      back_design = nil
      if @data[:back_name].present?
        back_design = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{File.basename(@data[:back_name])}")
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

      parsed_lod = JSON.parse(@data[:light_or_dark])

      @data[:colors].each do |color|

        front_design = parsed_lod[color.downcase] == "light" ? front_design_light : front_design_dark

        #add new stuff
        FileUtils.cp("app/assets/images/#{pre_f}#{color.downcase}_mockup_f.png", "#{ENV['STORAGE_URL']}/#{f_uuid}_#{pre_f}#{color.downcase}_mockup_f.png")
        FileUtils.cp("app/assets/images/#{pre_f}#{color.downcase}_mockup_b.png", "#{ENV['STORAGE_URL']}/#{b_uuid}_#{pre_f}#{color.downcase}_mockup_b.png") if @data[:back_name].present?
        #end new stuff

        mockup_f  = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{f_uuid}_#{pre_f}#{color.downcase}_mockup_f.png")
        mockup_b  = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{b_uuid}_#{pre_f}#{color.downcase}_mockup_b.png") if @data[:back_name].present?

        #mockup_f  = MiniMagick::Image.open("app/assets/images/#{pre_f}#{color.downcase}_mockup_f.png")
        #mockup_b  = MiniMagick::Image.open("app/assets/images/#{pre_f}#{color.downcase}_mockup_b.png") if @data[:back_name].present?

        if result_f.blank? 
          FileUtils.mkdir("#{ENV['STORAGE_URL']}/#{f_uuid}/")
          FileUtils.cp('bin/tshirt', "#{ENV['STORAGE_URL']}/#{f_uuid}/")
          FileUtils.cp('bin/tshirtwarp', "#{ENV['STORAGE_URL']}/#{f_uuid}/")
          text = File.read("#{ENV['STORAGE_URL']}/#{f_uuid}/tshirtwarp")

          Dir.chdir("#{ENV['STORAGE_URL']}/#{f_uuid}/") do 
            result_f = `./tshirt -r #{front_w}x#{front_h}+#{front_y}+#{front_x} -b 0 -l 25 -E ../#{File.basename(front_design.path)} ../#{File.basename(mockup_f.path)} ../#{f_uuid}_#{color.downcase}.png`
            #result_f = `./tshirt -r #{front_w}x#{front_h}+#{front_y}+#{front_x} -b 0 -l 25 -E ../#{File.basename(front_design.path)} #{mockup_f.path} ../#{f_uuid}_#{color.downcase}.png`
            #TestMailMailer.test_email("./tshirt -r #{front_w}x#{front_h}+#{front_y}+#{front_x} -s 1 -E #{front_design.path} #{mockup_f.path} ../#{f_uuid}_#{color.downcase}.png").deliver_now
          end
          
          replace = text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).gsub(/-- REPLACE IN CODE WITH REGEX --/, result_f)
          File.open("#{ENV['STORAGE_URL']}/#{f_uuid}/tshirtwarp", "w") {|file| file.puts replace}
        else
          Dir.chdir("#{ENV['STORAGE_URL']}/#{f_uuid}/") do 
            `./tshirtwarp ./lighting.png ./displace.png ../#{File.basename(front_design.path)} ../#{File.basename(mockup_f.path)} ../#{f_uuid}_#{color.downcase}.png`
            #`./tshirtwarp ./lighting.png ./displace.png ../#{File.basename(front_design.path)} #{mockup_f.path} ../#{f_uuid}_#{color.downcase}.png`
          end
        end

        mockup_f_done = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{f_uuid}_#{color.downcase}.png")

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
            FileUtils.mkdir("#{ENV['STORAGE_URL']}/#{b_uuid}/")
            FileUtils.cp('bin/tshirt', "#{ENV['STORAGE_URL']}/#{b_uuid}/")
            FileUtils.cp('bin/tshirtwarp', "#{ENV['STORAGE_URL']}/#{b_uuid}/")
            text = File.read("#{ENV['STORAGE_URL']}/#{b_uuid}/tshirtwarp")

            Dir.chdir("#{ENV['STORAGE_URL']}/#{b_uuid}/") do 
              result_b = `./tshirt -r #{back_w}x#{back_h}+#{back_y}+#{back_x} -s 0 -b 0 -C over -E ../#{File.basename(back_design.path)} ../#{File.basename(mockup_b.path)} ../B#{b_uuid}_#{color.downcase}.png`
              #result_b = `./tshirt -r #{back_w}x#{back_h}+#{back_y}+#{back_x} -s 0 -b 0 -C over -E ../#{File.basename(back_design.path)} #{mockup_b.path} ../B#{b_uuid}_#{color.downcase}.png`
            end

            replace = text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).gsub(/-- REPLACE IN CODE WITH REGEX --/, result_b)
            File.open("#{ENV['STORAGE_URL']}/#{b_uuid}/tshirtwarp", "w") {|file| file.puts replace}
          else
            Dir.chdir("#{ENV['STORAGE_URL']}/#{b_uuid}/") do 
              `./tshirtwarp ./lighting.png ./displace.png ../#{File.basename(back_design.path)} ../#{File.basename(mockup_b.path)} ../B#{b_uuid}_#{color.downcase}.png`
              #`./tshirtwarp ./lighting.png ./displace.png ../#{File.basename(back_design.path)} #{mockup_b.path} ../B#{b_uuid}_#{color.downcase}.png`
            end
          end

          mockup_b_done = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/B#{b_uuid}_#{color.downcase}.png")
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
      obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:front_name]}")
      FileUtils.rm_rf("#{ENV['STORAGE_URL']}/#{f_uuid}/")
      
      if @data[:back_name].present?
        obj = S3_BUCKET.put_object(key: "designs/B#{@data[:uuid]}_#{@data[:back_name]}", acl: "public-read-write")
        obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:back_name]}")
        FileUtils.rm_rf("#{ENV['STORAGE_URL']}/#{b_uuid}/")
        FileUtils.rm("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:back_name]}") if @data[:back_name] != @data[:front_name]
      end

      # Delete here in case b is also using this one
      FileUtils.rm("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:front_name]}")

      @data[:colors].each do |color|
        FileUtils.rm("#{ENV['STORAGE_URL']}/#{f_uuid}_#{color.downcase}.png")
        FileUtils.rm("#{ENV['STORAGE_URL']}/B#{b_uuid}_#{color.downcase}.png") if @data[:back_name].present?
        FileUtils.rm("#{ENV['STORAGE_URL']}/#{f_uuid}_#{pre_f}#{color.downcase}_mockup_f.png")
        FileUtils.rm("#{ENV['STORAGE_URL']}/#{b_uuid}_#{pre_f}#{color.downcase}_mockup_b.png") if @data[:back_name].present?
      end
      
    rescue Exception => e
      job_title = "publish_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end 
    

  end
end