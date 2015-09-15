module LogstalkerRails

  class Engine < Rails::Engine
    initializer 'logstalker_rails.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        include LogstalkerControllerExtension
      end
    end
  end
end
