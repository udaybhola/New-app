class Web::IssuesController < ApplicationController
  def show
    @issue = Issue.find(params[:id])
  end
end
