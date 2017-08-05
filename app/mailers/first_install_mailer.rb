class FirstInstallMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def welcome_email(name)
		@name = name
		mail(to: 'amorimluc@gmail.com', subject: 'Rocketees Orders CSV File')
	end
end
