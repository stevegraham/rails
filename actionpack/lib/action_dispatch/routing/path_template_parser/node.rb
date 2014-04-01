module ActionDispatch
  module Routing # :nodoc:
    class PathTemplateParser # :nodoc:
      class Node # :nodoc:
        attr_reader :nesting_level, :parent, :value, :required

        def initialize(value = '', parent = nil, required = true)
          @value         = value
          @parent        = parent
          @children      = []
          @required      = required
        end

        def recursively_add_child_for(lexeme, required_segment)
          nodes = @children.select(&:terminal?).flat_map do |c|
            c.recursively_add_child_for(lexeme, required_segment)
          end

          nodes << add_child_for(lexeme, required_segment)
        end

        def add_child_for(lexeme, required_segment)
          Node.new(lexeme, self, required_segment).tap { |n| @children << n }
        end

        def key_paths(memo = [])
          memo << to_key_path if exit?
          @children.reduce(memo) { |m, c| c.key_paths m }
        end

        def to_key_path
          @parent ? @parent.to_key_path.push(@value) : [@value]
        end

        def exit?
          @children.none?(&:required)
        end

        def terminal?
          @children.none? { |c| c.required && c.terminal? }
        end
      end
    end
  end
end
