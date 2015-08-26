module Bot
  module Handler
    class Control < Bot::Handler::Base

      def private_message(message, params)
        if message.from_admin?
          case message.text
          when /^!(enable|disable) (.*)$/
            if controller.all_handlers.include?($1)
              verb = $1 == 'enable' ? 'Enabling' : 'Disabling'
              say "#{verb} #{$2}", user_name: message.user_name
              controller.send("#{$1}_handler", $2)
            else
              say "I don't recognise the handler #{$2}", user_name: message.user_name
            end
          when /^!handlers$/
            say "Enabled: #{controller.enabled_handlers.join(", ")}\nDisabled: #{controller.disabled_handlers.join(", ")}", user_name: message.user_name
          end
        end
      end

    end
  end
end
