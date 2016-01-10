class InstancesController < ApplicationController
  respond_to :json
  before_action :validate_params

  def index
    respond_with({ instances: [
      { id: 15416, name: 'test1' },
      { id: 15417, name: 'test2' },
      { id: 15418, name: 'test3' }
    ] })
  end

  def show
    respond_with({ error: 'Not Implemented!' }, status: 501)
  end

  def create
    respond_with({ error: 'Not Implemented!' }, status: 501)
  end

  def destroy
    respond_with({ error: 'Not Implemented!' }, status: 501)
  end

  private

  def validate_params
    respond_with({ error: 'Site ID not provided!' }, status: 400) if params[:site_id].blank?
  end
end
