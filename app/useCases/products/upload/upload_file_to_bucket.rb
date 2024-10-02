class Products::Upload::UploadFileToBucket
  def initialize(file)
    @file = file
  end

  def exec
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    new_file_name = "#{timestamp}_#{@file.original_filename}"

    s3_object = S3_BUCKET.object(new_file_name)
    s3_object.put(body: @file.read)

    upload_file = UploadFile.create!(file_url: s3_object.public_url)
    
    return upload_file
  end
end