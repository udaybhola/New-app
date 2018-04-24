class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"
  before_action :set_constituency

  def index
    @country_states = CountryState.all

    unless params[:country_state].blank?
      @country_state = CountryState.find_by_code(params.permit(:country_state)["country_state"])
      @parliamentary_constituencies = @country_state.constituencies.parliamentary
      @assembly_constituencies = @country_state.constituencies.assembly
    end


    @q = User.unscoped.ransack(params[:q])
    if @constituency.nil? && params[:q].blank?
      @users = User.none.page params[:page]
    elsif !params[:q].blank?
      if @constituency.nil?
        @users = Kaminari.paginate_array(@q.result.sort_by{|item| -item.total_score}).page(params[:page])
      else
        @users = Kaminari.paginate_array(@q.result.where(constituency_id: @constituency.id).sort_by{|item| -item.total_score}).page(params[:page])
      end
    else
      @users = Kaminari.paginate_array(@constituency.influencers.sort_by{|item| -item.total_score}).page(params[:page])
    end
  end

  def show
    @user = User.unscoped.find(params.permit(:id)["id"])
  end

  def deactivate
    @user = User.find(params.permit(:id)["id"])
    @user.mark_as_inactive
    redirect_to admin_users_path(constituency: @constituency_slug, country_state: params.permit(:country_state)["country_state"])
  end

  private

  def candidature_params
    params.require(:candidature).permit(:candidate_id, :party_id, :constituency_id, :declared, :result, :manifesto)
  end

  def set_constituency
    @constituency_slug = params.permit(:constituency)["constituency"]
    unless @constituency_slug.blank?
      @constituency = Constituency.find_by_slug(@constituency_slug)
    end
    @constituencies = Constituency.parliamentary
  end
end
