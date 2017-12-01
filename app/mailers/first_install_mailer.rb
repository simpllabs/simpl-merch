class FirstInstallMailer < ApplicationMailer
	default from: 'support@rocketees.com'
	
	def welcome_email(name, email)
		@name = name
		mail(to: email, subject: 'A Message From Lucas, Co-Founder of Rocketees')
	end
end
