%w(builder).each { |f| require f }

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
      value_set.JSVALUE("value" => "foo")
    end
  end

  TIMETICKS_VALUE_CALLBACK = lambda do |value_set, name, values| 
    value_set.JSVALUE("value" => values.first.to_i)
  end

  INTEGER_VALUE_CALLBACK = lambda do |value_set, name, values|
    values = values.collect {|x| x.to_i}
    values.uniq!

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
    SNMP::Counter64 => {:syntax => "COUNTER", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::Gauge32 => {:syntax => "GAUGE", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::Integer => {:syntax => "INTEGER", :callback => INTEGER_VALUE_CALLBACK},
    SNMP::IpAddress => {:syntax => "IPADDRESS", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::ObjectId => {:syntax => "OBJECTIDENTIFIER", :callback => GENERIC_VALUE_CALLBACK},
    SNMP::OctetString => {:syntax => "OCTETSTRING", :callback => OCTETSTRING_VALUE_CALLBACK},
    SNMP::TimeTicks => {:syntax => "TIMETICKS", :callback => TIMETICKS_VALUE_CALLBACK},
    String => {:syntax => "OCTETSTRING", :callback => GENERIC_VALUE_CALLBACK},
  }
  
  class SnmpVar
    attr_accessor :name, :values
    def initialize(args)
      raise ArgumentError.new("Wrong paramters: ") unless args[:name]
      self.name = args[:name]
      self.values = []
    end

    def dump(jssnmpdevice)
      jssnmpdevice.JSSNMPVAR do |jssnmpvar|
        syntax_hash = DATA_TYPE_MAP[values.first.class] || {:syntax => "OCTETSTRING", :callback => OCTETSTRING_VALUE_CALLBACK}
        jssnmpvar.JSOID("syntax" => syntax_hash[:syntax], "value" => name)
        jssnmpvar.JSVALUESET { |value_set| DATA_TYPE_MAP[values.first.class][:callback].call(value_set, name, values) }
      end
    end
  end

  class JalasoftDumper
    attr_accessor :category
    attr_accessor :model
    attr_accessor :snmp_vars
    attr_accessor :model
    attr_accessor :category

    def initialize(options)
      @model = options.model
      @category = options.category
      @snmp_vars = Hash.new
    end

    def dump
      builder = Builder::XmlMarkup.new(:indent=>2)
      
      builder.JSSNMPDEVICE("category" => @category, "model" => get_model) do |jssnmpdevice|
        @snmp_vars.values.each do |snmp_var|
          snmp_var.dump(jssnmpdevice)
        end
      end
    end

    def add_snmp_var(args)
      raise ArgumentError.new("Invalid arguments") unless args[:name] && args[:value]
      @snmp_vars[args[:name]] ||= SnmpVar.new(:name => args[:name])
      @snmp_vars[args[:name]].values << args[:value]
    end

    def get_model
      return @model if @model
      m = @snmp_vars[".1.3.6.1.2.1.1.1.0"]
      return "Unknown Model" unless m
      m.values.first
    end
  end
end