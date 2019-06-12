# Rails.application.routes.disable_clear_and_finalize = true
# Rails.application.routes.draw do
#   namespace :api do
#     namespace :v1, defaults: { format: :json } do

#     end
#   end
# end
# https://labs.kollegorna.se/blog/2015/04/build-an-api-now/
class Api::V1::BaseController < ActionController::API
  include CanCan::ControllerAdditions
  #include Pundit
  #check_authorization
  #load_and_authorize_resource
  # https://github.com/kollegorna/active_hash_relation
  include ActiveHashRelation

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session

  before_action :destroy_session

  before_action :authenticate_user!
  before_action :find_model, except: [ :version, :token, :available_roles, :check ]
  before_action :find_record, only: [ :show, :update, :destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :not_found!
  rescue_from ActiveRecord::StatementInvalid, with: :unauthenticated!
  rescue_from ActiveRecord::RecordInvalid, with: :invalid!
  #rescue_from CanCan::AuthorizationNotPerformed, with: :unauthorized!
  rescue_from CanCan::AccessDenied, with: :unauthorized!
  #rescue_from Pundit::NotAuthorizedError, with: :unauthorized!

  attr_accessor :current_user

  #Disabling Strong Parameters
  # def params
  #   request.parameters
  # end

  def check
    path = params[:path].split("/")
    find_model path.first
    if request.get?
      if path.second.blank?
        @page = params[:page]
        @per = params[:per]
        @pages_info = params[:pages_info]
        @count = params[:count]
        @query = params[:q]
        index
      else
        find_record path.second.to_i
        show
      end
    elsif request.post?
      # Non sono certo che i request params gli arrivino... Domani da testare
      # Il body come glielo passo?
      create
    elsif request.put?
      # Non sono certo che i request params gli arrivino... Domani da testare
      # Il body come glielo passo?
      find_record path.second.to_i
      update
    elsif request.delete?
      find_record path.second.to_i
      destroy
    end
  end

  def index
    # Rails.logger.debug params.inspect
    # find the records
    @q = (@model.column_names.include?("user_id") ? @model.where(user_id: current_user.id) : @model).ransack(@query.presence|| params[:q])
    @records_all = @q.result(distinct: true)
    page = (@page.presence || params[:page])
    per = (@per.presence || params[:per])
    pages_info = (@pages_info.presence || params[:pages_info])
    count = (@count.presence || params[:count])
    @records = @records_all.page(page).per(per)

    # If there's the keyword pagination_info, then return a pagination info object
    return render json: MultiJson.dump({
      count: @records_all.count,
      current_page_count: @records.count,
      next_page: @records.next_page,
      prev_page: @records.prev_page,
      is_first_page: @records.first_page?,
      is_last_page: @records.last_page?,
      is_out_of_range: @records.out_of_range?,
      pages_count: @records.total_pages,
      current_page_number: @records.current_page
    }) if !pages_info.blank?
    # If it's asked for page number, the paginate
    return render json: MultiJson.dump(@records, @json_attrs || {}) if !page.blank? # (@json_attrs || {})
    # if you ask for count, then return a json object with just the number of objects
    return render json: MultiJson.dump({count: @records_all.count}) if !count.blank?
    # Default
    render json: MultiJson.dump(@records_all, @json_attrs || {}) #(@json_attrs || {})
  end

  # def count
  #   # find the records
  #   @q = (@model.column_names.include?("user_id") ? @model.where(user_id: current_user.id) : @model).ransack(params[:q])
  #   @records_all = @q.result(distinct: true)
  #   # if you ask for count, then return a json object with just the number of objects
  #   return render json: {count: @records_all.count}.to_json
  # end

  def search
    index
    render :index
  end

  def show
    render json: @record.to_json(@json_attrs || {}), status: 200
  end

  def create
    @record =  @model.new(request_params)
    @record.user_id = current_user.id if @model.column_names.include? "user_id"

    @record.save!

    render json: @record.to_json(@json_attrs || {}), status: 201
  end

  def update
    @record.update_attributes(request_params)

    render json: @record.to_json(@json_attrs || {}), status: 200
  end

  def destroy
    unless @record.destroy
       return api_error(status: 500)
    end

    render json: {message: "Deleted"}, status: 200
  end

  protected

  def destroy_session
    request.session_options[:skip] = true
  end

  def unauthenticated!
    response.headers['WWW-Authenticate'] = "Token realm=Application"
    render json: { error: 'bad credentials' }, status: 401
  end

  def unauthorized!
    render nothing: true, status: :forbidden
    return
  end

  def invalid_credentials!
    render json: { error: 'invalid credentials' }, status: 403
    return
  end

  def unable!
    render json: { error: 'you are not enabled to do so' }, status: 403
  end

  def invalid!
    render json: { error: 'Some validation has failed' }, status: 422
  end

  def invalid_resource!(errors = [])
    api_error(status: 422, errors: errors)
  end

  def not_found!
    return api_error(status: 404, errors: 'Not found')
  end

  def api_error(status: 500, errors: [])
    unless Rails.env.production?
      puts errors.full_messages if errors.respond_to? :full_messages
    end
    head status: status and return if errors.empty?

    # render json: jsonapi_format(errors).to_json, status: status
    render json: errors.to_json, status: status
  end

  def paginate(resource)
    resource = resource.page(params[:page] || 1)
    if params[:per_page]
      resource = resource.per_page(params[:per_page])
    end

    return resource
  end

  # expects pagination!
  def meta_attributes(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: (object.previous_page rescue nil),
      total_pages: object.total_pages,
      total_count: (object.total_entries rescue nil)
    }
  end

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    # puts "controller: #{controller_name}\naction: #{action_name}\ntoken: #{token}\noptions: #{options.inspect}\n\n"

    user_email = options.blank?? nil : options[:email]
    user = user_email && User.find_by(email: user_email)

    if user && ActiveSupport::SecurityUtils.secure_compare(user.authentication_token, token)
      @current_user = user
    else
      return unauthenticated!
    end
  end

  # private

  def find_record id
    # find the records
    @record = @model.column_names.include?("user_id") ? @model.where(id: (id.presence || params[:id]), user_id: current_user.id).first : @model.find((id.presence || params[:id]))
  end

  def find_model path=nil
    # Find the name of the model from controller
    @singular_controller = (path.presence || controller_name).singularize.to_sym
    @model = (path.presence || controller_path).classify.constantize rescue controller_name.classify.constantize
  end

  def request_params
    # controller_name.singularize.to_sym 
    params.require(@singular_controller).permit!
  end
end
