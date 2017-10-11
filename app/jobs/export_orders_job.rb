class ExportOrdersJob < ProgressJob::Base
  def initialize(params, domain, token, email)
    @params = params
    @domain = domain
    @token = token
    @email = email
  end

  def perform
    begin
      csv_string = CSV.generate do |csv|
        csv << ["Order ID", "Shop Domain", "Status", "Product", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]

        from_date = Date.strptime(@params[:from_date], "%m/%d/%Y")
        to_date = Date.strptime(@params[:to_date], "%m/%d/%Y")

        Order.where(created_at: from_date..to_date).each do |order|
          if order.shop_domain == @domain
            csv << [order.id, order.shop_domain, order.fulfillment_status, order.product_name, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, order.country]
          end
        end

      end

      CsvOrdersExportMailer.csv_file_email(csv_string, @email).deliver_now
    rescue Exception => e
      job_title = "export_orders_job.rb"
      log_data_1 = e.message
      log_data_2 = e.backtrace

      ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end

  end
end