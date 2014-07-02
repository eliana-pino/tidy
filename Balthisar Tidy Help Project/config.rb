###
# Setup directories to mirror Help Book directory layout.
###
set :source,       'Contents (source)'
set :build_dir,    'Contents (build)'

set :css_dir,      'Resources/Base.lproj/css'
set :js_dir,       'Resources/Base.lproj/javascript'
set :images_dir,   'Resources/Base.lproj/images'

set :partials_dir, 'partials'
set :layouts_dir,  'layouts'
set :data_dir,     'Contents (source)/data'


###
# Ignore items we don't want copied to the destination
###
ignore 'data/*'


###
# All of our links and assets must be relative
# to the file location, and never absolute.
###
set :relative_links, true
activate :relative_assets

###
# Everything in will default to Apple-recommended HTML 4.01 layout.
###
page "Resources/Base.lproj/*", :layout => :'layout-html4'


###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
helpers do

   # make page_name available for each page
   # this is the file name - useful for assigning classes, etc.
   def page_name
     File.basename( current_page.url, ".*" )
   end

   # make page+group available for each page.
   # this is the source containing directory (not the request path)
   # useful for for assigning classes, and/or group conditionals.
   def page_group
     File.basename(File.split(current_page.source_file)[0])
   end

   # returns an array of all of the pages in the current group, i.e.,
   # pages in the same source subdirectory that are HTML files.
   def current_group_pages
     sitemap.resources.find_all do |p|
       p.path.match(/\.html/) &&
       File.basename(File.split(p.source_file)[0]) == page_group
     end
   end

   # treat an environment variable as a bool
   def boolENV(envVar)
      (ENV.key?(envVar)) && !(ENV[envVar] == 'no')
   end

    # returns an array of all of the pages in the current group:
    def related_pages
        pages_related_to( page_group )
    end

    # returns an array of all of the pages in the specified group:
    #  - that are HTML files
    #  - that are in the same group
    #  - are NOT the current page
    #  - is not the index page beginning with 000
    #  - have an "order" key in the frontmatter
    #  - sorted by the "order" key.
    #  - if frontmatter:target is used, the target or feature appears in the frontmatter
    #  - if frontmatter:exclude is used, that target or enabled feature does NOT appear in the frontmatter.
    # also adds .metadata[:link] to the structure with a relative path to groups
    # that are not the current group.
    def pages_related_to( group )
        pages = sitemap.resources.find_all do |p|
        p.path.match(/\.html/) &&
        File.basename(File.split(p.source_file)[0]) == group &&
        File.basename( p.url, ".*" ) != page_name &&
        !File.basename( p.url ).start_with?("000") &&
        p.data.key?("order") &&
        ( !p.data.key?("target") || (p.data["target"].include?(ENV["HelpBookTarget"]) || p.data["target"].count{ |t| boolENV(t) } > 0) ) &&
        ( !p.data.key?("exclude") || !(p.data["exclude"].include?(ENV["HelpBookTarget"]) || p.data["exclude"].count{ |t| boolENV(t) } > 0) )
    end
    pages.each { |p| p.add_metadata(:link =>(group == page_group) ? File.basename(p.url) : File.join(group, File.basename(p.url) ) )}
    pages.sort_by { |p| p.data["order"].to_i }
    end
end


###
# Build-specific configurations
# - development: whenever the server is running and watching files.
# - build: when build is executed specifically.
###


configure :development do

  # Reload the browser automatically whenever files change
  activate :livereload, :host => "127.0.0.1"

  compass_config do |config|
    config.output_style = :expanded
    config.sass_options = { :line_comments => true }
  end

end

configure :build do

  # Compass
  compass_config do |config|
    config.output_style = :expanded
    config.sass_options = { :line_comments => false }
  end

  # Minify js
  activate :minify_javascript

end
