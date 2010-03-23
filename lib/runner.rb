require 'walker'
require 'snmpwalk_reader'
require 'config'

Dir.glob(File.join(File.dirname(__FILE__), 'dumper/*.rb')).each {|f| require f }

module SnmpDumper
  class Runner
    def initialize(argv)
      begin
        @config = Config.new(argv)
        rescue Exception => e
          STDERR.puts e.message
          STDERR.puts e.backtrace.join("\n") if $DEBUG
          exit(-1)
        end
    end

    def run
      begin
        ## interactive shell?
        if !$stdin.tty? || @config.options.in_filename then
          walker = SnmpwalkReader.new(@config.options)
        else
          walker = Walker.new(@config.options)
        end

        dumper = SnmpDumper.const_get(@config.options.dumper)::new(@config.options)

        walker.walk(dumper)

        if @config.options.out_filename
          File.open(@config.options.out_filename, 'w') { |f| f.write(dumper.dump) }  
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