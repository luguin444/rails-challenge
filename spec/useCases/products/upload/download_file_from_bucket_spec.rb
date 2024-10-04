require 'rails_helper'

RSpec.describe Products::Upload::DownloadFileFromBucket do
  let(:file_url) { "https://s3.amazonaws.com/20211010121212_example.txt" }
  let(:s3_object) { double("s3_object", get: "tmp/20211010121212_example.txt") }

  before do
    allow(S3_BUCKET).to receive(:object).and_return(s3_object)
  end

  describe 'exec' do
    it "should call S3_BUCKET.object with the only the filename" do

      Products::Upload::DownloadFileFromBucket.new(file_url).exec

      expect(S3_BUCKET).to have_received(:object).with("20211010121212_example.txt")
    end

    it "should return correctly the local path" do

      local_path = Products::Upload::DownloadFileFromBucket.new(file_url).exec

      expect(local_path.to_s).to include("tmp/20211010121212_example.txt")
    end
  end
end