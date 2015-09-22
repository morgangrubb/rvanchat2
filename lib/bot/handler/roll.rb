module Bot
  module Handler

    class Roll < Bot::Handler::Base

      def public_message(message, params)
        case message.text
        when /^!roll (.*)$/
          message.processed!
          roll_set = RollSet.new($1)
          say "#{message.user_name} rolls #{roll_set.to_s} for #{roll_set.to_i}", record: true
        when /^!roll$/
          message.processed!
          roll_set = RollSet.new("d20")
          say "#{message.user_name} rolls #{roll_set.to_s} for #{roll_set.to_i}", record: true
        end
      end

      def describe_commands(message)
        if message.from_admin?
          [
            "Roll a d20 with:",
            "!roll",
            "Or more complicated rolls:",
            "!roll 3d8+d6+2"
          ].join("\n")
        end
      end

      class RollSet
        class DiceSet
          attr_reader :operator, :value, :die

          def initialize(operator, value, die)
            @operator = operator
            @value    = value
            @die      = die
          end

          def to_s
            str = ""

            if operator
              str << "#{operator}"
            end

            representation =
              if value && die
                # 2d20
                "#{value}d#{die}"
              elsif value.nil? && die
                # d20
                "d#{die}"
              elsif value && die.nil?
                # 3
                "#{value}"
              else
                "?"
              end

            str << "#{representation}"
          end

          def to_i
            return @final_value if defined? @final_value

            absolute_value =
              if value && die
                # 2d20
                roll(value.to_i)
              elsif value.nil? && die
                # d20
                roll(1)
              elsif value && die.nil?
                # 3
                value.to_i
              else
                0
              end

            @final_value =
              case operator
              when '-'
                absolute_value * -1
              else
                absolute_value
              end

          end

          def roll(count)
            sum = 0
            count.times do
              sum += rand(1..(die.to_i))
            end
            sum
          end
        end

        attr_reader :str

        def initialize(str, options = {})
          @str = str
        end

        def parsed
          return @parsed if defined? @parsed

          @parsed = []
          str.scan /([+-])?\s*(\d+)?(?:d(\d+))?/i do |operator, count, die|
            next if operator.nil? && count.nil? && die.nil?
            @parsed << DiceSet.new(operator, count, die)
          end
          @parsed
        end

        def to_i
          parsed.sum(&:to_i)
        end

        def to_s
          parsed.collect(&:to_s).join
        end
      end

    end
  end
end
