class Admin::V1::HomeController < Admin::V1::ApiController

  def index
    render json: {message: 'uhull'}
  end
end
