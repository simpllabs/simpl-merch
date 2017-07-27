class CsvOrdersExportMailer < ApplicationMailer
	default from: 'support@rocketees.com'

	def csv_file_email(csv, email)
		attachments["orders-export.csv"] = {mime_type: 'text/csv', content: csv}
		mail(to: email, subject: 'Rocketees Orders Export ')
	end
end
