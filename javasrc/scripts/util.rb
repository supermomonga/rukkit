# encoding: utf-8

require 'java'
import 'org.bukkit.Bukkit'

module Rukkit
  module Util

    extend self

    def broadcast(*messages)
      Bukkit.server.broadcast_message messages.join
    end

    def sec(n)
      (n * 20).to_i
    end

    def later(tick, &block)
      plugin = Bukkit.plugin_manager.get_plugin("rukkit")
      Bukkit.scheduler.schedule_sync_delayed_task(plugin, block, tick)
    end

  end
end
