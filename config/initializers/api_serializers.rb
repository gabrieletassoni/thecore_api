require 'active_model_serializers'
require 'rack/cors'
#require 'rack_cors'

ActiveModel::Serializer.setup do |config|
  # Answer with id not the entire object, for has_many and belongs_to associations
  # This limits the throughput
  config.embed = :ids
  config.adapter = :json_api
end
