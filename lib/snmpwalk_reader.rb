module SnmpDumper
  class SnmpwalkReader
    CLASS_CALLBACK = {
      "Gauge32" => lambda { |value| SNMP::Gauge32.new(Integer(value)) },
      "Counter32" => lambda { |value| SNMP::Counter32.new(Integer(value)) },
      "Counter64" => lambda { |value| SNMP::Counter64.new(Integer(value)) },
      "Hex-STRING" => lambda { |value| SNMP::OctetString.new(value) },
      "IpAddress" => lambda { |value| SNMP::IpAddress.new(value) },
      "OID" => lambda { |value|
        value.strip!
        /^\.?((?:\d+\.)*\d+)$/ =~ value
        raise ArgumentError, value if Regexp.last_match(0).nil?
        SNMP::ObjectId.new(Regexp.last_match(1))
        }, "Timeticks" => lambda { |value|
          value.strip!
          /^\((\d+)\).*$/ =~ value
          raise value if Regexp.last_match(0).nil?
          SNMP::TimeTicks.new(Integer(Regexp.last_match(1)))
          }, "INTEGER" => lambda { |value|
            /^(.*\()*(\d+).*$/ =~ value
            return nil if Regexp.last_match(0).nil?
            SNMP::Integer.new(Integer(Regexp.last_match(2)))
            },
          }


    def initialize(options)
      STDERR.puts "SnmpwalkReader: initialize" if $DEBUG
      @options = options
    end

    def parse_snmpwalk_line(line)
      result = {}
      /^(\.?\d+(?:\.?\d)+)\s*=\s*([^:]+):\s*\"?([^"]*)\"?$/ =~ line

      if Regexp.last_match(0).nil?
        raise ArgumentError,  "Invalid line: #{line}"
      end
      result = {:oid => Regexp.last_match(1), :class => Regexp.last_match(2) }
      callback = CLASS_CALLBACK[result[:class]]

      value = Regexp.last_match(3)
      value = callback.call(value) if callback
      result[:value] = value

      STDERR.puts "SnmpwalkReader: oid = #{result[:oid]} / class = #{result[:class]} / value = #{result[:value]}" if $DEBUG
      result
    end

    def walk(dumper)
      STDERR.puts "SnmpwalkReader: walk start" if $DEBUG

      if $stdin.tty? || @options.in_filename then
        STDERR.puts "SnmpwalkReader: read from file #{@options.in_filename}" if $DEBUG
        input = File.open(@options.in_filename, 'r')
      else
        STDERR.puts "SnmpwalkReader: read from stdin" if $DEBUG
        input = $stdin
      end

      input.each_line do |line|
        line.rstrip! # Remove trailing newline
        STDERR.puts "SnmpwalkReader: processing line #{line}" if $DEBUG

        begin
          result = parse_snmpwalk_line line
          dumper.add_snmp_var({:name => result[:oid], :value => result[:value]})
        rescue Exception => e
          raise ArgumentError, "Error encountered while parsing the line (-f ignore errors): \n
          #{line}\n
          Format for input:\n
          <numerical oid> = <Type>: <value>\n
          Example: .1.3.6.1.2.1.1.1.0 = STRING: Linux lom0.taa-edu.local 2.6.17.6 #1 SMP Thu Mar 8 15:32:13 CET 2007 i686\n
          snmpwalk command example: snmpwalk -v 3 -u user -A PW -X PW -a MD5 -x DES -l authPriv -On -Oa 192.168.1.1" unless @options.force
        end

      end

      input.close

      STDERR.puts "SnmpwalkReader: walk start" if $DEBUG

    end
  end
end