require 'abstract_unit'

module ActionDispatch
  module Routing
    class TestTrie < ActiveSupport::TestCase
      def setup
        @object = Object.new
        @trie   = Routing::Trie.new
      end

      def test_add_object_trie
        @trie.add('/pets(/:name)(.:format)', @object)

        assert_object_in_trie_for_key('/pets/rover.xml')
        assert_object_in_trie_for_key('/pets/rover')
        assert_object_in_trie_for_key('/pets.xml')
        assert_object_in_trie_for_key('/pets')

        assert_no_object_in_trie_for_key('/')
        assert_no_object_in_trie_for_key('/users/show')
      end

      def assert_object_in_trie_for_key(key)
        assert @trie.find(key).any? { |n| n.value == [@object] }
      end

      def assert_no_object_in_trie_for_key(key)
        assert @trie.find(key).all? { |n| n.value.empty? }
      end
    end
  end
end
