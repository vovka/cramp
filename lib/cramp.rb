require 'eventmachine'
EM.epoll

require 'active_support'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/buffered_logger'

require 'rack'

module Cramp
  VERSION = '0.10'

  mattr_accessor :logger, :debug

  autoload :Action, "cramp/action"
  autoload :Websocket, "cramp/websocket"
  autoload :Body, "cramp/body"
  autoload :PeriodicTimer, "cramp/periodic_timer"
  autoload :KeepConnectionAlive, "cramp/keep_connection_alive"
  autoload :Abstract, "cramp/abstract"
  autoload :Callbacks, "cramp/callbacks"
  autoload :TestCase, "cramp/test_case"

  def self.log direction, msg=''
    if debug
      puts "\n" + (msg.split("\n").map do |line|
        "#{Cramp.direction_name(direction)}: #{line}"
      end.join("\n")) + "\n"
    else
      puts "no debug for today"
    end
  end

  def self.direction_name smb
    case smb
    when :received
      'rcvd>>>'
    when :sent
      'sent>>>'
    end
  end
end
