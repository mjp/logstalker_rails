require "logstalker_rails/version"

module LogstalkerRails

  def self.logger
    log_filename = "#{Rails.root}/log/logstalker_#{Rails.env}.log"
    unless File.exist?(log_filename)
      File.open(log_filename, 'w') {}
    end

    logger = Logger.new(log_filename)
    logger.formatter = proc {|lt, t, n, msg| "#{msg}\n"}

    return logger
  end

  def self.log(logger, event)
    log_event = {
      timestamp: DateTime.now.strftime("%Y-%m-%d %H:%M:%S"),
      ip: Thread.current[:logstalker][:ip],
      domain: Thread.current[:logstalker][:domain],
      method: event.payload[:method],
      path: event.payload[:path].split('?').first,
      query: query(event),
      action: "#{event.payload[:controller]}##{event.payload[:action]}",
      status: event.payload[:status],
      referrer: Thread.current[:logstalker][:referrer],
      user_agent: Thread.current[:logstalker][:user_agent],
      response_time: response_time(event)
    }

    if event.payload[:exception]
      log_event[:status] = 500
      log_event[:message] = event.payload[:exception].join(' ')
    end

    if Thread.current[:logstalker][:user_id]
      log_event[:user_id] = Thread.current[:logstalker][:user_id]
    end

    logger.unknown(log_event.to_json)
  end

  def self.query(event)
    event.payload[:params].except('controller', 'action').map {|k,v| "#{k}=#{v}"}.join('&')
  end

  def self.response_time(event)
    response_time = 0.0
    response_time += event.payload[:view_runtime] if event.payload[:view_runtime]
    response_time += event.payload[:db_runtime] if event.payload[:db_runtime]

    return response_time.round(2)
  end
end

require "logstalker_rails/engine"
