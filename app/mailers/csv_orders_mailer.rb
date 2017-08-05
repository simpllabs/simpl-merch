class CsvOrdersMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def csv_file_email(csv)
	    attachments["ROCKETEES-#{Date.today.to_s}.csv"] = {mime_type: 'text/csv', content: csv}
		mail(to: 'amorimluc@gmail.com', subject: 'Rocketees Orders CSV File')
	end
end
