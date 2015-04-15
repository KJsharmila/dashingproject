class Admin::DashboardsController < ApplicationController

  def index
    get_collections
    dashboard_widgets = DashboardWidget.where(dashboard_id: @dashboard.id)
    dashboard_widgets.each do |dw|
      if dw.access_token.present? && dw.organization_name.present? && dw.repo_name.present?
        $dashboard_widget_github = dw
      elsif dw.code_repo_id.present? && dw.code_api_token.present?
        $dashboard_widget_code = dw
      elsif dw.jira_url.present? && dw.jira_view_id.present? && dw.jira_name.present? && dw.jira_password.present?
        $dashboard_widget_jira = dw
      elsif dw.jira_url.present? && dw.jira_name.present? && dw.jira_password.present? && dw.jira_project_key.present?
        $dashboard_widget_jira = dw
      end
    end
  end

  def new
    @dashboard = Dashboard.new
  end

  def create
    @dashboard = Dashboard.new(dashboard_params)
    if @dashboard.valid?
      @dashboard.save
      @success = true
    else
      @success = false
    end
  end

  def edit
    @dashboard = Dashboard.find(params[:id])
  end

  def show
    @dashboard = Dashboard.find(params[:dashboard_id])
  end

  def update
    @dashboard = Dashboard.find(params[:id])
    if @dashboard.valid?
      @dashboard.update_attributes(dashboard_params)
      @success = true
    else
      @success = false
    end
  end

  private

  def dashboard_params
    params[:dashboard].permit(:name)
  end

  def get_collections

    # Fetching the dashboard
    relation = Dashboard.where("")
    @filters = {}

    if params[:query]
      @query = params[:query].strip
      relation = relation.search(@query) if !@query.blank?
    end

    @dashboards = relation.order("created_at desc")

    ## Initializing the @dashboard object so that we can render the show partial
    @dashboard = @dashboards.first unless @dashboard

    return true

  end
end