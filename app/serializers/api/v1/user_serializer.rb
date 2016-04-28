# How to print the user infos
class Api::V1::UserSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :username, :locked, :admin, :created_at, :updated_at

  #has_many :microposts
  #has_many :following
  #has_many :followers
end