# encoding: utf-8
import 'org.bukkit.Bukkit'

module Util
  extend self

  def broadcast(*messages)
    Bukkit.server.broadcast_message messages.join
  end

  def sec(n)
    (n * 20).to_i
  end

  def later(tick, &block)
    plugin = Bukkit.plugin_manager.plugin("rukkit")
    Bukkit.getScheduler.scheduleSyncDelayedTask(plugin, block, tick)
  end
end
