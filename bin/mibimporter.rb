#!/usr/bin/env ruby -w

require 'rubygems'
require 'snmp'
require 'builder'

include SNMP

# my_dir = Dir["./mibs/*.my"]
# my_dir.each do |filename|
#   puts filename
#   MIB.import_module(filename)
# end

MIB.import_module("mibs/CISCO-SMI.my ./mibs/CISCO-TC.my ./mibs/CISCO-PROCESS-MIB.my")
