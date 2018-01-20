class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token
 	layout "admin"

  	def admin
  		if params[:admin_pw] == "2145py7@NP$&YR@N$(&P!(GFGPNGP@N~PG&$GN&@"
  			session[:logged_in] = true
  			flash[:notice] = nil
  		else
  			flash[:notice] = "Incorrect key." if !session[:logged_in]
			  flash[:type] = "danger" if !session[:logged_in]
  		end

      #@extention_links = ""
      #Shop.all.sort_by(&:updated_at).reverse.each do |shop|
      #  @extention_links = @extention_links + "<tr><td>#{shop.shopify_domain}</td><td>#{shop.trial_extention_link}</td></tr>"
      #end

      #@extention_links = @extention_links.html_safe

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

    def upload_tracking_num
      Delayed::Job.enqueue UploadTrackingNumberJob.new(params[:tracking_number], params[:order_number])

      flash[:notice] = "Tracking number being uploaded in the background."
      flash[:type] = "success"
      redirect_to "/admin"
    end

    def tracking_number_email
      begin

        #raise 'fake error'
        message_array = params[:message].split()
        order_index = message_array.index("Order:")
        tracking_index = message_array.index("Tracking:")

        order_number = message_array[order_index + 1]
        tracking_number = message_array[tracking_index + 1]

        Delayed::Job.enqueue UploadTrackingNumberJob.new(tracking_number, order_number)

        head :ok
      rescue Exception => e

        job_title = "Rocketees ERRROR: admin_controller.rb"
        log_data_1 = e.message
        log_data_2 = e.backtrace

        ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
        head 500
      end

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
      Delayed::Job.enqueue ExtendTrialJob.new(params[:shop_domain])
      
      flash[:notice] = "Creating trial extention link."
      flash[:type] = "success"
      redirect_to "/admin"
    end

    def export_orders_range 
      Delayed::Job.enqueue ExportOrdersRangeJob.new(params[:range_from], params[:range_to])
      
      flash[:notice] = "You will receive an email shortly."
      flash[:type] = "success"
      redirect_to "/admin"
    end

    def try_again_new_order

      Delayed::Job.enqueue NewOrderJob.new(params[:shop_domain], params[:order_number], true)
      
      flash[:notice] = "Creating order in the background."
      flash[:type] = "success"
      redirect_to "/admin"
    end

    def reshipment

      Delayed::Job.enqueue ResubmitOrderJob.new(params[:order_id])
      
      flash[:notice] = "Resubmitting in the background."
      flash[:type] = "success"
      redirect_to "/admin"
    end
end
