class Products::Upload::DownloadFileFromBucket
  def initialize(file_url)
    @file_url = file_url
  end

  def exec
    extracted_file_name = URI.parse(@file_url).path[1..-1]
    local_file_path = Rails.root.join('tmp', File.basename(extracted_file_name))

    S3_BUCKET.object(extracted_file_name).get(response_target: local_file_path)

    local_file_path
  end
end