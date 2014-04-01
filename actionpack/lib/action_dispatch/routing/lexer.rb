require 'strscan'

module ActionDispatch
  module Routing # :nodoc:
    class Lexer # :nodoc:
      def initialize(string)
        @ss = StringScanner.new(string)
      end

      def next_token
        until @ss.eos? || token = scan; end
        token
      end

      private

        def scan
          @ss.scan(/\/|\./)

          case
          when text = @ss.scan(/\(/)
            [:LPAREN, text]
          when text = @ss.scan(/\)/)
            [:RPAREN, text]
          when text = @ss.scan(/[^\/.()]+/)
            [:TOKEN, text]
          end
        end
    end
  end
end
