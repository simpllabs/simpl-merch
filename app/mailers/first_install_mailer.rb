class FirstInstallMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def welcome_email(name, email)
		@name = name
		mail(to: email, subject: 'Rocketees Orders CSV File')
	end
end
