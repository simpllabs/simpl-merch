class PerOrderMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	#new will be nh01hq66@robot.zapier.com

	def order_email(order)
		@order = order
		mail(to: "nh01hq66@robot.zapier.com", subject: 'Rocketees: New Order')
	end
end
