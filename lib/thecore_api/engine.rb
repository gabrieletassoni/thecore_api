module ThecoreApi
  class Engine < ::Rails::Engine
    # appending migrations to the main app's ones
    initializer :append_migrations do |app|
      config.middleware.insert_before 0, "Rack::Cors" do
        allow do
          origins '*'
          resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options, :head]
        end
      end
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
