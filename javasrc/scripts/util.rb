# encoding: utf-8

require 'java'
import 'org.bukkit.Bukkit'
import 'org.bukkit.ChatColor'
import 'org.bukkit.Material'

class Integer
  def seconds
    self * 10
  end
  alias_method :second, :seconds
  alias_method :sec, :seconds
end

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

    def repeat(tick, &block)
      plugin = Bukkit.plugin_manager.get_plugin("rukkit")
      Bukkit.scheduler.schedule_sync_repeating_task(plugin, block, 0, tick)
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

    def play_effect(loc, effect, data)
      loc.world.play_effect(loc, effect, data)
    end

    # etype: org.bukkit.entity.EntityType
    def spawn(loc, etype)
      loc.world.spawn_entity(loc, etype)
    end

    def spawn_falling_block(loc, material, data)
      loc.world.spawn_falling_block(loc, material, data)
    end

    def fall_block(block)
      block_type, block_data = [block.type, block.data]
      block.type = Material::AIR
      block.data = 0
      loc.world.spawn_falling_block(loc, block_type, block_data)
    end

    def drop_item(loc, itemstack)
      loc.world.drop_item_naturally(loc, itemstack)
    end

    def explode(loc, power, set_fire_p)
      loc.world.create_explosion(loc, jfloat(power), set_fire_p)
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
      "#{bundler_gems_dir}/*/*/gems/**/lib/"
    end

    def gem_home
      rukkit_dir + 'gems'
    end

    def bundler_path
      dir = Dir.glob("#{gem_home}/gems/bundler-*/bin/").first
      "#{dir}/bundler"
    end

    def bundler_gems_dir
      '/bundler'
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
