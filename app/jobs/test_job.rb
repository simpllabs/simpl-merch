class TestJob < ProgressJob::Base
  def initialize(text)
  	@text = text
  end

  def perform
        TestMailMailer.test_email(@text).deliver_now
  end
end