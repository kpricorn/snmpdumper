%w(fileutils snmp builder pp).each { |f| require f }

module SnmpDumper
  GENERIC_VALUE_CALLBACK = lambda do |value_set, name, values| 
    value = values.first
    value_set.JSVALUE("value" => value)
  end

  OCTETSTRING_VALUE_CALLBACK = lambda do |value_set, name, values|
    value = values.first
    if value =~ /[[:cntrl:]]/ then
      value_set.JSVALUE("value" => value.unpack('H*').first.upcase.scan(/.{1,2}/).join(" "), "hexa" => 1)
    else
      value_set.JSVALUE("value" => value, "hexa" => 0)
    end
  end

  TIMETICKS_VALUE_CALLBACK = lambda do |value_set, name, values| 
    value_set.JSVALUE("value" => values.first.to_i)
  end

  INTEGER_VALUE_CALLBACK = lambda do |value_set, name, values|
    puts values.inspect
    values = values.collect {|x| x.to_i}
    puts values.inspect
    values.uniq!
    puts values.inspect
    if values.size > 1 then
      values.each do |value|
        value_set.JSVALUE("value" => value.to_i, "weight" => 100 / values.size)
      end
    else
      value_set.JSVALUE("value" => values.first.to_i)
    end
  end

  DATA_TYPE_MAP = {
    SNMP::Counter32 => {:syntax => "COUNTER", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::Gauge32 => {:syntax => "GAUGE", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::Integer => {:syntax => "INTEGER", :callback => INTEGER_VALUE_CALLBACK},
    SNMP::IpAddress => {:syntax => "IPADDRESS", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::ObjectId => {:syntax => "OBJECTIDENTIFIER", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::OctetString => {:syntax => "OCTETSTRING", :callback => OCTETSTRING_VALUE_CALLBACK},
    SNMP::TimeTicks => {:syntax => "TIMETICKS", :callback => TIMETICKS_VALUE_CALLBACK}
  }

  class SnmpDevice
    attr_accessor :category
    attr_accessor :model
    attr_accessor :snmp_vars

    def dump
      builder = Builder::XmlMarkup.new(:indent=>2)
      builder.JSSNMPDEVICE("category" => "windows", "model" => "Microsoft Windows 2003") do |jssnmpdevice|
        self.snmp_vars.values.each do |snmp_var|
          snmp_var.dump(jssnmpdevice)
        end
      end
    end
  end

  class SnmpVar
    attr_accessor :name, :values

    def initialize(args)
      raise ArgumentError.new("Wrong paramters: ") unless args[:name]
      self.name = args[:name]
      self.values = []
    end

    def dump(jssnmpdevice)
      jssnmpdevice.JSSNMPVAR do |jssnmpvar|
        jssnmpvar.JSOID("syntax" => DATA_TYPE_MAP[values.first.class][:syntax], "value" => name)
        jssnmpvar.JSVALUESET { |value_set| DATA_TYPE_MAP[values.first.class][:callback].call(value_set, name, values) }
      end
    end
  end

  class Walker
    def initialize(options)
      @options = options
    end

    def walk
      device = SnmpDevice.new
      device.snmp_vars = Hash.new

      snmpconfig = { :Host => @options.host}

      if @options.version == :SNMPv3 then
        snmpconfig.merge Hash.new(:Community => 'tacmon', :Version => @options.version)
      else
        snmpconfig.merge Hash.new(:Community => 'tacmon', :Version => @options.version)
      end
      

      manager = SNMP::Manager.new(snmpconfig)

      (1..@options.walks).each do |i|
       @options.oids.each do |oid|
          begin
            manager.walk(oid) do |var_bind|
              device.snmp_vars["#{var_bind.name}"] ||= SnmpVar.new(:name => var_bind.name)
              # print device.snmp_vars["#{var_bind.name}"].values.size.to_s + " (" + device.snmp_vars["#{var_bind.name}"].values.inspect + ") -> "
              device.snmp_vars["#{var_bind.name}"].values << var_bind.value
              # puts device.snmp_vars["#{var_bind.name}"].values.size.to_s + " (" + device.snmp_vars["#{var_bind.name}"].values.inspect + ")"
            end
          rescue SNMP::RequestTimeout => e
            raise e if device.snmp_vars.empty?
          end
          
          sleep @options.interval
        end
      end
      puts device.dump

      manager.close
    end
  end
end
