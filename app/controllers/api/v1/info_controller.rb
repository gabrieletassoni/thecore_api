class Api::V1::InfoController < Api::V1::BaseController
  # Info uses a different auth method: username and password
  skip_before_action :authenticate_user!, only: [:version, :translations], raise: false

  # api :GET, '/api/v1/info/version', "Just prints the APPVERSION."
  # api!
  def version
    render json: {
      version: (APPVERSION rescue "No version specified for this app, please add an APPVERSION constant to an initializer to start versioning the application.")
    }.to_json, status: 200
  end

  # api :GET, '/api/v1/info/token', "Given auth credentials, in HTTP_BASIC form,
  # it returns the AUTH_TOKEN, email and id of the user which performed the authentication."
  # api!
  def token
    render json: {
      token: @current_user.authentication_token,
      email: @current_user.email
    }.to_json, status: 200
  end

  # api :GET, '/api/v1/info/available_roles', "Given auth credentials, in HTTP_BASIC form,
  # it returns the roles list
  def available_roles
    render json: ROLES.to_json, status: 200
  end

  # GET '/api/v1/info/translations'
  def translations
    render json: I18n.t(".", locale: (params[:locale].presence || :it)).to_json, status: 200
  end

  # private

  # Method overridden because the first time I have to ask for the token
  def authenticate_user!
    username, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)
    if username
      user = User.find_by(username: username)
    end
    if user && user.valid_password?(password)
      @current_user = user
    else
      return unauthenticated!
    end
  end
end
