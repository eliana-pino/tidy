################################################################################
#  config.rb
#    Configure Middleman to generate Apple Helpbook containers for multiple
#    targets.
################################################################################

# 'helpbook.rb' contains the Helpbook class that will do additional lifting.
require "helpbook"


################################################################
# Configuration. Change the option values to suit your needs.
################################################################

activate :Helpbook do |options|

  # You should only change the default, fall-back target here. This is the
  # target that will be processed if no ENVironment variable is used.
  options.target = ENV['HBTARGET'] || 'pro'

  # This value will be used for correct .plists and .strings setup, and will
  # will determine finally .help directory name. All targets will use the
  # same CFBundleName.
  options.CFBundleName = 'Balthisar Tidy'

  # Directory where finished .help build should go. It should be relative
  # to this file, or make null to leave in this help project directory. The
  # *actual* output directory will be an Apple Help bundle at this location.
  options.HelpOutputLocation = "../Balthisar Tidy/Resources/"

  # :CFBundleID
  # Different versions of your app must have different bundle identifiers
  # so that the correct version of your help files stays related to your app.
  # This is *not* the CFBundleID of the application. However your application's
  # Info.plist `CFBundleHelpBookName` must match the value you specify.

  # :ProductName
  # You can specify different product names for each build target. The product
  # name for the current target will be available via the product_name helper.

  # :Features
  # A hash of features that a particular target supports or doesn't support.
  # The has_feature function and several helpers will use the true/false value
  # of these features in order to conditionally include content. This is given
  # as a hash of true/false instead of an array of symbols in order to make it
  # easier to enable/disable features for each target.

  # Define your targets here.
  options.Targets =
  {
    'web' =>
    {
      :CFBundleID  => 'com.balthisar.web.free.balthisar-tidy.help',
      :ProductName => 'Balthisar Tidy',
      :Features =>
      {
        :feature_advertise_pro        => true,
        :feature_sparkle              => true,
        :feature_exports_config       => false,
        :feature_supports_applescript => false,
        :feature_supports_diffs       => false, # eventually.
        :feature_supports_preview     => false, # eventually.
        :feature_supports_extensions  => false,
        :feature_supports_service     => false,
        :feature_supports_SxS_diffs   => false,
        :feature_supports_validation  => false,
      }
    },

    'app' =>
    {
      :CFBundleID  => 'com.balthisar.Balthisar-Tidy.help',
      :ProductName => 'Balthisar Tidy',
      :Features =>
      {
        :feature_advertise_pro        => true,
        :feature_sparkle              => false,
        :feature_exports_config       => false,
        :feature_supports_applescript => false,
        :feature_supports_diffs       => false, # eventually.
        :feature_supports_preview     => false, # eventually.
        :feature_supports_extensions  => false,
        :feature_supports_service     => false,
        :feature_supports_SxS_diffs   => false,
        :feature_supports_validation  => false,
      }
    },

    'pro' =>
    {
      :CFBundleID  => 'com.balthisar.Balthisar-Tidy.pro.help',
      :ProductName => 'Balthisar Tidy for Work',
      :Features =>
      {
        :feature_advertise_pro        => false,
        :feature_sparkle              => false,
        :feature_exports_config       => true,
        :feature_supports_applescript => true,
        :feature_supports_diffs       => false, # eventually.
        :feature_supports_preview     => false, # eventually.
        :feature_supports_extensions  => false, # eventually.
        :feature_supports_service     => false, # eventually.
        :feature_supports_SxS_diffs   => false, # eventually.
        :feature_supports_validation  => false, # eventually.
      }
    },

    'test' =>
    {
      :CFBundleID  => 'com.balthisar.Balthisar-Tidy.test.help',
      :ProductName => 'Balthisar Tidy Test',
      :Features =>
      {
        :feature_advertise_pro        => true,
        :feature_sparkle              => true,
        :feature_exports_config       => true,
        :feature_supports_applescript => true,
        :feature_supports_diffs       => true,
        :feature_supports_preview     => true,
        :feature_supports_extensions  => true,
        :feature_supports_service     => true,
        :feature_supports_SxS_diffs   => true,
        :feature_supports_validation  => true,
      }
    },

  }

  # Build #{:partials_dir}/_markdown-links.erb file? This enables easy-to-use
  # markdown links in all markdown files, and is kept up to date.
  options.build_markdown_links = true

  # Build #{:partials_dir}/_markdown-images.erb file? This enables easy-to-use
  # markdown links to images in all markdown files, and is kept up to date.
  options.build_markdown_images = true

  # Build #{:css_dir}/_image_widths.scss? This will enable a max-width of
  # all images the reflect the image size. Images that are @2x will use
  # proper retina image width.
  options.build_image_width_css = true

end #activate


################################################################################
# STOP! There's nothing below here that you should have to
# change. Just follow the conventions and framework provided.
################################################################################


#===============================================================
# Setup directories to mirror Help Book directory layout.
#===============================================================
set :source,       'Contents'
set :build_dir,    'Contents (build)'   # Will be overriden by Helpbook.

set :css_dir,      'Resources/Base.lproj/css'
set :js_dir,       'Resources/Base.lproj/javascript'
set :images_dir,   'Resources/Base.lproj/images'

set :partials_dir, 'partials'
set :layouts_dir,  'layouts'
set :data_dir,     'Contents (source)/data'


#===============================================================
# Ignore items we don't want copied to the destination
#===============================================================
ignore 'data/*'


#===============================================================
# All of our links and assets must be relative to the file
# location, and never absolute. However we will *use* absolute
# paths with root being the source directory; they will be
# converted to relative paths at build.
#===============================================================
set :relative_links, true
activate :relative_assets


#===============================================================
# Default to Apple-recommended HTML 4.01 layout.
#===============================================================
page "Resources/Base.lproj/*", :layout => :'layout-html4'


#===============================================================
# Add-on features
#===============================================================
activate :syntax


################################################################################
# Helpers
################################################################################


#===============================================================
# Methods defined in this helpers block are available in
# templates.
#===============================================================
helpers do

  # no helpers here, but the Helpbook class offers quite a few.

end #helpers


################################################################################
# Build-specific configurations
################################################################################


#===============================================================
# :development - the server is running and watching files.
#===============================================================
configure :development do

  # Reload the browser automatically whenever files change
  activate :livereload, :host => "127.0.0.1"

  compass_config do |config|
    config.output_style = :expanded
    config.sass_options = { :line_comments => true }
  end

end #configure


#===============================================================
# :build - build is executed specifically.
#===============================================================
configure :build do

  # Compass
  compass_config do |config|
    config.output_style = :expanded
    config.sass_options = { :line_comments => false }
  end

  # Minify js
  activate :minify_javascript

end #configure
