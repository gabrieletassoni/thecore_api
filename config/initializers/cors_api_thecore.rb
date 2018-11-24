# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins { |source, env| 
    #   # No settings => '*'
    #   allowed_origins = Settings.ns('api').allowed_origins
    #   return true if allowed_origins.blank?
    #   allowed_origins.split(",").each do |domain|
    #     return true if source.end_with?(domain.strip)
    #   end
    #   return false 
    # }
    origins '*'
    resource '*',
      headers: :any,
      methods: %i(get post put patch delete options head)
  end
end
