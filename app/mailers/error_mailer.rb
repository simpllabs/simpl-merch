class ErrorMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def error_email(job_title, log1, log2)
		@job_title = job_title
		@log1 = log1
		@log2 = log2
		mail(to: 'amorimluc@gmail.com', subject: 'Rocketees Job ERROR Report')
	end
end
