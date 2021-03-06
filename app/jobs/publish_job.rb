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

  #def before(job)
  #  @job = job
  #end

  def perform
    begin

      #0. Start new Shopify API session with token
      session = ShopifyAPI::Session.new(@domain, @token)
      ShopifyAPI::Base.activate_session(session)

      #raise "@data[:genders].join(',') : #{@data[:genders].join(',')}"

      #1. Create main product
      update_stage('Generating product...')
      new_tee = ShopifyAPI::Product.new
      new_tee.title = @params[:product_title]
      new_tee.body_html = @params[:product_description]
      new_tee.vendor = "rocketees"
      if @data[:genders].count > 1
        new_tee.options = [{"name" => "Size"}, {"name" => "Color"}, {"name" => "Gender"}]
      else
        new_tee.options = [{"name" => "Size"}, {"name" => "Color"}]
      end
      new_tee.tags = @params[:product_tags]

      #2. Create all the variants
      update_progress(step: 10)
      update_stage('Generating variants...')
      variants = []

      if @data[:genders].count > 1
        @data[:genders].each do |g|
          @data[:colors].each do |c|
            c = c == "SportGray" ? "Light Gray" : c
            c = c == "RoyalBlue" ? "Royal Blue" : c
            @data[:sizes].each do |s|
              variants.push({
                  "option1" => s,
                  "option2" => c,
                  "option3" => g,
                  "position" => "1",
                  "price" => @params[:product_price].to_f.round(2),
                  "sku" => "#{s}-#{c}-#{g}"
                })
            end
          end
        end
      else
        @data[:colors].each do |c|
          c = c == "SportGray" ? "Light Gray" : c
          c = c == "RoyalBlue" ? "Royal Blue" : c
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
      end
      new_tee.variants = variants
      new_tee.save

      #raise "variants_all: #{ShopifyAPI::Variant.find(:all, params: {product_id: new_tee.id, limit: 100})}"
      
      @tee.shopify_product_id = new_tee.id
      @tee.save # Store product id in Tee table row

      collection = ShopifyAPI::CustomCollection.find(:all, :params => { :title => @params[:add_to_collection] }).first if !@params[:add_to_collection].include?("- None -")
      collection.add_product(new_tee) if !@params[:add_to_collection].include?("- None -") && collection.present?
      collection.save if !@params[:add_to_collection].include?("- None -") && collection.present?

      # ( 2.5 Save un-resized designs to S3 )

      if @data[:front_name].present?
        obj = S3_BUCKET.put_object(key: "designs/#{@data[:uuid]}_#{@data[:front_name]}", acl: "public-read-write")
        obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:front_name]}")

        if @data[:light_or_dark].include?("dark")
          obj = S3_BUCKET.put_object(key: "designs/#{@data[:uuid]}_#{@data[:front_name].gsub('light', 'dark')}", acl: "public-read-write")
          obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:front_name].gsub('light', 'dark')}")
        end
      end
      
      if @data[:back_name].present?
        obj = S3_BUCKET.put_object(key: "designs/B#{@data[:uuid]}_#{@data[:back_name]}", acl: "public-read-write")
        obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:back_name]}")
      end

      # 3. Resize designs
      update_progress(step: 10)
      front_w = (@data[:front_size][0].to_i*1.96).round
      front_h = (@data[:front_size][1].to_i*1.96).round
      back_w = (@data[:back_size][0].to_i*1.96).round
      back_h = (@data[:back_size][1].to_i*1.96).round

      if @data[:front_name].present?
        front_design_light = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{File.basename(@data[:front_name])}")
        front_design_light.resize("#{front_w}")

        front_design_dark = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{File.basename(@data[:front_name].gsub('light', 'dark'))}") if @data[:light_or_dark].include?("dark")
        front_design_dark.resize("#{front_w}") if @data[:light_or_dark].include?("dark")
      end

      back_design = nil
      if @data[:back_name].present?
        back_design = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{File.basename(@data[:back_name])}")
        back_design.resize("#{back_w}") 
      end

      # 4. Iterate through colors and create images with overlay (with displacement on the folds)
      # => Store all mockups in S3 /tmp, and delete afterwards
      update_progress(step: 10)
      update_stage('Generating product images...')

      back_multiplier = @data[:back_name].present? ? 2 : 1
      progress_count = (70 / (@data[:genders].count * @data[:colors].count * back_multiplier)).round
      for_later = @data[:genders].count * @data[:colors].count * back_multiplier
      #progress_count = (70 / (@data[:genders].count * @data[:colors].count/2)).round if @data[:back_name].present?

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

      parsed_lod = @data[:light_or_dark].present? ? JSON.parse(@data[:light_or_dark]) : "light"

      #pre = @data[:genders].include? ==  2 ? "" : "f_"
      # pre_k = for when doing kids tees


      @data[:genders].each do |gender|
        pre = gender == "Male" ? "" : "f_"
        pre = "k_" if gender == "Kids"

        @data[:colors].each do |color|

          if @data[:front_name].present?
            front_design = parsed_lod[color.downcase] == "light" ? front_design_light : front_design_dark

            #add new stuff
            FileUtils.cp("app/assets/images/#{pre}#{color.downcase}_mockup_f.png", "#{ENV['STORAGE_URL']}/#{f_uuid}_#{pre}#{color.downcase}_mockup_f.png")
            #end new stuff
            mockup_f  = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{f_uuid}_#{pre}#{color.downcase}_mockup_f.png")

            #mockup_f  = MiniMagick::Image.open("app/assets/images/#{pre}#{color.downcase}_mockup_f.png")
            #mockup_b  = MiniMagick::Image.open("app/assets/images/#{pre}#{color.downcase}_mockup_b.png") if @data[:back_name].present?

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

            color_tmp = color == "SportGray" ? "Light Gray" : color
            color_tmp = color == "RoyalBlue" ? "Royal Blue" : color_tmp

            variants_all = ShopifyAPI::Variant.find(:all, params: {product_id: new_tee.id, limit: 200}) # This is an array of ShopifyAPI::Variant objects
            variants_one_color = []
            variants_all.each do |v|
              if @data[:genders].count > 1
                variants_one_color.push(v.id) if v.option2 == color_tmp && v.option3 == gender
              else
                variants_one_color.push(v.id) if v.option2 == color_tmp
              end
            end
            new_tee_img_f = ShopifyAPI::Image.new(:product_id => new_tee.id) 
            new_tee_img_f.attach_image(mockup_f_done.to_blob)
            new_tee_img_f.variant_ids = variants_one_color
            new_tee_img_f.save

            #if color == "Purple"
            #  raise "Color: #{color}. variants_one_color: #{variants_one_color.length}"
            #end

          end

          update_progress(step: progress_count)


          if @data[:back_name].present?
            FileUtils.cp("app/assets/images/#{pre}#{color.downcase}_mockup_b.png", "#{ENV['STORAGE_URL']}/#{b_uuid}_#{pre}#{color.downcase}_mockup_b.png")
            mockup_b  = MiniMagick::Image.new("#{ENV['STORAGE_URL']}/#{b_uuid}_#{pre}#{color.downcase}_mockup_b.png")
            
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
      end

      #update_progress_max(100)
      #update_progress(step: 100)
      remaining = 70 - (for_later * progress_count)
      update_progress(step: remaining)
      update_stage('Successfully published!')

      #DO THIS AFTER 100% ON FRONT-END

      #5. Store reference images based on last mockups
      S3_BUCKET.put_object(body: mockup_f_done.to_blob, key: "designs/REF-#{@data[:ref_uuid]}", acl: "public-read-write") if @data[:front_name].present?
      S3_BUCKET.put_object(body: mockup_b_done.to_blob, key: "designs/REF-B-#{@data[:ref_uuid]}", acl: "public-read-write") if @data[:back_name].present?

      #6. Delete local versions
      if @data[:front_name].present?
        #obj = S3_BUCKET.put_object(key: "designs/#{@data[:uuid]}_#{@data[:front_name]}", acl: "public-read-write")
        #obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:front_name]}")
        FileUtils.rm_rf("#{ENV['STORAGE_URL']}/#{f_uuid}/")
      end
      
      if @data[:back_name].present?
        #obj = S3_BUCKET.put_object(key: "designs/B#{@data[:uuid]}_#{@data[:back_name]}", acl: "public-read-write")
        #obj.upload_file("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:back_name]}")
        FileUtils.rm_rf("#{ENV['STORAGE_URL']}/#{b_uuid}/")
        FileUtils.rm("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:back_name]}") if @data[:back_name] != @data[:front_name]
      end

      # Delete here in case b is also using this one
      FileUtils.rm("#{ENV['STORAGE_URL']}/#{@data[:uuid]}_#{@data[:front_name]}") if @data[:front_name].present?


      @data[:colors].each do |color|
        FileUtils.rm("#{ENV['STORAGE_URL']}/#{f_uuid}_#{color.downcase}.png") if @data[:front_name].present?
        FileUtils.rm("#{ENV['STORAGE_URL']}/B#{b_uuid}_#{color.downcase}.png") if @data[:back_name].present?
      end

      @data[:genders].each do |gender|
        pre = gender == "Male" ? "" : "f_"
        pre = "k_" if gender == "Kids"
        @data[:colors].each do |color|
          FileUtils.rm("#{ENV['STORAGE_URL']}/#{f_uuid}_#{pre}#{color.downcase}_mockup_f.png") if @data[:front_name].present?
          FileUtils.rm("#{ENV['STORAGE_URL']}/#{b_uuid}_#{pre}#{color.downcase}_mockup_b.png") if @data[:back_name].present?
        end
      end
      
    rescue Exception => e

      new_tee.destroy

      update_stage("ERROR")

      sleep 5

      job_title = "publish_job.rb STORE: #{@domain}"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end
    

  end
end