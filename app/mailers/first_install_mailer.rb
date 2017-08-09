class FirstInstallMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def welcome_email(shop_domain)
		@shop_domain = shop_domain
		mail(to: 'amorimluc@gmail.com', subject: 'A Message From Lucas, Co-Founder of Rocketees')
	end
end
