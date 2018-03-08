class PerOrderMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	#new will be rocketees.o0vtk8@zapiermail.com

	def order_email(order)
		@order = order
		storename = order[5].split('.').first
		@packing_slip_msg = "https://app.rocketees.com/packingslip/#{storename}"
		mail(to: "rocketees.o0vtk8@zapiermail.com", subject: 'Rocketees: New Order')
	end
end
