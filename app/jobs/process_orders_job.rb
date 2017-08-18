class ProcessOrdersJob < ProgressJob::Base
  def initialize

  end

  # run everyday 11:59 pm MST
  def perform

    csv_string = CSV.generate do |csv|

      header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Shop Domain", "Gender", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
      packing_slip = ["Packing Slip Logo URL", "Packing Slip Message"]
      csv << [*header, *packing_slip]

      Shop.where.not(stripe_customer_id: nil).each do |shop|

        charge_amount = 0
        design_fee = 0
        Order.where(fulfillment_status: "Pending").each do |order|
          #one time design fees?
          tee = Tee.where(id: order.tee_id).first
          if !tee.one_time_fee_charged
            design_fee += 3 
            tee.one_time_fee_charged = true
          end
          if !tee.back_one_time_fee_charged
            design_fee += 3 
            tee.back_one_time_fee_charged = true
          end
          tee.save

          base_cost = order.back_design.present? ? 7 : 6

          is_US = order.country.include?("United States")
          chose_china_post = shop.chose_china_post == "Yes"

          if !is_US && !chose_china_post
            base_cost = base_cost + 4
          end

          if shop.shopify_domain == order.shop_domain
            charge_amount = charge_amount + (order.quantity * base_cost)
          end



        end

        charge_amount = charge_amount + design_fee
        charge_amount = charge_amount + (charge_amount * 0.03) + 0.3 #Stripe fees
        charge_amount = charge_amount * 100 #set total to cents

        status = "In-Production"

        if charge_amount > 0 

          begin
            charge = Stripe::Charge.create(
              :amount => charge_amount.to_i,
              :currency => "usd",
              :customer => shop.stripe_customer_id,
              :receipt_email => shop.send_receipts == "Yes" ? shop.email : nil
            )
          rescue Stripe::APIConnectionError => e
            status = "#APIConnectionError: #{e.message}"
          rescue Stripe::CardError => e
            status = "#CardError: #{e.message}"
            #send shop owner email here saying their card is invalid, say will try again in 10 hour intervals 3 times
          rescue Stripe::AuthenticationError => e
            status = "#AuthenticationError: #{e.message}"
          rescue Stripe::InvalidRequestError => e
            status = "#InvalidRequestError: #{e.message}"
          rescue Stripe::StripeError => e
            status = "#StripeError: #{e.message}"
          rescue Stripe::APIError => e
            status = "#APIError: #{e.message}"
          rescue Stripe::ValidationError => e
            status = "#ValidationError: #{e.message}"
          end

          intl_shipping = (shop.chose_china_post == "No" || shop.chose_china_post.blank?) ? "USPS" : "China Post"

          Order.where(fulfillment_status: "Pending").each do |order|
            if shop.shopify_domain == order.shop_domain
              row = ["", order.country == "United States" ? "USPS" : intl_shipping, order.id, order.shop_domain, order.gender, order.front_design, order.back_design, order.front_ref, order.back_ref, status, order.sku, order.light_or_dark, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, order.country]
              packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order.name)] : ["",""]
              csv << [*row, *packing_slip]
              order.processed = true
              order.fulfillment_status = status
              order.save

              updateInvetoryTables(order.gender, order.quantity, order.sku) if status == "In-Production"
            end
          end
        end
      end #shop each end

    end #csv_string end
    
    #send out email
    CsvOrdersMailer.csv_file_email(csv_string).deliver_now

  end

  def updateInvetoryTables(gender, quantity, sku)
    sku_convention = sku.split('-').reverse.join('_').downcase

    if gender == "female"
      record = FemaleInventory.all.first
      record["#{sku_convention}"] -= quantity.to_i
      record.save
    else
      record = MaleInventory.all.first
      record["#{sku_convention}"] -= quantity.to_i
      record.save
    end
  end

end






























