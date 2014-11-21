import 'org.bukkit.Sound'

module Dummy
  extend self
  extend Rukkit::Util

  # def on_player_toggle_sneak(evt)
  #   player = evt.player
  #   if player.name == 'ujm'
  #     play_sound(add_loc(player.location, 0, 5, 0), Sound.values.to_a.sample, 1.0, 0.0)
  #   end
  # end

  def on_command(sender, command, label, args)
    return unless label == 'rukkit'

    args = args.to_a
    case args.shift
    when 'update'
      unless args.empty?
        log.warning('rukkit update with argument is invalid')
        return
      end

      # just for now
      Dir.chdir('/home/rukkit/rukkit') do
        puts `git pull --rebase`
        Bukkit.dispatch_command(sender, 'reload')
      end
    when 'eval'
      # very dangerous!
      later(0) do
        begin
          # how to handle double-space?
          sender.send_message(eval(args.join(' ')).inspect)
        rescue => e
          sender.send_message(e.inspect)
        end
      end
    when 'what-time'
      broadcast Time.now.to_s
    else
      p :else, sender, command, args
    end
  end

  Lingr.post('Rukkit updated.')
end
