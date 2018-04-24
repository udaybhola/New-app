class BulkUploader < BaseUploader
  after :store, :perform_bulk_upload_job

  def extension_white_list
    %w[csv]
  end

  def perform_bulk_upload_job(_file)
    BulkUploadJob.perform_later(model.id)
  end
end
