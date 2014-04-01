require 'action_dispatch/routing/trie/node'
require 'action_dispatch/routing/simple_scanner'

module ActionDispatch
  module Routing # :nodoc:
    class Trie # :nodoc:
      def initialize
        @root = Node.new
      end

      def find(key)
        scanner = SimpleScanner.new(key)
        nodes   = [@root]

        while key = scanner.scan
          children = nodes.flat_map { |n| n.children_for key }
          nodes = children unless children.empty?
        end

        nodes
      end

      def add(key, value)
        parser    = PathTemplateParser.new
        key_paths = parser.parse(key)

        key_paths.each do |key_path|
          node = @root

          if node.match(key_path.first) && !key_path[1]
            node.value << value
          else
            key_path[1..-1].each do |segment|
              node, _node = node.children.detect { |n| n.key == segment }, node

              unless node
                node = Node.new(segment, _node)
                _node.add_child node
              end
            end

            node.value << value
          end
        end
      end
    end
  end
end
