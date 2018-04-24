class Admin::PollsController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'

  before_action :set_region

  def new
    @poll = Poll.new
    4.times { |i| @poll.poll_options.build(position: i) }
  end

  def create
    @poll = Poll.new(poll_params)

    case poll_params[:region_type]
    when "CountryState"
      @poll.region = CountryState.find(params[:poll][:region_id])
    when "Constituency"
      @poll.region = Constituency.find(params[:poll][:region_id])
    end

    if @poll.save
      redirect_to admin_issues_path
    else
      @poll.poll_options.build
      render action: 'new'
    end
  end

  def edit
    redirect_to admin_issues_path unless @poll.admin?
    @poll.poll_options.build(position: @poll.poll_options.map(&:position).max.nil? ? 0 : @poll.poll_options.map(&:position).max + 1)
  end

  def update
    if @poll.update_attributes(poll_params)
      if params[:poll][:attachments_attributes]
        if attachment_hash = params[:poll][:attachments_attributes]
          if !attachment_hash.respond_to?(:count) && attachment_hash["_destroy"]
            @poll.attachments.find(attachment_hash["id"]).destroy
          end
             end
      end
      redirect_to admin_issues_path
    else
      @poll.poll_options.build
      render action: 'edit'
    end
  end

  def destroy
    if @poll.destroy
      redirect_to admin_issues_path(country_state: params[:country_state], constituency: params[:constituency])
    else
      Rails.logger.debug "error while deleting poll : #{@poll.errors.messages}"
      render action: 'edit'
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

  def poll_params
    params.require(:poll).permit(
      :region_type,
      :region_id,
      :question,
      :show_on_dashboard,
      :poll_options_as_image,
      poll_options_attributes: [:answer, :id, :position, :image],
      attachments_attributes: ["media", "@original_filename", "@content_type", "@headers", "_destroy", "id"]
    )
  end

  def set_region
    if params[:id]
      @poll = Poll.unscoped.find(params[:id])
      @region_type = @poll.region_type
      @region_id = @poll.region_id
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
