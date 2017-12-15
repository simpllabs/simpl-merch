class ProcessOrdersJob < ProgressJob::Base
	def initialize

	end

	def update_color_names(sku)
		if sku.include?("Light Grey")
			return sku.sub("Light Grey", "Charcoal")
		elsif sku.include?("Grey")
			return sku.sub("Grey", "Sport Grey")
		elsif sku.include?("Green")
			return sku.sub("Green", "Irish Green")
		else
			return sku
		end
	end

	def to_country_code(country)
		COUNTRY_CODES.key(country)
	end

  	# convert country name to country code
	COUNTRY_CODES = {
		'AF'=>'Afghanistan',
		'AL'=>'Albania',
		'DZ'=>'Algeria',
		'AS'=>'American Samoa',
		'AD'=>'Andorra',
		'AO'=>'Angola',
		'AI'=>'Anguilla',
		'AQ'=>'Antarctica',
		'AG'=>'Antigua And Barbuda',
		'AR'=>'Argentina',
		'AM'=>'Armenia',
		'AW'=>'Aruba',
		'AU'=>'Australia',
		'AT'=>'Austria',
		'AZ'=>'Azerbaijan',
		'BS'=>'Bahamas',
		'BH'=>'Bahrain',
		'BD'=>'Bangladesh',
		'BB'=>'Barbados',
		'BY'=>'Belarus',
		'BE'=>'Belgium',
		'BZ'=>'Belize',
		'BJ'=>'Benin',
		'BM'=>'Bermuda',
		'BT'=>'Bhutan',
		'BO'=>'Bolivia',
		'BA'=>'Bosnia And Herzegovina',
		'BW'=>'Botswana',
		'BV'=>'Bouvet Island',
		'BR'=>'Brazil',
		'IO'=>'British Indian Ocean Territory',
		'BN'=>'Brunei',
		'BG'=>'Bulgaria',
		'BF'=>'Burkina Faso',
		'BI'=>'Burundi',
		'KH'=>'Cambodia',
		'CM'=>'Cameroon',
		'CA'=>'Canada',
		'CV'=>'Cape Verde',
		'KY'=>'Cayman Islands',
		'CF'=>'Central African Republic',
		'TD'=>'Chad',
		'CL'=>'Chile',
		'CN'=>'China',
		'CX'=>'Christmas Island',
		'CC'=>'Cocos (Keeling) Islands',
		'CO'=>'Columbia',
		'KM'=>'Comoros',
		'CG'=>'Congo',
		'CK'=>'Cook Islands',
		'CR'=>'Costa Rica',
		'CI'=>'Cote D\'Ivorie (Ivory Coast)',
		'HR'=>'Croatia (Hrvatska)',
		'CU'=>'Cuba',
		'CY'=>'Cyprus',
		'CZ'=>'Czech Republic',
		'CD'=>'Democratic Republic Of Congo (Zaire)',
		'DK'=>'Denmark',
		'DJ'=>'Djibouti',
		'DM'=>'Dominica',
		'DO'=>'Dominican Republic',
		'TP'=>'East Timor',
		'EC'=>'Ecuador',
		'EG'=>'Egypt',
		'SV'=>'El Salvador',
		'GQ'=>'Equatorial Guinea',
		'ER'=>'Eritrea',
		'EE'=>'Estonia',
		'ET'=>'Ethiopia',
		'FK'=>'Falkland Islands (Malvinas)',
		'FO'=>'Faroe Islands',
		'FJ'=>'Fiji',
		'FI'=>'Finland',
		'FR'=>'France',
		'FX'=>'France, Metropolitan',
		'GF'=>'French Guinea',
		'PF'=>'French Polynesia',
		'TF'=>'French Southern Territories',
		'GA'=>'Gabon',
		'GM'=>'Gambia',
		'GE'=>'Georgia',
		'DE'=>'Germany',
		'GH'=>'Ghana',
		'GI'=>'Gibraltar',
		'GR'=>'Greece',
		'GL'=>'Greenland',
		'GD'=>'Grenada',
		'GP'=>'Guadeloupe',
		'GU'=>'Guam',
		'GT'=>'Guatemala',
		'GN'=>'Guinea',
		'GW'=>'Guinea-Bissau',
		'GY'=>'Guyana',
		'HT'=>'Haiti',
		'HM'=>'Heard And McDonald Islands',
		'HN'=>'Honduras',
		'HK'=>'Hong Kong',
		'HU'=>'Hungary',
		'IS'=>'Iceland',
		'IN'=>'India',
		'ID'=>'Indonesia',
		'IR'=>'Iran',
		'IQ'=>'Iraq',
		'IE'=>'Ireland',
		'IL'=>'Israel',
		'IT'=>'Italy',
		'JM'=>'Jamaica',
		'JP'=>'Japan',
		'JO'=>'Jordan',
		'KZ'=>'Kazakhstan',
		'KE'=>'Kenya',
		'KI'=>'Kiribati',
		'KW'=>'Kuwait',
		'KG'=>'Kyrgyzstan',
		'LA'=>'Laos',
		'LV'=>'Latvia',
		'LB'=>'Lebanon',
		'LS'=>'Lesotho',
		'LR'=>'Liberia',
		'LY'=>'Libya',
		'LI'=>'Liechtenstein',
		'LT'=>'Lithuania',
		'LU'=>'Luxembourg',
		'MO'=>'Macau',
		'MK'=>'Macedonia',
		'MG'=>'Madagascar',
		'MW'=>'Malawi',
		'MY'=>'Malaysia',
		'MV'=>'Maldives',
		'ML'=>'Mali',
		'MT'=>'Malta',
		'MH'=>'Marshall Islands',
		'MQ'=>'Martinique',
		'MR'=>'Mauritania',
		'MU'=>'Mauritius',
		'YT'=>'Mayotte',
		'MX'=>'Mexico',
		'FM'=>'Micronesia',
		'MD'=>'Moldova',
		'MC'=>'Monaco',
		'MN'=>'Mongolia',
		'MS'=>'Montserrat',
		'MA'=>'Morocco',
		'MZ'=>'Mozambique',
		'MM'=>'Myanmar (Burma)',
		'NA'=>'Namibia',
		'NR'=>'Nauru',
		'NP'=>'Nepal',
		'NL'=>'Netherlands',
		'AN'=>'Netherlands Antilles',
		'NC'=>'New Caledonia',
		'NZ'=>'New Zealand',
		'NI'=>'Nicaragua',
		'NE'=>'Niger',
		'NG'=>'Nigeria',
		'NU'=>'Niue',
		'NF'=>'Norfolk Island',
		'KP'=>'North Korea',
		'MP'=>'Northern Mariana Islands',
		'NO'=>'Norway',
		'OM'=>'Oman',
		'PK'=>'Pakistan',
		'PW'=>'Palau',
		'PA'=>'Panama',
		'PG'=>'Papua New Guinea',
		'PY'=>'Paraguay',
		'PE'=>'Peru',
		'PH'=>'Philippines',
		'PN'=>'Pitcairn',
		'PL'=>'Poland',
		'PT'=>'Portugal',
		'PR'=>'Puerto Rico',
		'QA'=>'Qatar',
		'RE'=>'Reunion',
		'RO'=>'Romania',
		'RU'=>'Russia',
		'RW'=>'Rwanda',
		'SH'=>'Saint Helena',
		'KN'=>'Saint Kitts And Nevis',
		'LC'=>'Saint Lucia',
		'PM'=>'Saint Pierre And Miquelon',
		'VC'=>'Saint Vincent And The Grenadines',
		'SM'=>'San Marino',
		'ST'=>'Sao Tome And Principe',
		'SA'=>'Saudi Arabia',
		'SN'=>'Senegal',
		'SC'=>'Seychelles',
		'SL'=>'Sierra Leone',
		'SG'=>'Singapore',
		'SK'=>'Slovak Republic',
		'SI'=>'Slovenia',
		'SB'=>'Solomon Islands',
		'SO'=>'Somalia',
		'ZA'=>'South Africa',
		'GS'=>'South Georgia And South Sandwich Islands',
		'KR'=>'South Korea',
		'ES'=>'Spain',
		'LK'=>'Sri Lanka',
		'SD'=>'Sudan',
		'SR'=>'Suriname',
		'SJ'=>'Svalbard And Jan Mayen',
		'SZ'=>'Swaziland',
		'SE'=>'Sweden',
		'CH'=>'Switzerland',
		'SY'=>'Syria',
		'TW'=>'Taiwan',
		'TJ'=>'Tajikistan',
		'TZ'=>'Tanzania',
		'TH'=>'Thailand',
		'TG'=>'Togo',
		'TK'=>'Tokelau',
		'TO'=>'Tonga',
		'TT'=>'Trinidad And Tobago',
		'TN'=>'Tunisia',
		'TR'=>'Turkey',
		'TM'=>'Turkmenistan',
		'TC'=>'Turks And Caicos Islands',
		'TV'=>'Tuvalu',
		'UG'=>'Uganda',
		'UA'=>'Ukraine',
		'AE'=>'United Arab Emirates',
		'UK'=>'United Kingdom',
		'US'=>'United States',
		'UM'=>'United States Minor Outlying Islands',
		'UY'=>'Uruguay',
		'UZ'=>'Uzbekistan',
		'VU'=>'Vanuatu',
		'VA'=>'Vatican City (Holy See)',
		'VE'=>'Venezuela',
		'VN'=>'Vietnam',
		'VG'=>'Virgin Islands (British)',
		'VI'=>'Virgin Islands (US)',
		'WF'=>'Wallis And Futuna Islands',
		'EH'=>'Western Sahara',
		'WS'=>'Western Samoa',
		'YE'=>'Yemen',
		'YU'=>'Yugoslavia',
		'ZM'=>'Zambia',
		'ZW'=>'Zimbabwe'
	}

  	# run everyday 11:59 pm MST
  	def perform

    begin
    	
    	orders = []
    	failed_cards = {}
	    csv_string = CSV.generate do |csv|

	      	header = ["TRACKING NUMBER", "Shipping Method", "Order ID", "Order Date", "Shop Name", "Shop Domain", "Gender", "Product Name", "Front Design URL", "Back Design URL", "Front Reference URL", "Back Reference URL", "Status", "SKU", "Light/Dark", "Quantity", "Shipping Name", "Shipping Address1", "Shipping Address2", "Shipping Company", "Shipping City", "Shipping ZIP", "Shipping Province/State", "Shipping Country"]
	      	packing_slip = ["Packing Slip Logo URL", "Packing Slip Message", "Non-Plastic Packaging", "Remove Tag", "Shop Shipping Address1", "Shop Shipping Address2", "Shop Shipping City", "Shop Shipping ZIP", "Shop Shipping Province/State", "Shop Shipping Country"]
	      	csv << [*header, *packing_slip]

	      	Shop.where.not(stripe_customer_id: nil).each do |shop|

				session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
				ShopifyAPI::Base.activate_session(session)

				#shop_from_api = ShopifyAPI::Shop.current

				#start by checking if orders with pending payment status have been paid
				Order.where(fulfillment_status: "Pending").each do |order|
				  if order.payment_status == "pending"
				    #Do a Shopify API call to check is still pending
				    payment_status = "pending"
				    begin
				  	  payment_status = ShopifyAPI::Order.find(order.shopify_order_id).financial_status
				    rescue Exception => e
				  	
				    end
				    order.payment_status = payment_status
				    order.save
				  end
				end

				charge_amount = 0
				design_fee = 0
				Order.where(fulfillment_status: "Pending").each do |order|
				  
				  # Don't process order if its payment status is pending
				  if order.payment_status != "pending"

				    #tee = Tee.where(id: order.tee_id).first
				    #if !tee.one_time_fee_charged
				    #  design_fee += 3 
				    #  tee.one_time_fee_charged = true
				    #end
				    #if !tee.back_one_time_fee_charged
				    #  design_fee += 3 
				    #  tee.back_one_time_fee_charged = true
				    #end
				    #tee.save

				    base_cost = order.gender == "male" ? 5 : 5.5
				    #base_cost = order.back_design.present? ? 7 : 6
				    #base_cost = order.multicolor == 'yes' ? base_cost + 1.5 : base_cost

				    is_US = order.country.include?("United States")
				    chose_china_post = shop.chose_china_post == "Yes"

				    if is_US
				    	base_cost = base_cost + 3
				    else
				    	if chose_china_post
					      	base_cost = base_cost + 4.5
					    else
					    	base_cost = base_cost + 7
					    end
				    end

				    if shop.non_plastic == "Yes"
				    	base_cost = base_cost + 0.5
				    end

				    if shop.remove_tag == "Yes"
				    	base_cost = base_cost + 0.05
				    end

				    if shop.shopify_domain == order.shop_domain
				      charge_amount = charge_amount + (order.quantity * base_cost)
				    end
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

				  #send shop owner email if card failed to process
				  if status != "In-Production"
				  	failed_cards[shop.email] = status
				  end

				  intl_shipping = (shop.chose_china_post == "No" || shop.chose_china_post.blank?) ? "UPS" : "China Post"

				  shop_from_api = nil
				  begin
				  	shop_from_api = ShopifyAPI::Shop.current 
				  rescue Exception => e

				  end


				  Order.where(fulfillment_status: "Pending").each do |order|
				    if shop.shopify_domain == order.shop_domain && order.payment_status != "pending"
				      row = ["", order.country == "United States" ? "USPS" : intl_shipping, order.id, order.created_at, order.shop_name, order.shop_domain, order.gender, order.product_name, order.front_design, order.back_design, order.front_ref, order.back_ref, status, update_color_names(order.sku), order.light_or_dark, order.quantity, order.name, order.address1, order.address2, order.company, order.city, order.zip, order.province, to_country_code(order.country) == nil ? order.country : to_country_code(order.country)]
				      packing_slip = shop.packing_slip == "Yes" ? [shop.packing_slip_logo, shop.packing_slip_message.sub("[customer_name]", order.name)] : ["",""]
				      csv << [*row, *packing_slip, shop.non_plastic, shop.remove_tag, shop_from_api.blank? ? "" : shop_from_api.address1, shop_from_api.blank? ? "" : shop_from_api.address2, shop_from_api.blank? ? "" : shop_from_api.city, shop_from_api.blank? ? "" : shop_from_api.zip, shop_from_api.blank? ? "" : shop_from_api.province, shop_from_api.blank? ? "" : shop_from_api.country_name]
				      order.processed = true
				      order.fulfillment_status = status == "In-Production" ? status : "Pending"
				      order.save

				      sleep(3)

				      orders.push(order) if status == "In-Production"
				    end
				  end
				end
		    end #shop each end

	    end #csv_string end

	    #send out email
	    CsvOrdersMailer.csv_file_email(csv_string).deliver_now
	    send_email_per_order(csv_string)

	    failed_cards.each do |key, value|
		    FailedProcessingCardMailer.failed_card_email(key, value).deliver_now
		end

	    #update inventory
    	#orders.each do |order|
    	#	updateInvetoryTables(order.gender, order.quantity, order.sku)
    	#end

    rescue Exception => e
    	job_title = "process_orders_job.rb"
	    log_data_1 = e.message
	    log_data_2 = e.backtrace

	    ErrorMailer.error_email(job_title, log_data_1, log_data_2).deliver_now
    end

  end

  def send_email_per_order(csv_string)
  	CSV.parse(csv_string, {headers: true}) do |order|
  		if order[12] == "In-Production"
	  		PerOrderMailer.order_email(order).deliver_now
	  	end
        sleep(3)
    end

    check_if_any_in_same_order(csv_string)
  end

  def check_if_any_in_same_order(csv_string)
  	#
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






























