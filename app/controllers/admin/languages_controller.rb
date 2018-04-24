class Admin::LanguagesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_language, only: [:make_available, :make_unavailable]
  layout "admin"

  def index
    Language.seed if Language.all.empty?
  end

  def make_available
    @language.availability = true
    @language.save
    redirect_to admin_languages_path
  end

  def make_unavailable
    @language.availability = false
    @language.save
    redirect_to admin_languages_path
  end

  def set_language
    @language = Language.find(params[:language_id]) if params[:language_id]
  end
end
