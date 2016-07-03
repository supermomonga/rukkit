# encoding: utf-8

require 'java'
import 'org.bukkit.Bukkit'
import 'org.bukkit.ChatColor'
import 'org.bukkit.Material'
import 'redis.clients.jedis.Jedis'
import 'redis.clients.jedis.Protocol'

module Rukkit
  module TimeConvertable
    def seconds_in_minecraft
      self
    end
    alias_method :mcsec, :seconds_in_minecraft

    def minutes_in_minecraft
      mcsec * 60
    end
    alias_method :mcminute, :minutes_in_minecraft

    def hours_in_minecraft
      mcminute * 60
    end
    alias_method :mchour, :hours_in_minecraft

    def seconds_to_tick
      mcsec * 20
    end
    alias_method :sec, :seconds_to_tick

    def minutes_to_tick
      mcminute * 20
    end
    alias_method :minute, :minutes_to_tick

    def hours_to_tick
      mchour * 20
    end
    alias_method :hour, :hours_to_tick

  end
end

class Fixnum
  include Rukkit::TimeConvertable
end

module Rukkit
  module Util
    extend self

    def plugin
      Bukkit.plugin_manager.get_plugin("rukkit")
    end

    def broadcast(*messages)
      log.info "broadcast: " + messages.join
      Bukkit.server.broadcast_message messages.join
    end

    def sec(n)
      (n * 20).to_i
    end

    def repeat(tick, &block)
      Bukkit.scheduler.schedule_sync_repeating_task(self.plugin, block, 0, tick)
    end

    def later(tick, &block)
      Bukkit.scheduler.schedule_sync_delayed_task(self.plugin, block, tick)
    end

    def block_below(block)
      add_loc(block.location, 0, -1, 0).block
    end

    def add_loc(loc, x, y, z)
      l = loc.clone
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
      config = self.plugin.config
      config.send method, config_path
    end

    def plugin_config(key, type = :string)
      config "plugin_config.#{key}", type
    end

    def log
      self.plugin.logger
    end

    def plugin_repository
      self.plugin.config.get_string "rukkit.repository"
    end

    def rukkit_dir
      path = self.plugin.
        get_class.
        protection_domain.
        code_source.
        location.
        path
      File.dirname(path) + "/rukkit/"
    end

    def jruby_path
      pattern = rukkit_dir + 'jruby-complete-*.jar'
      files = Dir[pattern]
      if files.empty?
        nil
      else
        files.sort { |a,b|
          ver_a = a.match(%r`jruby-complete-([\d.]+)\.jar`)[1]
          ver_b = b.match(%r`jruby-complete-([\d.]+)\.jar`)[1]
          Gem::Version.new(ver_b) <=> Gem::Version.new(ver_a)
        }.first
      end
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

      color =
        if colors.keys.include?(color_name)
          colors[color_name]
        else
          colors[:RESET]
        end

      "#{color}#{text}#{colors[:RESET]}"
    end

    def camelize(snake_case)
      snake_case.split('_').map(&:capitalize).join
    end

    def consume_item(player)
      if player.item_in_hand.amount == 1
        player.item_in_hand = ItemStack.new(Material::AIR)
      else
        player.item_in_hand.amount -= 1
      end
    end

    def jedis()
      @@jedis
    end

    def __on_plugin_enable(evt)
      host = plugin.config.get_string('rukkit.plugin_config.redis.host', 'localhost')
      port = plugin.config.get_int('rukkit.plugin_config.redis.port', Protocol::DEFAULT_PORT)

      log.info "--> Connecting to #{host}:#{port} using jedis."
      begin
        @@jedis = Jedis.new host, port
        @@jedis.connect

        log.info "----> Use it for plugin storage."
        @@jedis.select 1
        log.info "------> OK."
      rescue Exception => e
        log.warning e.message
        log.warning "--> Disabling redis feature."
        @@jedis = nil
      end
    end
    private :__on_plugin_enable

    def __on_plugin_disable(evt)
      if @@jedis
        begin
          log.info "--> Disconnecting."
          @@jedis.close
        rescue Exception => e
          log.warning e.message
        ensure
          @@jedis = nil
        end
      end
    end
    private :__on_plugin_disable
  end
end
