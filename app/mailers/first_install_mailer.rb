class FirstInstallMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def welcome_email(name, email)
		@name = name
		mail(to: email, subject: 'A Message From Lucas, Co-Founder of Rocketees')
	end
end
