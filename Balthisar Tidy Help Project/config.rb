###
# Setup directories to mirror Help Book directory layout.
###
set :source,       'Contents (source)'
set :build_dir,    'Contents (build)'

set :css_dir,      'Resources/Base.lproj/css'
set :js_dir,       'Resources/Base.lproj/javascript'
set :images_dir,   'Resources/Base.lproj/images'

#set :partials_dir, 'partials'
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
# Everything in pages will use Apple-recommended HTML 4.01 layout.
###
page "Resources/Base.lproj/pages/*", :layout => :'layout-html4'


###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end


# Sets the page_class variable to the name of the current page.
# Layouts can then use, e.g., <body class="<%= page_classes %>">
def page_classes
  path = request.path_info.dup
  path << settings.index_file if path.match(%r{/$})
  path = path.gsub(%r{^/}, '')

  classes = []
  parts = path.split('.')[0].split('/')
  parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }

  classes.join(' ')
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
