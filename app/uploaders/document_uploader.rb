class DocumentUploader < BaseUploader
  def extension_white_list
    %w[pdf]
  end
end
