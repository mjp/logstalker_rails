logger = LogstalkerRails.logger

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  LogstalkerRails.log(logger, ActiveSupport::Notifications::Event.new(*args))
end
