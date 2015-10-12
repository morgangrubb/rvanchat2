module Bot
  module Handler
    class EightBall < Bot::Handler::Base

      # MESSAGES = [
      #   "It is certain.",
      #   "It is decidedly so.",
      #   "Without a doubt.",
      #   "Yes, definitely.",
      #   "You may rely on it.",
      #   "As I see it, yes.",
      #   "Most likely.",
      #   "Outlook good.",
      #   "Yes.",
      #   "Signs point to yes.",
      #   "Reply hazy try again.",
      #   "Ask again later.",
      #   "Better not tell you now.",
      #   "Cannot predict now.",
      #   "Concentrate and ask again.",
      #   "Don't count on it.",
      #   "My reply is no.",
      #   "My sources say no.",
      #   "Outlook not so good.",
      #   "Very doubtful."
      # ]

      # INSULTS = [
      #   "Go fuck yourself.",
      #   "You're an idiot.",
      #   "You kiss your mother with that mouth?",
      #   "I am not your bitch.",
      #   "Outlook is go away.",
      #   "Go home, you're drunk."
      # ]

      def public_message(message, params)
        if message.text =~ /^!8ball$/
          message.processed!
          say describe_commands(message), user_name: message.user_name
        elsif message.text =~ /^!8ball (.+)$/
          message.processed!
          response = EightBallResponse.offset(rand(EightBallResponse.count)).first
          say "8ball says: #{response.text}" if response
        end
      end

      def private_message(message, params)
        if message.from_admin?
          case message.text
          when /^!8ball list$/
            message.processed!
            responses = EightBallResponse.all.collect { |r| "#{r.id}: #{r.text}" }
            say responses.join("\n"), user_name: message.user_name
          when /^!8ball add (.*)$/
            message.processed!
            response = EightBallResponse.create(text: $1)
            if response.id.present?
              say "Response added", user_name: message.user_name
            else
              say "There was a problem adding your response", user_name: message.user_name
            end
          when /^!8ball remove (\d+)$/
            message.processed!
            response = EightBallResponse.where(id: $1).first
            if response.present?
              response.destroy
              say "Response removed", user_name: message.user_name
            else
              say "I couldn't find that response. Did you use the right id?", user_name: message.user_name
            end
          when /^!8ball.*$/
            message.processed!
            say describe_commands(message), user_name: message.user_name
          end
        else
          #
        end
      end

      def describe_commands(message)
        if message.from_admin?
          [
            "Manage the !8ball responses with",
            "!8ball list",
            "!8ball add <response>",
            "!8ball remove <id>"
          ].join("\n")
        else
          examples = [
            "Will I ever be a real boy?",
            "Has anyone really been far as decided to use even go want to do look more like?",
            "Does he love me?",
            "Will Donald Trump win the election?"
          ]

          "See into the future with\n!8ball #{examples.sample}"
        end
      end
    end
  end
end
