$:.unshift File.dirname(__FILE__)
%w( rubygems fileutils snmp builder getoptlong rdoc/usage).each { |f| require f }
RUBY_PLATFORM = PLATFORM unless defined? RUBY_PLATFORM   # Ruby 1.8 compatibility

module SnmpDumper
  extend self

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

    def to_s
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

  def dump(args)
    args = args.dup
    return unless parse_args(args)



    device = SnmpDevice.new
    device.snmp_vars = Hash.new

    snmpconfig ={ :Host => '172.27.174.72', :Community => 'tacmon', :Version => :SNMPv2c}

    manager = SNMP::Manager.new(snmpconfig)

    oids = [
      "1",
      "1.3.6.1.4.1.9.2.1.40.0",
      "1.3.6.1.4.1.9.2.1.41.0",
      "1.3.6.1.4.1.9.2.1.42.0",
      "1.3.6.1.4.1.9.2.1.43.0",
      "1.3.6.1.4.1.9.2.1.44.0",
      "1.3.6.1.4.1.9.2.1.45.0",
      "1.3.6.1.4.1.9.2.1.46.0",
      "1.3.6.1.4.1.9.2.1.47.0",
      "1.3.6.1.4.1.9.2.1.48.0",
      "1.3.6.1.4.1.9.2.1.49.0",
      "1.3.6.1.4.1.9.2.4.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.3.1.1.2.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.3.1.1.3.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.3.1.1.4.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.3.1.1.5.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.3.1.1.6.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.3.1.1.7.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.10.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.11.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.12.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.2.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.3.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.4.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.5.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.6.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.7.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.8.1.1",
      "1.3.6.1.4.1.9.9.10.1.1.4.1.1.9.1.1",
      "1.3.6.1.4.1.9.9.106.1.1.1.0",
      "1.3.6.1.4.1.9.2.1",
      "1.3.6.1.4.1.9.2.2",
      "1.3.6.1.4.1.9.3.6",
      "1.3.6.1.4.1.9.2.9",
      "1.3.6.1.4.1.9.2.10",
      "1.3.6.1.4.1.9.9.10",
      "1.3.6.1.4.1.9.9.23",
      "1.3.6.1.4.1.9.9.46",
      "1.3.6.1.4.1.9.9.48",
      "1.3.6.1.4.1.9.9.68",
      "1.3.6.1.4.1.9.9.87",
      "1.3.6.1.4.1.9.9.109",
      "1.3.6.1.4.1.9.1.324",
      "1.3.6.1.4.1.9.9.134"
    ]

    (1..2).each do |i|
      oids.each do |oid|
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
      end
    end
    puts device.to_s

    manager.close

  end

  def parse_args(args)
    opts = GetoptLong.new([ '--help', '-h', GetoptLong::NO_ARGUMENT ],
                          [ '--version', '-v', GetoptLong::NO_ARGUMENT ],
                          [ '--verbose', '-V', GetoptLong::NO_ARGUMENT ],
                          [ '--timeout', '-t', GetoptLong::REQUIRED_ARGUMENT ],
                          [ '--mib', '-m', GetoptLong::REQUIRED_ARGUMENT ],
                          [ '--protocol', '-p', GetoptLong::REQUIRED_ARGUMENT ],
                          [ '--comunity', '-c', GetoptLong::REQUIRED_ARGUMENT ]
                          )

    # Defaults
    timeout = 1000
    mib = "sysDescr.0"
    protocol = "2c"
    comunity = "public"
    verbose = false

    opts.each do |opt, arg|
      case opt
      when '--help'
        RDoc::usage
      when '--version'
        puts "snmpscan, version #$VERSION"
        exit 0
      when '--timeout'
        timeout = arg.to_i
      when '--mib'
        mib = arg
        unless mib =~ /\.\d+$/
          mib += ".0"
        end
      when '--protocol'
        protocol = arg
      when '--comunity'
        comunity = arg
      when '--verbose'
        verbose = true
      end
    end
    
    true
  end
end

SnmpDumper.sheets(ARGV) if __FILE__ == $0
