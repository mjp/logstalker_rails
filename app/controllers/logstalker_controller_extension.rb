module LogstalkerControllerExtension
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.around_action :logstalker
  end

  module InstanceMethods
    def logstalker
      begin
        yield
      ensure
        Thread.current[:logstalker] = {
          ip: request.remote_ip,
          domain: request.host,
          referrer: request.referer,
          user_agent: request.user_agent
        }

        user_id_cookie = Rails.configuration.x.logstalker.user_id_cookie
        user_id_session = Rails.configuration.x.logstalker.user_id_session

        if user_id_cookie and cookies[user_id_cookie]
          Thread.current[:logstalker][:user_id] = cookies[user_id_cookie].to_s
        elsif user_id_session and session[user_id_session]
          Thread.current[:logstalker][:user_id] = session[user_id_session].to_s
        end
      end
    end
  end
end
