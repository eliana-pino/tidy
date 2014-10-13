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
#    - (recommended) helpbook --build target-1 target-2 target-n
#    - (not recommended) HBTARGET=target middleman build
#    - (not recommended) HBTARGET=target bundle exec middleman build
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


##########################################################################
#  Command-Line Script
##########################################################################
if __FILE__ == $0


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
    STDOUT.puts "Using target `#{options.Target}`"
  else
    STDOUT.puts "`#{options.Target}` is not a valid target. Choose from one of:"
    options.Targets.each do |k,v|
      STDOUT.puts "  #{k}"
    end
    STDOUT.puts 'Or use nothing for the default target.'
    exit 1
  end

  @path_content = nil # string will be initialized in after_configuration.

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
  @path_content = File.join( app.source, "Resources/", "Base.lproj/" )


  # Set the correct :build_dir based on the options.
  app.set :build_dir, File.join(options.Help_Output_Location, "#{options.CFBundleName} (#{options.Target}).help", "Contents")


  # Set the destinations for generated markdown partials and css.
  options.File_Markdown_Images = File.join(app.source, app.partials_dir, options.File_Markdown_Images)
  options.File_Markdown_Links  = File.join(app.source, app.partials_dir, options.File_Markdown_Links)
  options.File_Image_Width_Css = File.join(app.source, app.css_dir, options.File_Image_Width_Css)


  # make the title page
  srcFile = File.join(@path_content, options.File_Titlepage_Template)
  dstFile = File.join(@path_content, "#{options.CFBundleName}.html.md.erb")
  FileUtils.cp(srcFile, dstFile)


  # create all other necessary files
  process_plists
  build_mdimages
  build_mdlinks
  build_imagecss

end #def


#===============================================================
#  before_build
#    Callback occurs one time before the build starts.
#    We will peform all of the required pre-work.
#===============================================================
def before_build

end

#===============================================================
#  after_build
#    Callback occurs one time after the build.
#    We will peform all of the finishing touches.
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
  # target_name
  #   Return the current build target.
  #--------------------------------------------------------
  def target_name
    extensions[:Helpbook].options.Target
  end


  #--------------------------------------------------------
  # target_name?
  #   Return the current build target.
  #--------------------------------------------------------
  def target_name?(proposal)
    options = extensions[:Helpbook].options.Target == proposal
  end


  #--------------------------------------------------------
  # target_feature?
  #   Does the target have the feature `feature`?
  #--------------------------------------------------------
  def target_feature?(feature)
    options = extensions[:Helpbook].options
    features = options.Targets[options.Target][:Features]
    result = features.key?(feature) && features[feature]
  end


  #--------------------------------------------------------
  # product_name
  #   Returns the product name for the current target
  #--------------------------------------------------------
  def product_name
    options = extensions[:Helpbook].options
    options.Targets[options.Target][:ProductName]
  end


  #--------------------------------------------------------
  # cfBundleName
  #   Returns the product CFBundleName for the current
  #   target
  #--------------------------------------------------------
  def cfBundleName
    extensions[:Helpbook].options.CFBundleName
  end


  #--------------------------------------------------------
  # cfBundleIdentifier
  #   Returns the product CFBundleIdentifier for the
  #   current target
  #--------------------------------------------------------
  def cfBundleIdentifier
    options = extensions[:Helpbook].options
    options.Targets[options.Target][:CFBundleID]
  end


  #--------------------------------------------------------
  # boolENV
  #   Treat an environment variable with the value 'yes' or
  #   'no' as a bool. Undefined ENV are no, and anything
  #   that's not 'yes' is no.
  #--------------------------------------------------------
  def boolENV(envVar)
     (ENV.key?(envVar)) && !((ENV[envVar].downcase == 'no') || (ENV[envVar].downcase == 'false'))
  end


  #--------------------------------------------------------
  #  page_name
  #    Make page_name available for each page. This is the
  #    file base name. Useful for assigning classes, etc.
  #--------------------------------------------------------
  def page_name
    File.basename( current_page.url, ".*" )
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
  #      - do have an "order" key in the frontmatter
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
      File.basename( p.url, ".*" ) != page_name &&
      !File.basename( p.url ).start_with?("00") &&
      p.data.key?("order") &&
      ( !p.data.key?("target") || (p.data["target"].include?(target_name) || p.data["target"].count{ |t| target_feature?(t) } > 0) ) &&
      ( !p.data.key?("exclude") || !(p.data["exclude"].include?(target_name) || p.data["exclude"].count{ |t| target_feature(t) } > 0) )
    end
    pages.each { |p| p.add_metadata(:link =>(group == page_group) ? File.basename(p.url) : File.join(group, File.basename(p.url) ) )}
    pages.sort_by { |p| p.data["order"].to_i }
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

    STDOUT.puts "Helpbook is creating `#{options.File_Markdown_Images}`."

    files_array = []
    out_array = []
    longest_shortcut = 0
    longest_path = 0

    Dir.glob("#{app.source}/Resources/**/*.{jpg,png,gif}").each do |fileName|

        # Remove all file extensions and make a shortcut
        base_name = fileName
        while File.extname(base_name) != "" do
            base_name = File.basename( base_name, ".*" )
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

    STDOUT.puts "Helpbook is creating `#{options.File_Markdown_Links}`."

    files_array = []
    out_array = []
    longest_shortcut = 0
    longest_path = 0

    Dir.glob("#{app.source}/Resources/**/*.erb").each do |fileName|

        # Remove all file extensions and make a shortcut
        base_name = fileName
        while File.extname(base_name) != "" do
            base_name = File.basename( base_name, ".*" )
        end
        next if base_name.start_with?('_')

        shortcut = "[#{base_name}]:"

        # Make a fake absolute path
        path = Pathname.new(fileName).relative_path_from(Pathname.new(app.source))
        path = File::SEPARATOR + File.join(File.dirname(path), base_name) + ".html"

        # Get the title, if any
        metadata = YAML.load_file(fileName)
        title = (metadata.is_a?(Hash) && metadata.key?("title")) ? metadata["title"] : ""

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

    STDOUT.puts "Helpbook is creating `#{options.File_Image_Width_Css}`."

    out_array = []

    Dir.glob("#{app.source}/Resources/**/*.{jpg,png,gif}").each do |fileName|
        # fileName contains complete path relative to this script.
        # Get just the name and extension.
        base_name = File.basename(fileName)

        # width
        if File.basename(base_name, '.*').end_with?("@2x")
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

      STDOUT.puts "Helpbook is processing plist file #{fileName}."

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

      indexDir = File.expand_path(File.join(app.build_dir, "Resources/", "Base.lproj/" ))
      indexDst = File.expand_path(File.join(indexDir, "#{options.CFBundleName}.helpindex"))

      STDOUT.puts "'#{indexDir}' (indexing)"
      STDOUT.puts "'#{indexDst}' (final file)"

      `hiutil -Cf "#{indexDst}" "#{indexDir}"`
    else
      STDOUT.puts "NOTE: `hituil` is not on path or not installed. No index will exist for target '#{options.Target}'."
    end
  end #def


#===============================================================
#  ClassMethods
#===============================================================

module ClassMethods

end #module


end #class


::Middleman::Extensions.register(:Helpbook, Helpbook)
