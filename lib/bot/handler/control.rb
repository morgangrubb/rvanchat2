module Bot
  module Handler
    class Control < Bot::Handler::Base

      def describe_commands(message)
        if message.from_admin?
          "!enable <handler>\n!disable <handler>\n!handlers"
        else
          nil
        end
      end

      def private_message(message, params)
        if message.from_admin?
          case message.text
          when /^!(enable|disable) (.*)$/
            message.processed!

            $stderr.puts "action: '#{$1}', handler: '#{$2}', encoding: '#{$2.encoding}'"
            $stderr.puts "all_handlers: #{controller.all_handlers.join(", ")}"

            if controller.all_handlers.include?($2)
              verb = $1 == 'enable' ? 'Enabling' : 'Disabling'
              say "#{verb} #{$2}", user_name: message.user_name
              controller.send("#{$1}_handler", $2)
            else
              say "I don't recognise the handler '#{$2}'", user_name: message.user_name
            end
          when /^!handlers$/
            message.processed!

            say "Enabled: #{controller.enabled_handlers.join(", ")}\nDisabled: #{controller.disabled_handlers.join(", ")}", user_name: message.user_name
          end
        end
      end

    end
  end
end
