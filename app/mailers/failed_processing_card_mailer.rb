class FailedProcessingCardMailer < ApplicationMailer
	default from: 'support@rocketees.com'
	
	def failed_card_email(email, status)
		@status = status
		@email = email
		mail(to: "amorimluc@gmail.com", subject: 'Rocketees ALERT: Card Failed Processing')
	end
end
