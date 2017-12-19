class FailedProcessingCardMailer < ApplicationMailer
	default from: 'support@rocketees.com'
	
	def failed_card_email(email, status, order_number)
		@status = status
		@email = email
		@order_number = order_number
		mail(to: "amorimluc@gmail.com", subject: 'Rocketees ALERT: Card Failed Processing')
	end
end
