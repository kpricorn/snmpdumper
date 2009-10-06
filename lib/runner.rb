require 'walker'
require 'dumper'
require 'options'

Dir.glob(File.join(File.dirname(__FILE__), 'dumper/*.rb')).each {|f| require f }

module SnmpDumper
  class Runner
    def initialize(argv)
      @options = Options.new(argv)
    end

    def run
      begin
        walker = Walker.new(@options.options)
        dumper = SnmpDumper.const_get(@options.options.dumper)::new(@options.options)

        walker.walk(dumper)

        if @options.options.filename
          File.open(@options.options.filename, 'w') { |f| f.write(dumper.dump) }  
        else
          puts dumper.dump
        end

      rescue Exception => e
        STDERR.puts e.message
        raise e
        exit(-1)
      end
      exit(0)
    end
  end
end