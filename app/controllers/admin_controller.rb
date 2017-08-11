class AdminController < ApplicationController
 	layout "admin"

  	def admin
  		if params[:admin_pw] == "2145py7@NP$&YR@N$(&P!(GFGPNGP@N~PG&$GN&@"
  			session[:logged_in] = true
  			flash[:notice] = nil
  		else
  			flash[:notice] = "Incorrect key." if !session[:logged_in]
			  flash[:type] = "danger" if !session[:logged_in]
  		end

      @extention_links = ""
      Shop.all.sort_by(&:updated_at).reverse.each do |shop|
        @extention_links = @extention_links + "<tr><td>#{shop.shopify_domain}</td><td>#{shop.trial_extention_link}</td></tr>"
      end
      

  	end

  	def upload_tracking
  		@incoming_file = params[:spreadsheet]
  		file_name = params[:spreadsheet].original_filename
  		FileUtils.mv @incoming_file.tempfile, "#{ENV['STORAGE_URL']}/#{file_name}"

  		Delayed::Job.enqueue UploadTrackingNumbersJob.new("#{ENV['STORAGE_URL']}/#{file_name}")

  		flash[:notice] = "Tracking numbers being uploaded in the background."
  		flash[:type] = "success"
  		redirect_to "/admin"
  	end

  	def add_inventory
  		@incoming_file = params[:inventory]
  		file_name = params[:inventory].original_filename
		FileUtils.mv @incoming_file.tempfile, "#{ENV['STORAGE_URL']}/#{file_name}"

		Delayed::Job.enqueue AddInventoryJob.new("#{ENV['STORAGE_URL']}/#{file_name}")

		flash[:notice] = "Adding inventory: Refresh page in a few seconds."
		flash[:type] = "success"
		redirect_to "/admin"

		#male_inventory = MaleInventory.all.first
        #female_inventory = FemaleInventory.all.first
		#arr_of_arrs = CSV.read("db/inventory/#{file_name}")
		#redirect_to :controller => 'admin', :action => 'admin', :param1 => arr_of_arrs[1]
  	end

    def extend_trial_period 
      Delayed::Job.enqueue ExtendTrialPeriod.new(params)
    end
end
