require 'rails_helper'

RSpec.describe ImageUploader do
  let(:category) { build(:category) }
  let(:uploader) { ImageUploader.new(category, :image) }

  before do
    ImageUploader.enable_processing = true
    File.open("#{Rails.root}/spec/images/image.png") { |f| uploader.store!(f) }
  end

  context 'the thumb version' do
    # it "scales down a landscape image to be exactly 64 by 64 pixels" do
    #   expect(uploader.thumb).to have_dimensions(64, 64)
    # end
  end
end
