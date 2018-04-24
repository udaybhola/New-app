require 'csv'
class Admin::LanguageLabelsController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  def index; end

  def upload
    file_data = params['upload']['file']
    data = CSV.parse(file_data.read.force_encoding('utf-8'), headers: true)
    data.each do |item|
      LanguageLabel.create_from_csv_row(item)
    end
    redirect_to admin_language_labels_path
  end
end
