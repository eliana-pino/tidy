#!/usr/bin/env ruby
###############################################################################
#  helpbook.rb
#
#    Consists of both:
#    - the `helpbook` command-line tool for invoking Middleman with multiple
#      targets, as well as some basic utilities, and
#
#    - the `Helpbook` class that Middleman requires to perform additional
#      functions related to generating Apple Helpbooks.
#
#    Together, they will:
#    - Build automatic CSS max-width for all images.
#    - Build a partial containing markdown links to all html file.
#    - Build a partial containing markdown links to all images.
#    - Process *.plist files with data for building a helpbook.
#    - Provide helpers for determining build targets.
#    - Provide functions for simplifying dealing with the sitemap.
#
#    Building:
#    - ./helpbook target-1 target-2 target-n || all
#    - HBTARGET=target middleman build
#    - HBTARGET=target bundle exec middleman build
#
#    Note:
#     In a better world this file would be split up, of course. For end-user
#     convenience and ease of distribution, this single file script is used.
###############################################################################

require 'fastimage'
require 'fileutils'
require 'nokogiri'
require 'pathname'
require 'yaml'


#---------------------------------------------------------------
# ANSI terminal codes for use in documentation strings.
#---------------------------------------------------------------
A_BLUE      = "\033[34m"
A_CYAN      = "\033[36m"
A_GREEN     = "\033[32m"
A_RED       = "\033[31m"
A_RESET     = "\033[0m"
A_UNDERLINE = "\033[4m"


#---------------------------------------------------------------
# Output in color and abstract standard out.
#---------------------------------------------------------------
def puts_blue(string)
  puts "\033[34m" + string + "\033[0m"
end
def puts_cyan(string)
  puts "\033[36m" + string + "\033[0m"
end
def puts_green(string)
  puts "\033[32m" + string + "\033[0m"
end
def puts_red(string)
  puts "\033[31m" + string + "\033[0m"
end
def puts_yellow(string)
  puts "\033[33m" + string + "\033[0m" # really ANSI brown
end


#---------------------------------------------------------------
# Command-Line documentation.
#---------------------------------------------------------------
def documentation(targets_array)
<<-HEREDOC
#{A_CYAN}This tool generates a complete Apple Help Book using Middleman as
a static generator, and supports multiple build targets. It is
necessary to specify one or more build targets.

  #{A_UNDERLINE}Use:#{A_RESET}#{A_CYAN}
#{targets_array.sort.collect { |item| "    helpbook #{item}"}.join("\n")}
    helpbook all

Also, any combination of #{targets_array.join(', ')} or all can be used to build
multiple targets at the same time.

  #{A_UNDERLINE}Switches:#{A_RESET}#{A_CYAN}
    -v, --verbose    Executes Middleman in verbose mode for each build target.
    -q, --quiet      Silences Middleman output, even if --verbose is specified.#{A_RESET}

HEREDOC
end



##########################################################################
#  Command-Line Script
#    Slow to use for a single target, because we run Middleman once in
#    order to get a list of the valid targets. However it's useful for
#    building multiple targets, if desired.
##########################################################################
if __FILE__ == $0

  # Lower-case everything and eliminate duplicate arguments.
  targets = ARGV.map(&:downcase).uniq

  # Find out if there are any switches.
  # can be -q, --quiet, -v, --verbose
  BE_QUIET = targets.include?('-q') || targets.include?('--quiet')
  BE_VERBOSE = targets.include?('-v') || targets.include?('--verbose')

  # Remove switches.
  targets.delete_if {|item| %w(-q --quiet -v --verbose).include?(item)}

  # Build an array of valid targets. This is the part that slows things down.
  puts_blue 'Determining valid targets…'
  valid_targets = `HBTARGET=improbable_value bundle exec middleman build`.split("\n")

  # Ensure each argument is valid, and fail if not.
    if targets.count > 0
      targets.each do |target|
        unless valid_targets.include?(target) || target == 'all'
          puts documentation(valid_targets)
          exit 1
        end
      end
    else
      # No arguments isn't a failure.
      puts documentation(valid_targets)
      exit 0
    end

  # Build each target.
  targets = targets.include?('all') ? valid_targets : targets

  targets.each do |target|
    puts_blue "Starting build for target '#{target}'…"

    result = system("HBTARGET=#{target} bundle exec middleman build #{'--verbose' if BE_VERBOSE} #{'>/dev/null' if BE_QUIET}")

    unless result
      puts_red "** NOTE: `middleman` did not exit cleanly for target '#{target}'. Build process will stop now."
      puts_red "   Consider using the --verbose flag to identify the source of the error. The error reported was:"
      puts_red "   #{$?}"
      exit 1
    end
  end

  puts_green '** ALL TARGETS COMPLETE **'

  exit 0
end



##########################################################################
#  Helpbook Class
##########################################################################

class Helpbook < Middleman::Extension


#===============================================================
#  Configuration options
#   You do NOT have to change any of these. These are part of
#   the class. These options must be configured in config.rb.
#===============================================================

option :Target, 'default', 'The default target to process if not specified.'
option :CFBundleName, nil, 'The CFBundleName key; will be used in a lot of places.'
option :Help_Output_Location, nil, 'Directory to place the built helpbook.'
option :Targets, nil, 'A data structure that defines many characteristics of the target.'
option :Build_Markdown_Links, true, 'Whether or not to generate `_markdown-links.erb`'
option :Build_Markdown_Images, true, 'Whether or not to generate `_markdown-images.erb`'
option :Build_Image_Width_Css, true, 'Whether or not to generate `_image_widths.scss`'

option :File_Markdown_Images, '_markdown-images.erb', 'Filename for the generated images markdown file.'
option :File_Markdown_Links,  '_markdown-links.erb',  'Filename for the generated links markdown file.'
option :File_Image_Width_Css, '_image_widths.scss', 'Filename for the generated image width css file.'
option :File_Titlepage_Template, '_title_page.html.md.erb', 'Filename of the template for the title page.'



#===============================================================
#  initializer
#===============================================================
def initialize(app, options_hash={}, &block)
  super
  app.extend ClassMethods

  # Ensure target exists. Value `options.Target` is supplied to middleman
  # via the HBTARGET environment variable, or the default set in config.rb.
  if options.Targets.key?(options.Target)
    puts "\n#{A_BLUE}Using target `#{options.Target}`#{A_RESET}"
  elsif options.Target == :improbable_value
    options.Targets.keys.each {|key| puts "#{key}"}
    exit 0
  else
    puts "\n#{A_RED}`#{options.Target}` is not a valid target. Choose from one of:#{A_CYAN}"
    options.Targets.keys.each {|key| puts "\t#{key}"}
    puts "#{A_RED}Or use nothing for the default target.#{A_RESET}"
    exit 1
  end

end #initialize


#===============================================================
#  after_configuration
#    Callback occurs before before_build.
#    Here we will adapt the middleman config.rb settings to the
#    current target settings. This is also our only chance to
#    create files that will be processed (by time we get to
#    before_build, middleman already has its manifest).
#===============================================================
def after_configuration

  # Setup some instance variables
  path_content = File.join( app.source, 'Resources/', 'Base.lproj/' )


  # Set the correct :build_dir based on the options.
  app.set :build_dir, File.join(options.Help_Output_Location, "#{options.CFBundleName} (#{options.Target}).help", 'Contents')


  # Set the destinations for generated markdown partials and css.
  options.File_Markdown_Images = File.join(app.source, app.partials_dir, options.File_Markdown_Images)
  options.File_Markdown_Links  = File.join(app.source, app.partials_dir, options.File_Markdown_Links)
  options.File_Image_Width_Css = File.join(app.source, app.css_dir, options.File_Image_Width_Css)


  # make the title page
  src_file = File.join(path_content, options.File_Titlepage_Template)
  dst_file = File.join(path_content, "#{options.CFBundleName}.html.md.erb")
  FileUtils.cp(src_file, dst_file)


  # create all other necessary files
  process_plists
  build_mdimages
  build_mdlinks
  build_imagecss

end #def


#===============================================================
#  before_build
#    Callback occurs one time before the build starts.
#    We will perform all of the required pre-work.
#===============================================================
def before_build

end

#===============================================================
#  after_build
#    Callback occurs one time after the build.
#    We will perform all of the finishing touches.
#===============================================================
def after_build
    run_help_indexer
end


#===============================================================
#  Helpers
#    Methods defined in this helpers block are available in
#    templates.
#===============================================================

helpers do

  #--------------------------------------------------------
  # cfBundleIdentifier
  #   Returns the product `CFBundleIdentifier` for the
  #   current target
  #--------------------------------------------------------
  def cfBundleIdentifier
    options = extensions[:Helpbook].options
    options.Targets[options.Target][:CFBundleID]
  end


  #--------------------------------------------------------
  # cfBundleName
  #   Returns the product `CFBundleName` for the current
  #   target
  #--------------------------------------------------------
  def cfBundleName
    extensions[:Helpbook].options.CFBundleName
  end


  #--------------------------------------------------------
  # product_name
  #   Returns the ProductName for the current target
  #--------------------------------------------------------
  def product_name
    options = extensions[:Helpbook].options
    options.Targets[options.Target][:ProductName]
  end


  #--------------------------------------------------------
  # target_name
  #   Return the current build target.
  #--------------------------------------------------------
  def target_name
    extensions[:Helpbook].options.Target
  end


  #--------------------------------------------------------
  # target_name?
  #   Is the current target `proposal`?
  #--------------------------------------------------------
  def target_name?(proposal)
    extensions[:Helpbook].options.Target == proposal
  end


  #--------------------------------------------------------
  # target_feature?
  #   Does the target have the feature `feature`?
  #--------------------------------------------------------
  def target_feature?(feature)
    options = extensions[:Helpbook].options
    features = options.Targets[options.Target][:Features]
    features.key?(feature) && features[feature]
  end


  #--------------------------------------------------------
  #  page_name
  #    Make page_name available for each page. This is the
  #    file base name. Useful for assigning classes, etc.
  #--------------------------------------------------------
  def page_name
    File.basename( current_page.url, '.*' )
  end


  #--------------------------------------------------------
  #  page_group
  #    Make page_group available for each page. This is the
  #    source parent directory (not the request path).
  #    Useful for for assigning classes, and/or group
  #    conditionals.
  #--------------------------------------------------------
  def page_group
    File.basename(File.split(current_page.source_file)[0])
  end


  #--------------------------------------------------------
  #  current_group_pages
  #    Returns an array of all of the pages in the current
  #    group, i.e., pages in the same source subdirectory
  #    that are HTML files.
  #--------------------------------------------------------
  def current_group_pages
    sitemap.resources.find_all do |p|
      p.path.match(/\.html/) &&
      File.basename(File.split(p.source_file)[0]) == page_group
    end
  end


  #--------------------------------------------------------
  #  related_pages
  #    Returns an array of all of the pages related to the
  #    current page's group. See pages_related_to.
  #--------------------------------------------------------
   def related_pages
       pages_related_to( page_group )
   end


  #--------------------------------------------------------
  #  pages_related_to(group)
  #    Returns an array of all of the pages in the
  #    specified group, defined as:
  #      - that are HTML files
  #      - that are in the same group
  #      - are NOT the current page
  #      - is not the index page beginning with 00
  #      - does have an "order" key in the frontmatter
  #      - if frontmatter:target is used, the target or
  #        feature appears in the frontmatter
  #      - if frontmatter:exclude is used, that target or
  #        enabled feature does NOT appear in the
  #        frontmatter.
  #    Returned array will be:
  #      - sorted by the "order" key.
  #
  # Also adds a .metadata[:link] to the structure with a
  # relative path to groups that are not the current group.
  #--------------------------------------------------------
  def pages_related_to( group )
     pages = sitemap.resources.find_all do |p|
      p.path.match(/\.html/) &&
      File.basename(File.split(p.source_file)[0]) == group &&
      File.basename( p.url, '.*' ) != page_name &&
      !File.basename( p.url ).start_with?('00') &&
      p.data.key?('order') &&
      ( !p.data.key?('target') || (p.data['target'].include?(target_name) || p.data['target'].count{ |t| target_feature?(t) } > 0) ) &&
      ( !p.data.key?('exclude') || !(p.data['exclude'].include?(target_name) || p.data['exclude'].count{ |t| target_feature(t) } > 0) )
    end
    pages.each { |p| p.add_metadata(:link =>(group == page_group) ? File.basename(p.url) : File.join(group, File.basename(p.url) ) )}
    pages.sort_by { |p| p.data['order'].to_i }
  end

end #helpers


#===============================================================
#  Instance Methods
#===============================================================


  #--------------------------------------------------------
  #  build_mdimages
  #    Will build a markdown file with shortcuts to links
  #    for every image found in the project.
  #--------------------------------------------------------
  def build_mdimages

    return unless options.Build_Markdown_Images

    puts "#{A_CYAN}Helpbook is creating `#{options.File_Markdown_Images}`.#{A_RESET}"

    files_array = []
    out_array = []
    longest_shortcut = 0
    longest_path = 0

    Dir.glob("#{app.source}/Resources/**/*.{jpg,png,gif}").each do |fileName|

        # Remove all file extensions and make a shortcut
        base_name = fileName
        while File.extname(base_name) != '' do
            base_name = File.basename( base_name, '.*' )
        end
        next if base_name.start_with?('_')
        shortcut = "[#{base_name}]:"

        # Make a fake absolute path
        path = File::SEPARATOR + Pathname.new(fileName).relative_path_from(Pathname.new(app.source)).to_s

        files_array << { :shortcut => shortcut, :path => path }

        longest_shortcut = shortcut.length if shortcut.length > longest_shortcut
        longest_path = path.length if path.length > longest_path

    end

    files_array = files_array.sort_by { |key| [File.split(key[:path])[0], key[:path]] }
    files_array.uniq.each do |item|
        item[:shortcut] = "%-#{longest_shortcut}.#{longest_shortcut}s" % item[:shortcut]
        item[:path] = "%-#{longest_path}.#{longest_path}s" % item[:path]
        out_array << "#{item[:shortcut]}  #{item[:path]}   "
    end

    File.open(options.File_Markdown_Images, 'w') { |f| out_array.each { |line| f.puts(line) } }

  end #def


  #--------------------------------------------------------
  #  build_mdlinks
  #    Will build a markdown file with shortcuts to links
  #    for every HTML file found in the project.
  #--------------------------------------------------------
  def build_mdlinks
    return unless options.Build_Markdown_Links

    puts "#{A_CYAN}Helpbook is creating `#{options.File_Markdown_Links}`.#{A_RESET}"

    files_array = []
    out_array = []
    longest_shortcut = 0
    longest_path = 0

    Dir.glob("#{app.source}/Resources/**/*.erb").each do |fileName|

        # Remove all file extensions and make a shortcut
        base_name = fileName
        while File.extname(base_name) != '' do
            base_name = File.basename( base_name, '.*' )
        end
        next if base_name.start_with?('_')

        shortcut = "[#{base_name}]:"

        # Make a fake absolute path
        path = Pathname.new(fileName).relative_path_from(Pathname.new(app.source))
        path = File::SEPARATOR + File.join(File.dirname(path), base_name) + '.html'

        # Get the title, if any
        metadata = YAML.load_file(fileName)
        title = (metadata.is_a?(Hash) && metadata.key?('title')) ? metadata['title'] : ''

        files_array << { :shortcut => shortcut, :path => path, :title => title }

        longest_shortcut = shortcut.length if shortcut.length > longest_shortcut
        longest_path = path.length if path.length > longest_path

    end

    files_array = files_array.sort_by { |key| [File.split(key[:path])[0], key[:path]] }
    files_array.uniq.each do |item|
        item[:shortcut] = "%-#{longest_shortcut}.#{longest_shortcut}s" % item[:shortcut]

        if item[:title].length == 0
            out_array << "#{item[:shortcut]}  #{item[:path]}"
        else
            item[:path] = "%-#{longest_path}.#{longest_path}s" % item[:path]
            out_array << "#{item[:shortcut]}  #{item[:path]}  \"#{item[:title]}\""
        end
    end

    File.open(options.File_Markdown_Links, 'w') { |f| out_array.each { |line| f.puts(line) } }

  end #def


  #--------------------------------------------------------
  #  build_imagecss
  #    Builds a css file containing an max-width for every
  #    image in the project.
  #--------------------------------------------------------
  def build_imagecss
    return unless options.Build_Image_Width_Css

    puts "#{A_CYAN}Helpbook is creating `#{options.File_Image_Width_Css}`.#{A_RESET}"

    out_array = []

    Dir.glob("#{app.source}/Resources/**/*.{jpg,png,gif}").each do |fileName|
        # fileName contains complete path relative to this script.
        # Get just the name and extension.
        base_name = File.basename(fileName)

        # width
        if File.basename(base_name, '.*').end_with?('@2x')
          width = (FastImage.size(fileName)[0] / 2).to_i.to_s
        else
          width = FastImage.size(fileName)[0].to_s;
        end

        # proposed css
        out_array << "img[src$='#{base_name}'] { max-width: #{width}px; }"
    end

    File.open(options.File_Image_Width_Css, 'w') { |f| out_array.each { |line| f.puts(line) } }

  end #def


  #--------------------------------------------------------
  #  process_plists
  #    Performs substitutions in all _*.plist and
  #    _*.strings files in the project.
  #--------------------------------------------------------
  def process_plists

    Dir.glob("#{app.source}/**/_*.{plist,strings}").each do |fileName|

      puts "#{A_CYAN}Helpbook is processing plist file #{fileName}.#{A_RESET}"

        file = File.open(fileName)
        doc = Nokogiri.XML(file)
        file.close

        doc.traverse do |node|
          if node.text?
            node.content = node.content.gsub('{$CFBundleIdentifier}', options.Targets[options.Target][:CFBundleID])
            node.content = node.content.gsub('{$CFBundleName}', options.CFBundleName)
          end
        end

        dst_path = File.dirname(fileName)
        dst_file = File.basename(fileName)[1..-1]

        File.open(File.join(dst_path, dst_file),'w') {|f| doc.write_xml_to f}

    end
  end #def


  #--------------------------------------------------------
  #  run_help_indexer
  #--------------------------------------------------------
  def run_help_indexer

    # see whether a help indexer is available.
    `command -v hiutil > /dev/null`
    if $?.success?

      index_dir = File.expand_path(File.join(app.build_dir, 'Resources/', 'Base.lproj/' ))
      index_dst = File.expand_path(File.join(index_dir, "#{options.CFBundleName}.helpindex"))

      puts "#{A_CYAN}'#{index_dir}' #{A_BLUE}(indexing)#{A_RESET}"
      puts "#{A_CYAN}'#{index_dst}' #{A_BLUE}(final file)#{A_RESET}"

      `hiutil -Cf "#{index_dst}" "#{index_dir}"`
    else
      puts "#{A_RED}NOTE: `hituil` is not on path or not installed. No index will exist for target '#{options.Target}'.#{A_RESET}"
    end
  end #def


#===============================================================
#  ClassMethods
#===============================================================

module ClassMethods

end #module


end #class


::Middleman::Extensions.register(:Helpbook, Helpbook)
