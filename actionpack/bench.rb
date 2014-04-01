require 'bundler/setup'

Bundler.setup

require 'benchmark'
require './lib/action_dispatch'

arr    = ["foo", "bar", "baz", "qux", "quux", "corge", "grault", "garply"]
paths  = arr.permutation(3).map { |a| "/#{a.join '/'}" }
set    = ActionDispatch::Routing::RouteSet.new(ActionDispatch::TestRequest)

class HelloWorld
  def initialize(response)
    @response = response
  end

  def call(env)
    [ 200, { 'Content-Type' => 'text/plain' }, [@response] ]
  end
end

times = 5.times.map do |i|
  set.clear!
  Benchmark.measure do
    set.draw do
      paths.each do |path|
        get path, to: HelloWorld.new(path)
      end
    end
  end
end


# times = 5.times.map do |i|
#   Benchmark.measure {
#     1000.times do |i|
#       paths.each do |path|
#         request      = ActionDispatch::TestRequest.new
#         request.path = path
#
#         set.call request.env
#       end
#     end
#   }
# end
#
sum      = times.reduce(0) { |memo, obj| memo + obj.real }
mean     = sum / times.length.to_f
variance = times.inject(0) { |memo, obj| memo + (obj.real - mean ) ** 2 }
variance = variance / (times.length - 1).to_f

puts times.map(&:real)

puts "Mean elapsed real time: #{mean} seconds"
puts "Standard Deviation: #{ Math.sqrt variance }"

# request      = ActionDispatch::TestRequest.new
# request.path = paths.first
#
# RubyProf.start
# response = set.call request.env
# raise 'broken' unless response.first == 200
#
# (paths * 100).each do |path|
#   request      = ActionDispatch::TestRequest.new
#   request.path = path
#
#   set.call request.env
# end
#
# data = RubyProf.stop
# printer = RubyProf::GraphPrinter.new(data)
#
# printer.print STDOUT
