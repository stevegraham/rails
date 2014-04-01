require 'action_dispatch/routing/path_template_parser/node'
require 'action_dispatch/routing/lexer'

module ActionDispatch
  module Routing # :nodoc:
    class PathTemplateParser # :nodoc:
      def initialize
        @root          = Node.new
        @nesting_level = 0
        @target_nodes  = [@root]
      end

      def parse(path)
        @lexer = Routing::Lexer.new(path)

        while lex_pair = @lexer.next_token
          send(*lex_pair)
        end

        @root.key_paths
      end

      private

      def TOKEN(lexeme)
        @target_nodes.map! { |n| n.recursively_add_child_for lexeme, @nesting_level.zero? }
        @target_nodes.flatten!
      end

      def LPAREN(lexeme)
        @nesting_level += 1
      end

      def RPAREN(lexeme)
        @nesting_level -= 1
        @target_nodes.map!(&:parent)
        @target_nodes.uniq!(&:value)
      end
    end
  end
end
