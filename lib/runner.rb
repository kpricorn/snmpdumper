require_relative 'walker'
require_relative 'options'

module SnmpDumper
  class Runner
    
    def initialize(argv)
      @options = Options.new(argv)
    end
    
    def run
      walker = Walker.new(@options.options)
      begin
        walker.walk
      rescue Exception => e
        STDERR.puts e.message
        exit -1
      end
      exit 0
    end
  end
end