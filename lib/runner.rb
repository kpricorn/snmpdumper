require 'walker'
require 'snmpwalk_reader'
require 'options'

Dir.glob(File.join(File.dirname(__FILE__), 'dumper/*.rb')).each {|f| require f }

module SnmpDumper
  class Runner
    def initialize(argv)
      @options = Options.new(argv)
    end

    def run
      begin
        ## interactive shell?
        if !$stdin.tty? || @options.options.inputfile then
          walker = SnmpwalkReader.new(@options.options)
        else
          walker = Walker.new(@options.options)
        end

        dumper = SnmpDumper.const_get(@options.options.dumper)::new(@options.options)

        walker.walk(dumper)

        if @options.options.out_filename
          File.open(@options.options.out_filename, 'w') { |f| f.write(dumper.dump) }  
        else
          puts dumper.dump
        end

      rescue Exception => e
        STDERR.puts e.message
        STDERR.puts e.backtrace.join("\n") if $DEBUG
        exit(-1)
      end
      exit(0)
    end
  end
end