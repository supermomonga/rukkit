
puts :test

require_resource 'scripts/util'

puts Rukkit::Util.plugin_config 'lingr.secret'

module Lingr
  extend self
end
