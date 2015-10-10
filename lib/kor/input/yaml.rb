require 'yaml'

module Kor
  module Input
    class Yaml
      def initialize(io)
        @io = io
        @keys = []
        @yamls = []
        @prekeys = nil
        @count = 0
        @fiber = Fiber.new do
          @yamls.each do |yaml|
            Fiber.yield @keys.map{ |k| yaml[k] }
          end
          # gets should be return nil when last
          Fiber.yield nil
        end
      end

      def parse(opt)
        opt.on("--key=KEY", "preset keys (e.g. foo,bar,baz)") do |arg|
          @prekeys = arg
        end
      end

      def head
        if @prekeys
          line = @io.gets
          if line.index(START) != 0
            @io.seek(line.length, IO::SEEK_CUR)
          end
          @keys = @prekeys.split(",")
        else
          @yamls = YAML.load_stream(@io.read)
          @keys = @yamls.map do |yaml|
            yaml.keys
          end
          @keys.flatten!.uniq!
          @keys
        end
      end

      START = "---"
      EOF = "\n"

      def gets
        if @prekeys
          stock = ""
          while line = @io.gets
            stock << line
            if line.index(START) == 0
              break
            end
          end
          if stock == ""
            return nil
          end
          yaml = YAML.load(stock)
          @count += 1
          @keys.map{ |key| yaml[key] }
        else
          resume
        end
      end

      private

      def resume
        @fiber.resume
      rescue FiberError
        nil
      end
    end

    require "kor/input/yaml/version"
  end
end
