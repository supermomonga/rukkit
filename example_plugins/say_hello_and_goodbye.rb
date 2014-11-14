# encoding: utf-8

import 'org.bukkit.Bukkit'

$LOAD_PATH.each do |path|
  puts "LOAD PATH: #{path}"
end

puts File.exists? "/Users/momonga/Develops/bukkit/plugins/rukkit.jar/scripts/util.rb"

require './util'

module SayHelloAndGoodbye
  include_package 'org.bukkit.entity'
  include Util
  extend self

  def on_player_join(evt)
    player = evt.player
    broadcast "#{player.name}さんがログインしました"
  end

  def on_player_quit(evt)
    player = evt.player
    broadcast "#{player.name}さんがログアウトしました"
  end

end



