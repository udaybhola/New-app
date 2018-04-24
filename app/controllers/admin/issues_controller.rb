class Admin::IssuesController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'

  before_action :set_region, except: [:index]

  def index
    @filter = params.permit(:filter)[:filter] || "featured"
    @country_states = CountryState.all

    unless params[:country_state].blank?
      @country_state = CountryState.find_by_code(params[:country_state])
      @parliamentary_constituencies = @country_state.constituencies.parliamentary
      @assembly_constituencies = @country_state.constituencies.assembly
    end

    if params[:constituency].blank?
      all_posts = Post.all
    else
      @constituency = @country_state.constituencies.find_by_slug(params[:constituency])

      all_posts = if @constituency.parent.nil?
                    Post.where(region_id: @constituency.children.map(&:id)).where.not(user_id: nil).order('created_at desc')
                  else
                    @constituency.posts
                  end

    end

    @posts = if @filter == 'dashboard'
               all_posts.dashboard.page params[:page]
             elsif @filter == 'archived'
               all_posts.admin.archived.page params[:page]
             elsif @filter == 'reported'
               all_posts.flagged.page params[:page]
             elsif @filter == 'all'
               all_posts.all.page params[:page]
             else
               all_posts.featured.page params[:page]
             end
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = Issue.new(issue_params)

    case issue_params[:region_type]
    when "CountryState"
      @issue.region = CountryState.find(params[:issue][:region_id])
    when "Constituency"
      @issue.region = Constituency.find(params[:issue][:region_id])
    end

    if @issue.save
      if @issue.region_type == "CountryState"
        redirect_to admin_country_state_path(@issue.region.id)
      else
        redirect_to admin_issues_path
      end
    else
      @issue.issue_options.build
      render action: 'new'
    end
  end

  def edit
    redirect_to admin_issues_path unless @issue.admin?
  end

  def update
    if @issue.update_attributes(issue_params)
      if params[:issue][:attachments_attributes]
        if attachment_hash = params[:issue][:attachments_attributes]
          if !attachment_hash.respond_to?(:count) && attachment_hash["_destroy"]
            @issue.attachments.find(attachment_hash["id"]).destroy
          end
        end
      end
      if @issue.region_type == "CountryState"
        redirect_to admin_country_state_path(@issue.region.id)
      else
        redirect_to admin_issues_path
      end
    else
      @issue.issue_options.build
      render action: 'edit'
    end
  end

  def destroy
    if @issue.destroy
      redirect_to admin_issues_path(country_state: params[:country_state], constituency: params[:constituency])
    else
      Rails.logger.debug "error while deleting issue : #{@issue.errors.messages}"
      redirect_to admin_issues_path
    end
  end

  def show
    unless params[:country_state].blank?
      @country_state = CountryState.find_by_code(params[:country_state])
    end

    unless params[:constituency].blank?
      @constituency = @country_state.constituencies.find_by_slug(params[:constituency])
    end
  end

  private

  def issue_params
    params.require(:issue).permit(
      :region_type,
      :region_id,
      :title,
      :description,
      :show_on_dashboard,
      attachments_attributes: ["media", "@original_filename", "@content_type", "@headers", "_destroy", "id"]
    )
  end

  def set_region
    if params[:id]
      @issue = Issue.unscoped.find(params[:id])
      @region_type = @issue.region_type
      @region_id = @issue.region_id
    else
      @region_type = params[:region_type] || ''
      @region_id = params[:region_id] || ''
    end

    case @region_type
    when 'CountryState'
      @region = CountryState.find(@region_id)
      @region_name = @region.name.capitalize
    when 'Constituency'
      @region = Constituency.find(@region_id)
      @region_name = "#{@region.name.capitalize} (#{@region.country_state.name.capitalize})"
    else
      @region_name = "India"
    end
  end
end
