require 'digest/sha1'
require 'erb'
require 'open-uri'
require 'json'

require_resource 'scripts/util'

module Lingr
  CONVERSION_TABLE = {
    /benri/ => '便利',
    /[fh]u[bv]en/ => '不便',
    /ribensei/ => '利便性',
  }

  class Message
    attr_reader :name, :message

    def initialize(name, message)
      @name = name
      @message = message
    end
  end

  extend self

  def post_to_lingr(channel, message)
    bot = Rukkit::Util.plugin_config 'lingr.bot'
    secret = Rukkit::Util.plugin_config 'lingr.secret'
    verifier = Digest::SHA1.hexdigest(bot + secret)

    params = {
      room: channel,
      bot: bot,
      text: message,
      bot_verifier: verifier
    }

    query_string = params.map{|k,v|
      key = ERB::Util.url_encode k.to_s
      value = ERB::Util.url_encode v.to_s
      "#{key}=#{value}"
    }.join "&"

    Thread.start do
      open "http://lingr.com/api/room/say?#{query_string}"
    end
  end

  def on_async_player_chat(evt)
    player = evt.player

    message = Message.new player.name, evt.message
    message = CONVERSION_TABLE.inject {|memo, (k, v)| memo.gsub(k, v) }
    evt.message = message

    text = "[#{message.name}] #{message.message}"

    channel = Rukkit::Util.plugin_config 'lingr.channel'
    post_to_lingr channel, text

  end
end
