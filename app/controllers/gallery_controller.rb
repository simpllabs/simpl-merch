class GalleryController < ShopifyApp::AuthenticatedController
  def gallery
  	@niches = []
  	@images = []

    Dir.foreach('app/assets/images/free-designs/') do |item|
      @niches.push(item)
    end

    @niches = @niches[3..-1]

    @niches.each do |niche|
      Dir.chdir("app/assets/images/") do 
        Dir["free-designs/#{niche}/*"].each do |fname|
          @images.push("<div style='display:none' class='col-sm-3 img-div #{niche.downcase}'><div class='img-wrapper'> <img class='gallery-img' src='#{ActionController::Base.helpers.asset_path(fname)}'> </div></div>") if fname.include?("thumbnail")
        end
      end
    end

  	#@objects = S3_BUCKET.objects(prefix: 'free-designs/').each do |obj|
  	#	@niches.push(obj.key.split('/')[1]) if !@niches.include?(obj.key.split('/')[1])
  	#	@images.push("<div style='display:none' class='col-sm-3 img-div #{obj.key.split('/')[1].downcase}'><div class='img-wrapper'><img class='gallery-img' src='https://rocketees-dev.s3.us-east-2.amazonaws.com/#{obj.key}'></div></div>") if obj.key.include?("thumbnail")
  	#end

  end
end


