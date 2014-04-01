require 'abstract_unit'

module ActionDispatch
  module Routing
    class TestPathTemplateParser < ActiveSupport::TestCase
      def test_parse_simple_path_template
        template  = '/foo/:id(.:format)'
        parser    = Routing::PathTemplateParser.new
        key_paths = [
          ['', 'foo', ':id'],
          ['', 'foo', ':id', ':format'],
        ]

        assert_equal parser.parse(template), key_paths
      end

      def test_parse_canonical_non_resourceful_template
        template  = '/:controller(/:action)(.:format)'
        parser    = Routing::PathTemplateParser.new
        key_paths = [
          ['', ':controller'],
          ['', ':controller', ':action'],
          ['', ':controller', ':action', ':format'],
          ['', ':controller', ':format']
        ]

        assert_equal parser.parse(template), key_paths
      end

      def test_parse_optional_group_at_beginning_of_template
        template  = '(/widgets(/thingies))(/doo_dads)/gizmos(.:format)'
        parser    = Routing::PathTemplateParser.new
        key_paths = [
          ['', 'widgets', 'thingies', 'doo_dads', 'gizmos'],
          ['', 'widgets', 'thingies', 'doo_dads', 'gizmos', ':format'],
          ['', 'widgets', 'thingies', 'gizmos'],
          ['', 'widgets', 'thingies', 'gizmos', ':format'],
          ['', 'widgets', 'doo_dads', 'gizmos'],
          ['', 'widgets', 'doo_dads', 'gizmos', ':format'],
          ['', 'widgets', 'gizmos'],
          ['', 'widgets', 'gizmos', ':format'],
          ['', 'doo_dads', 'gizmos'],
          ['', 'doo_dads', 'gizmos', ':format'],
          ['', 'gizmos'],
          ['', 'gizmos', ':format']
        ]

        assert_equal parser.parse(template), key_paths
      end
    end
  end
end
