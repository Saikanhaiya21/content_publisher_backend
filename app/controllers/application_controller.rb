class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { error: 'Not Found' }, status: :not_found
  end

  def authenticate_request!
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    return render json: { error: 'Missing token' }, status: :unauthorized unless header

    begin
      payload = JsonWebToken.decode(header)
      @current_user = User.find(payload['user_id'])
    rescue JWT::ExpiredSignature
      render json: { error: 'Token expired' }, status: :unauthorized
    rescue => e
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
