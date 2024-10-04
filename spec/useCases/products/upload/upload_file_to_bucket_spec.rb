require 'rails_helper'

RSpec.describe Products::Upload::UploadFileToBucket do
  let(:file) { double("file", original_filename: "example.txt", read: "file content") }
  let(:s3_object) { double("s3_object", public_url: "https://s3.amazonaws.com/fake_bucket/20211010121212_example.txt") }

  before do
    allow(S3_BUCKET).to receive(:object).and_return(s3_object)
    allow(s3_object).to receive(:put)
  end

  describe 'exec' do
    it "should calls S3_BUCKET.object with the timestamps and filename" do
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      expected_file_name = "#{timestamp}_#{file.original_filename}"

      Products::Upload::UploadFileToBucket.new(file).exec

      expect(S3_BUCKET).to have_received(:object).with(expected_file_name)
    end

    it "should calls put with the correct file content" do
      Products::Upload::UploadFileToBucket.new(file).exec

      expect(s3_object).to have_received(:put).with(body: "file content")
    end

    it "creates the UploadFile correctly with the public_url" do
      Products::Upload::UploadFileToBucket.new(file).exec
    
      upload_file = UploadFile.last

      expect(upload_file.file_url).to eq(s3_object.public_url)
    end

    it "returns the created upload_file" do
      result =  Products::Upload::UploadFileToBucket.new(file).exec
      
      expect(result).to eq(UploadFile.last)
    end
  end
end