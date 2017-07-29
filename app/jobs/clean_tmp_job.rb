require "base64"

class CleanTmpJob < ProgressJob::Base
  def initialize

  end

  def perform
    #clean all files that weren't created within the last 5 hours in local /tmp
    system("find #{ENV['STORAGE_URL']} -type f -name '*.png' -mmin +360 -delete")

    #clean all files that weren't created within the last 5 hours in S3 /tmp
    #obj_keys = []
    #S3_BUCKET.objects(prefix: "tmp").each_with_index do |obj, index|
    #  if index != 0
    #    hours = (Time.now.utc - obj.last_modified)/60/60
    #    if hours > 6
    #      obj_keys.push({key: obj.key})
    #    end 
    #  end
    #end

    #S3_BUCKET.delete_objects(delete: { objects: obj_keys}) if !obj_keys.empty?
  end
end