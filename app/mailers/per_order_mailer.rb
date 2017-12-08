class PerOrderMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
			#cc: 'rock3t33s@robot.zapier.com'

	def order_email(order)
		@order = order
		mail(to: "amorimluc@gmail.com", subject: 'Rocketees: New Order')
	end
end
