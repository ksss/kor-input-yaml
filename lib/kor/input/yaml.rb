require 'yaml'

module Kor
  module Input
    class Yaml
      DEFAULT_GUESS_TIME = 5
      START = "---"

      def initialize(io)
        @io = io
        @keys = []
        @yamls = []
        @prekeys = nil
        @count = 0
        @stock = []
        @guess_time = DEFAULT_GUESS_TIME
        @fiber = Fiber.new do
          @yamls.each do |yaml|
            Fiber.yield @keys.map{ |k| yaml[k] }
          end
          # gets should be return nil when last
          Fiber.yield nil
        end
      end

      def parse(opt)
        opt.on("--key=KEY", "select keys (e.g. foo,bar,baz)") do |arg|
          @prekeys = arg
        end
        opt.on("--guess-time=NUM", "guess number of times (default #{DEFAULT_GUESS_TIME})") do |arg|
          @guess_time = arg.to_i
        end
      end

      def head
        if @prekeys
          @keys = @prekeys.split(",")
        else
          while yaml = read_yaml
            @yamls << yaml
            if 0 < @guess_time && @guess_time <= @yamls.length
              break
            end
          end
          @keys = @yamls.map { |yaml| yaml.keys }
          @keys.flatten!
          @keys.uniq!
        end
        @keys
      end

      def gets
        if @prekeys
          if yaml = read_yaml
            @keys.map{ |key| yaml[key] }
          else
            nil
          end
        elsif 0 < @guess_time
          if @count < @guess_time
            @count += 1
            return resume
          end
          if yaml = read_yaml
            @keys.map { |k| yaml[k] }
          else
            nil
          end
        else
          resume
        end
      end

      private

      def read_yaml
        while line = @io.gets
          @stock << line
          if line.index(START) == 0
            if 1 < @stock.length
              break
            end
          end
        end
        if @stock.empty?
          return nil
        end
        last_index = line ? -2 : -1
        YAML.load(@stock.slice!(0..last_index).join)
      end

      def resume
        @fiber.resume
      rescue FiberError
        nil
      end
    end

    require "kor/input/yaml/version"
  end
end
