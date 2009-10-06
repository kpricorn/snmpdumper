require 'optparse'
require 'ostruct'

module SnmpDumper
  class Options
    SNMP_VERSIONS = {"1" => :SNMPv1, "2c" => :SNMPv2c, "3" => :SNMPv3}
    DEFAULT_PORT = 161
    DEFAULT_VERSION = SNMP_VERSIONS[:SNMPv2c]

    DEFAULT_INTERVAL = 10
    DEFAULT_WALKS = 3

    DEFAULT_COMMUNITY = "public"

    attr_reader :options

    def initialize(argv)
      parse(argv)
    end

    private
    def parse(argv)
      @options = OpenStruct.new
      @options.port = DEFAULT_PORT
      @options.interval = DEFAULT_INTERVAL
      @options.walks = DEFAULT_WALKS
      @options.oids = [
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
      
      @options.version = "2c"
      @options.debug = false
      @options.community = DEFAULT_COMMUNITY


      opts = OptionParser.new do |opts|
        opts.banner = "Usage: snmpdumper [options] host [oids]"

        opts.separator ""        
        opts.separator "Specific options:"

        opts.on("-p", "--port", Integer, "SNMP agent port  (Default: #{DEFAULT_INTERVAL})") do |port|
          @options.port = port
        end

        opts.on("-i", "--interval", Integer, "walk interval in seconds (Default: #{DEFAULT_INTERVAL})") do |interval|
          @options.interval = interval
        end

        opts.on("-w", "--walks", Integer, "number of walks (Default: #{DEFAULT_WALKS})") do |walks|
          @options.walks = walks
        end

        opts.separator ""
        opts.separator "snmpwalk options:"

        opts.on("-r", "--retries", Integer, "set the number of retries") do |retries|
          @options.retries = retries
        end

        opts.on("-t", "--timeout", Integer, "set the request timeout (in seconds)") do |timeout|
          @options.timeout = timeout
        end

        opts.on("-v [VERSION]", SNMP_VERSIONS,
        "specifies SNMP version to use #{SNMP_VERSIONS.keys.join(', ')} (Default: #{@options.version})") do |version|
          options.version = version if version
        end

        opts.separator ""
        opts.separator "SNMP Version 1 or 2c specific:"

        opts.on("-c [community]", "--community [community]", "set the community string") do |community|
          @options.community = community
        end

        opts.separator ""
        opts.separator "SNMP Version 3 specific:"

        opts.on("-A [PASSPHRASE]", "set authentication protocol pass phrase") do |auth_passphrase|
          @options.auth_passphrase = auth_passphrase
        end

        opts.on("-X [PASSPHRASE]", "set privacy protocol pass phrase") do |privacy_passphrase|
          @options.privacy_passphrase = privacy_passphrase
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on("-d", "--[no-]debug", "print debug messages") do |d|
          @options.debug = d
        end

        opts.on("-h", "--help", "display this help message") do 
          puts opts
          exit
        end

        opts.on_tail("-V", "--version", "show version") do
          puts OptionParser::Version.join('.')
          exit
        end

        begin
          argv = ["-h"] if argv.empty?
          opts.parse!(argv)
          raise OptionParser::MissingArgument.new(@options.community) if 
          @options.version == :SNMPv3 && 
          (@options.auth_passphrase.nil? || @options.privacy_passphrase.nil?)
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end

        @options.host = argv.shift
        @options.oids = argv

      end #OptionParser.new

    end #parse(argv)

  end #class Options
end # module SnmpDumper
