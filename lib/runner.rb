require_relative 'walker'
require_relative 'options'

module SnmpDumper
  class Runner
    
    def initialize(argv)
      @options = Options.new(argv)
    end
    
    def run
      walker = Walker.new(@options.options)
      walker.walk
    end
  end
end