class Api::V1::UsersController < Api::V1::BaseController
  load_and_authorize_resource
  
  before_action :check_demoting

  private
  
  def check_demoting
    render json: "You cannot demote yourself", status: 403 if (params[:id].to_i == current_user.id && (params[:users].keys.include?("admin") || params[:users].keys.include?("locked")))
  end
  
  def request_params
    params.require(:users).permit(:email, :roles, :password, :password_confirmation, :username, :number_of_instances_purchased, :admin, :locked).delete_if{ |_,v| v.nil? }
  end
end
