class ResubmitOrderMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'

	def order_email(order)
		@order = order
		mail(to: "rock3t33s@robot.zapier.com", subject: 'Rocketees: Reship Order')
	end
end