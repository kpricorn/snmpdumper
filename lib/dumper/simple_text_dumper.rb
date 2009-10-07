module SnmpDumper
  class SimpleTextDumper
    attr_accessor :model
    attr_accessor :category
    
    def initialize(options)
    end
    
    def snmp_vars
    end
    
    def snmp_vars=(args)
      puts args.inspect
    end

  end
end