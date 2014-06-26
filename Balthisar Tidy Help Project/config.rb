###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

# Build Configurations
#config :development do
#  compass_config do |config|
#    config.sass_options = {:debug_info => true}
#  end
#end



###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

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


set :source, 'Contents (source)'

set :build_dir, 'Contents (build)'

set :css_dir, 'Resources/Base.lproj/css'

set :js_dir, 'Resources/Base.lproj/javascript'

set :images_dir, 'Resources/Base.lproj/images'

set :partials_dir, 'partials'

set :layouts_dir, 'layouts'

set :data_dir, 'Contents (source)/data'

ignore 'data/*'

set :relative_links, true


# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
