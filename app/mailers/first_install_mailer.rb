class FirstInstallMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def welcome_email(shop_domain)
		@name = shop_domain
		mail(to: email, subject: 'A Message From Lucas, Co-Founder of Rocketees')
	end
end
