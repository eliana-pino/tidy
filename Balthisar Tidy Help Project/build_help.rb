#!/usr/bin/env ruby

############################################
# build_help.rb
#   This will build a Balthisar Tidy help
#   book using the specified build
#   configuration.
#
# Usage:
#    build_help web
#    build_help app
#    build_help pro
############################################

require 'nokogiri'
require 'fileutils'

$CFBundleName = 'Balthisar Tidy'
$CFBundleIDs = {
                 'web' => 'com.balthisar.web.free.balthisar-tidy.help',
                 'app' => 'com.balthisar.Balthisar-Tidy.help',
                 'pro' => 'com.balthisar.Balthisar-Tidy.pro.help',
                }
$CFBundleIdentifier = 'com.company.app.help'

$plist_template = "Contents (source)/_Info.plist"
$plist_destination = "Contents (source)/Info.plist"
$strings_template = "Contents (source)/Resources/Base.lproj/_InfoPlist.strings"
$strings_destination ="Contents (source)/Resources/Base.lproj/InfoPlist.strings"

# local directory where finished .help build should go. Make null to
# leave in the help project directory. Must use a final path separator!
$FinalOutputPrefix = "../Balthisar Tidy/Resources/"

###################################
# Capture command line arguments.
###################################

unless $CFBundleIDs.key?(ARGV[0])
   STDOUT.puts <<-EOF

   This tool generates a complete Apple Help Book using middleman as
   a static generator, and supports multiple build targets. It is
   necessary to specify a build target.

   Usage:
     build_help web
     build_help app
     build_help pro

    EOF
    exit 0
end


###################################
# Define Remaning Variables
###################################
$CFBundleIdentifier = $CFBundleIDs[ARGV[0]]
$FinalOutput = "#{$FinalOutputPrefix}#{$CFBundleName} (#{ARGV[0]}).help"

ENV['CFBundleName'] = $CFBundleName
ENV['CFBundleIdentifier'] = $CFBundleIdentifier
ENV['HelpBookTaget'] = ARGV[0]

STDOUT.puts "\nWill use CFBundleName = #{$CFBundleName} and CFBundleIdentifier = #{$CFBundleIdentifier}."


###################################
# Feature Specific Env. Vars
###################################
ENV['feature_advertise_pro']        = (ARGV[0] == "web" || ARGV[0] == "app") ? "yes" : "no"
ENV['feature_sparkle']              = (ARGV[0] == "web") ? "yes" : "no"
ENV['feature_exports_config']       = (ARGV[0] == "pro") ? "yes" : "no"
ENV['feature_supports_applescript'] = (ARGV[0] == "pro") ? "yes" : "no"
ENV['feature_supports_service']     = (ARGV[0] == "pro") ? "yes" : "no"
ENV['feature_supports_extensions']  = (ARGV[0] == "pro") ? "yes" : "no"
ENV['feature_supports_SxS_diffs']   = (ARGV[0] == "pro") ? "yes" : "no"


###################################
# Process the .plist and .strings.
###################################

# open and check existance of files.
unless File::exists?($plist_template)
    STDOUT.puts "\n     Expected to find the .plist template: #{$plist_template}, but didn't. Exiting.\n\n"
    exit 1
end

unless File::exists?($strings_template)
    STDOUT.puts "\n     Expected to find the .strings template: #{$strings_template}, but didn't. Exiting.\n\n"
    exit 1
end


# Process the .plist
STDOUT.puts "Processing the .plist..."
$file = File.open($plist_template)
$doc = Nokogiri.XML($file)
$file.close

#puts $doc.to_xml(:indent => 2)
$doc.traverse do |node|
    if node.text?
        node.content = node.content.gsub('{$CFBundleIdentifier}', $CFBundleIdentifier)
        node.content = node.content.gsub('{$CFBundleName}', $CFBundleName)
    end
end
#puts $doc.to_xml(:indent => 2)

File.open($plist_destination,'w') {|f| $doc.write_xml_to f}


# Process the .strings
STDOUT.puts "Processing the .strings..."
$file = File.open($strings_template)
$doc = Nokogiri.XML($file)
$file.close

#puts $doc.to_xml(:indent => 2)
$doc.traverse do |node|
    if node.text?
        node.content = node.content.gsub('{$CFBundleIdentifier}', $CFBundleIdentifier)
        node.content = node.content.gsub('{$CFBundleName}', $CFBundleName)
    end
end
#puts $doc.to_xml(:indent => 2)

File.open($strings_destination,'w') {|f| $doc.write_xml_to f}


###################################
# Run middleman.
###################################

STDOUT.puts "Building content with middleman..."

`middleman build`
unless $?.success?
    STDOUT.puts "\nNOTE: `middleman` did not exit cleanly. Build process will stop now."
    exit 1
end


###################################
# Run hiutil.
###################################

STDOUT.puts "Running the help indexer..."

`command -v hiutil > /dev/null`
unless $?.success?
    STDOUT.puts "\n     NOTE: `hituil` is not on path or not installed. A new help index will NOT be generated.\n\n"
end

`hiutil -Cf "Contents (build)/Resources/Base.lproj/#{$CFBundleName}.helpindex" "Contents (build)/Resources/Base.lproj"`


###################################
# Setup the final help directory.
###################################

STDOUT.puts "Assembling the project output into #{$FinalOutput}..."

Dir.mkdir($FinalOutput) unless File.directory?($FinalOutput)
FileUtils.copy_entry("Contents (build)" , $FinalOutput + "/Contents",false,false,true)

STDOUT.puts "\nBuilding `#{$FinalOutput}` is complete.\n\n"
