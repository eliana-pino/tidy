################################################################################
#  helpbook.rb
#    Consists of the Helpbook class which performs additional functions for
#    generating Apple Helpbooks with Middleman.
#
#    - Build automatic CSS max-width for all images.
#    - Build a partial containing markdown links to all html file.
#    - Build a partial containing markdown links to all images.
#    - Process *.plist files with data for building a helpbook.
#    - Provides helpers for determining build targets.
#    - Provides functions for simplifying dealing with the sitemap.
################################################################################

require 'fastimage'
require 'fileutils'
require 'nokogiri'
require 'pathname'
require 'yaml'


class Helpbook < Middleman::Extension


#===============================================================
#  Configuration options
#===============================================================

option :CFBundleName, nil, 'The CFBundleName key; will be used in a lot of places.'
option :HelpOutputLocation, nil, 'Directory to place the built helpbook.'
option :Targets, nil, 'A data structure that defines many characteristics of the target.'
option :build_markdown_links, true, 'Whether or not to generate `_markdown-links.erb`'
option :build_markdown_images, true, 'Whether or not to generate `_markdown-images.erb`'
option :build_image_width_css, true, 'Whether or not to generate `_image_widths.scss`'
option :build_ignore_at2x_images, true, 'Whether or not to ignore @2x images.'

#===============================================================
#  initializer
#===============================================================
def initialize(app, options_hash={}, &block)
  super

  #--------------------------------------------------------
  #  callback occurs just before before_build.
  #--------------------------------------------------------
  app.ready do |builder|
    #STDOUT.puts "READY occurs before before_build."
  end


  #--------------------------------------------------------
  #  callback occurs one time before the build starts.
  #--------------------------------------------------------
  app.before_build do |builder|
    #STDOUT.puts "BEFORE_BUILD"
  end


  #--------------------------------------------------------
  #  callback occurs before every page.
  #--------------------------------------------------------
  app.before do
    #puts "APPEARS FOR EVERY PAGE"
    true
  end


  #--------------------------------------------------------
  #  callback occurs after Middleman is done building.
  #--------------------------------------------------------
  app.after_build do |builder|
    #STDOUT.puts "ONLY APPEARS ONCE AT END"
  end

end #initialize


#===============================================================
#  callback occurs before before_build.
#===============================================================
def after_configuration
  #STDOUT.puts "AFTER_CONFIGURATION THIS SHOULD ONLY APPEAR ONCE AT START."
end


#===============================================================
#  Helpers
#    Methods defined in this helpers block are available in
#    templates.
#===============================================================

helpers do

  #--------------------------------------------------------
  # boolENV
  #   Treat an environment variable with the value 'yes' or
  #   'no' as a bool. Undefined ENV are no, and anything
  #   that's not 'yes' is no.
  #--------------------------------------------------------
  def boolENV(envVar)
     (ENV.key?(envVar)) && !(ENV[envVar].downcase == 'no')
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
      ( !p.data.key?("target") || (p.data["target"].include?(ENV["HelpBookTarget"]) || p.data["target"].count{ |t| boolENV(t) } > 0) ) &&
      ( !p.data.key?("exclude") || !(p.data["exclude"].include?(ENV["HelpBookTarget"]) || p.data["exclude"].count{ |t| boolENV(t) } > 0) )
    end
    pages.each { |p| p.add_metadata(:link =>(group == page_group) ? File.basename(p.url) : File.join(group, File.basename(p.url) ) )}
    pages.sort_by { |p| p.data["order"].to_i }
  end

end #helpers


#===============================================================
#  ClassMethods
#===============================================================


module ClassMethods


  #--------------------------------------------------------
  #  say_hello
  #--------------------------------------------------------
  def say_hello
    puts "Hello"
  end #def


end #module


end #class


::Middleman::Extensions.register(:Helpbook, Helpbook)
