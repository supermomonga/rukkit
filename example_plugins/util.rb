# encoding: utf-8

module Util
  extend self

  def broadcast(*messages)
    Bukkit.server.broadcast_message messages.join
  end

end
