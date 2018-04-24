class Admin::DashboardController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'

  def index
    @country_states = CountryState.all
    @region_type = ''
    @region_id = ''

    @constituencies = Constituency.parliamentary
    @elections = Election.limit(20)
    @labels = Label.limit(50)

    if params[:country_state] && !params[:country_state].empty?
      @country_state = CountryState.find_by_code(params[:country_state])
      @parliamentary_constituencies = @country_state.constituencies.parliamentary
      @assembly_constituencies = @country_state.constituencies.assembly

      if params[:constituency] && !params[:constituency].empty?
        @constituency = @country_state.constituencies.find_by_slug(params[:constituency])

        @polls = @constituency.polls unless @constituency.nil?
        @issues = @constituency.issues unless @constituency.nil?
      end

      if @constituency
        @polls = @constituency.polls.admin
        @region_type = "Constituency"
        @region_id = @constituency.id
      else
        @polls = @country_state.polls.admin
        @region_type = "CountryState"
        @region_id = @country_state.id
      end

      @elections = @country_state.elections
    else
      @admin_polls = Poll.national.admin
      @admin_issues = Issue.national.admin
    end

    # @issues = Issue.limit(10)
    @comments = Comment.limit(10)
  end

  def clear_cache
    Rails.cache.clear
    redirect_to admin_path, notice: "Cache cleared"
  end

  def flagged_resources
    set_flagged_resources_data
  end

  def block_resource
    resource_id = params.permit(:resource_id)["resource_id"]
    raise Error::CustomError if resource_id.blank?
    flaggable = Flagging.find_by(flaggable_id: resource_id).flaggable
    flaggable.block!
    redirect_to admin_issues_path(constituency: params.permit(:constituency)["constituency"], country_state: params.permit(:country_state)["country_state"])
  end

  def approve_resource
    resource_id = params.permit(:resource_id)["resource_id"]
    raise Error::CustomError if resource_id.blank?
    flaggable = Flagging.find_by(flaggable_id: resource_id).flaggable
    if flaggable.nil?
      flaggable_type = Flagging.find_by(flaggable_id: resource_id).flaggable_type
      flaggable_id = Flagging.find_by(flaggable_id: resource_id).flaggable_id
      case flaggable_type
      when "Post"
        post = Post.unscoped.find(flaggable_id)
        post.approve!
      when "Comment"
        comment = Comment.unscoped.find(flaggable_id)
        comment.approve!
      end
    else
      flaggable.approve!
    end
    redirect_to admin_issues_path(constituency: params.permit(:constituency)["constituency"], country_state: params.permit(:country_state)["country_state"])
  end

  def archive_resource 
    resource_id = params.permit(:resource_id)["resource_id"]
    post = Post.find(resource_id)
    post.archive
    respond_to do |format|
      format.js
      format.html {redirect_to admin_issues_path(constituency: params.permit(:constituency)["constituency"], country_state: params.permit(:country_state)["country_state"])}
    end
  end

  def unarchive_resource
    resource_id = params.permit(:resource_id)["resource_id"]
    post = Post.unscoped.find(resource_id)
    post.unarchive
    respond_to do |format|
      format.js
      format.html {redirect_to admin_issues_path(constituency: params.permit(:constituency)["constituency"], country_state: params.permit(:country_state)["country_state"])}
    end
  end

  private

  def set_flagged_resources_data
    @flagged_posts = Post.flagged.order('updated_at desc')
    @flagged_comments = Comment.flagged.order('updated_at desc')
    @approved_posts = Post.approved.order('updated_at desc')
    @approved_comments = Comment.approved.order('updated_at desc')
    @blocked_posts = Post.unscoped.blocked.order('updated_at desc')
    @blocked_comments = Comment.unscoped.blocked.order('updated_at desc')
  end
end
