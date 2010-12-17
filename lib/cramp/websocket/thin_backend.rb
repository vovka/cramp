require 'thin'

silence_warnings { Thin::Server::DEFAULT_TIMEOUT = 0 }

class Thin::Connection
  # Called when data is received from the client.
  def receive_data(data)
    Cramp.log :received, data
    trace { data }

    if data =~ /^<policy-file-request\/>/
      domain = @request.env['SERVER_NAME']
      port = "*"
      policy_file = "<?xml version=\"1.0\"?>"
      policy_file << "<!DOCTYPE cross-domain-policy SYSTEM \"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">"
      policy_file << "<cross-domain-policy>"
      policy_file << "<allow-access-from domain=\"#{domain.to_s}\" to-ports=\"#{port.to_s}\"/>"
      policy_file << "</cross-domain-policy>"
      send_data policy_file
      terminate_request
    else
      case @serving
      when :websocket
        callback = @request.env[Thin::Request::WEBSOCKET_RECEIVE_CALLBACK]
        callback.call(data) if callback
      else
        if @request.parse(data)
          if @request.websocket?
            @response.persistent!
            @response.websocket_upgrade_data = @request.websocket_upgrade_data
            @serving = :websocket
          end
          process
        end
      end
    end
  rescue Thin::InvalidRequest => e
    log "!! Invalid request"
    log_error e
    close_connection
  end
end

class Thin::Request
  include Cramp::WebsocketExtension
end

class Thin::Response
  # Headers for sending Websocket upgrade
  attr_accessor :websocket_upgrade_data

  def each
    websocket_upgrade_data ? yield(websocket_upgrade_data) : yield(head)
    if @body.is_a?(String)
      yield @body
    else
      @body.each { |chunk| yield chunk }
    end
  end
end
