%w(fileutils snmp builder pp).each { |f| require f }

module SnmpDumper
  class Walker
    def initialize(options)
      @options = options
    end

    def walk(dumper)
      snmpconfig = { :Host => @options.host, :Port => @options.port, :Version => @options.version}

      if @options.version == :SNMPv3 then
        snmpconfig.merge! Hash.new()
      else
        snmpconfig.merge! :Community => @options.community
      end

      STDERR.puts snmpconfig if $DEBUG
      manager = SNMP::Manager.new(snmpconfig)

      model = @options.model || manager.get_value('sysDescr.0')

      dumper.model = model
      dumper.category = @options.category
      
      dumper.snmp_vars = Hash.new
      (1..@options.walks).each do |i|
        STDERR.puts "Walk #{i}/#{@options.walks}: start" if $DEBUG

        @options.oids.each do |oid|
          begin
            manager.walk(oid) do |var_bind|
              dumper.snmp_vars["#{var_bind.name}"] ||= SnmpVar.new(:name => var_bind.name)
              dumper.snmp_vars["#{var_bind.name}"].values << var_bind.value
            end
          rescue SNMP::RequestTimeout => e
            raise e if dumper.snmp_vars.empty?
          end
        end

        STDERR.puts "Walk #{i}/#{@options.walks}: end" if $DEBUG
        if i != @options.walks then
          STDERR.puts "Sleep for #{@options.interval} seconds" if $DEBUG
          sleep @options.interval 
        end
      end

      manager.close

    end # (1..@options.walks).each

  end
end
