class TestMailMailer < ApplicationMailer
	default from: 'amorimluc@gmail.com'
	
	def test_email(text)
		@text = text
		mail(to: 'amorimluc@gmail.com', subject: 'Test Mailer')
	end
end
