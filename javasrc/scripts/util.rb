# encoding: utf-8

require 'java'
import 'org.bukkit.Bukkit'
import 'org.bukkit.ChatColor'

module Rukkit
  module Util
    extend self

    def log
      Bukkit.plugin_manager.get_plugin('rukkit').logger
    end

    def broadcast(*messages)
      logger.info "broadcast: " + messages.join
      Bukkit.server.broadcast_message messages.join
    end

    def sec(n)
      (n * 20).to_i
    end

    def later(tick, &block)
      plugin = Bukkit.plugin_manager.get_plugin("rukkit")
      Bukkit.scheduler.schedule_sync_delayed_task(plugin, block, tick)
    end

    def block_below(block)
      add_loc(block.location, 0, -1, 0).block
    end

    def add_loc(loc, x, y, z)
      l = loc.dup
      l.add(x, y, z)
      l
    end

    def play_sound(loc, sound, volume, pitch)
      loc.world.play_sound(loc, sound, jfloat(volume), jfloat(pitch))
    end

    def jfloat(rubyfloat)
      rubyfloat.to_java Java.float
    end

    def config(key, type = :string)
      config_path = "rukkit.#{key}"
      method = "get_#{type}"
      config = Bukkit.plugin_manager.get_plugin('rukkit').config
      config.send method, config_path
    end

    def plugin_config(key, type = :string)
      config "plugin_config.#{key}", type
    end

    def logger
      Bukkit.plugin_manager.get_plugin('rukkit').logger
    end

    def plugin_repository
      Bukkit.plugin_manager.get_plugin('rukkit').config.get_string "rukkit.repository"
    end

    def rukkit_dir
      path =
        Bukkit.plugin_manager.
        get_plugin('rukkit').
        get_class.
        protection_domain.
        code_source.
        location.
        path
      File.dirname(path) + "/rukkit/"
    end

    def gems_dirs
      rukkit_dir + '/vendor/bundler/*/*/gems/**/lib/'
    end

    def gem_home
      rukkit_dir + '/gems'
    end

    def bundler_path
      dir = Dir.glob("#{gem_home}/gems/bundler-*/bin/").first
      "#{dir}/bundle"
    end

    def repo_dir
      rukkit_dir + 'repository'
    end

    def colorize(text, color_name)
      color_name = color_name.upcase

      colors = ChatColor.values.each_with_object({}){|c, acc|
        acc[c.name.to_sym] = c
      }

      if colors.keys.include? color_name
        color = colors[color_name]
      else
        color = colors[:RESET]
      end

      "#{color}#{text}#{colors[:RESET]}"
    end

    def camelize snake_case
      snake_case.split('_').map(&:capitalize).join
    end

  end
end
