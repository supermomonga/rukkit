# encoding: utf-8

require 'redis'
require 'redis-namespace'

module Rukkit
  module Redis
    extend self
    @@redis = Redis.new
    @@ns = Redis::Namespace.new(:Rukkit, :redis => @@redis)

    def get(key)
      @@ns.get("Rukkit:#{key}")
    end

    def set(key, value)
      @@ns.set(key, value)
    end

    def del(key, value)
      @@ns.del(key)
    end

  end
end
