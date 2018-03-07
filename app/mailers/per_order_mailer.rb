class PerOrderMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	#new will be l4ddigct@robot.zapier.com

	def order_email(order)
		@order = order
		mail(to: "l4ddigct@robot.zapier.com", subject: 'Rocketees: New Order')
	end
end
