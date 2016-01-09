class HaikunatorController < ApplicationController
  respond_to :json

  def show
    respond_with({ name: Haikunator.haikunate })
  end
end
