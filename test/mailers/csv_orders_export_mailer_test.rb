require 'test_helper'

class CsvOrdersExportMailerTest < ActionMailer::TestCase
  test "csv_file_email" do
    mail = CsvOrdersExportMailer.csv_file_email
    assert_equal "Csv file email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
