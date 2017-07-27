# Preview all emails at http://localhost:3000/rails/mailers/csv_orders_export_mailer
class CsvOrdersExportMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/csv_orders_export_mailer/csv_file_email
  def csv_file_email
    CsvOrdersExportMailer.csv_file_email
  end

end
