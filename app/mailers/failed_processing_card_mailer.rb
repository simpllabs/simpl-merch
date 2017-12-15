class FailedProcessingCardMailer < ApplicationMailer
	default from: 'support@rocketees.com'
	
	def failed_card_email(email, status)
		@status = status
		mail(to: email, subject: 'Rocketees ALERT: Card Failed Processing')
	end
end
