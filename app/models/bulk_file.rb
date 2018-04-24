class BulkFile < ApplicationRecord
  belongs_to :election
  mount_uploader :file, BulkUploader

  before_create :set_name, :set_status

  def set_name
    self.name = file_identifier
  end

  def set_status
    self.status = "file uploaded"
  end
end
