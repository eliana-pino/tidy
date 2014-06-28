README
======

About the Build System for Help
-------------------------------
This directory is the help project for _Balthisar Tidy_ series of applications.
Because of the differing build and feature configurations for _Balthisar Tidy_,
a more flexible build system for its help files is necessary, too.

If you're working on your own forks of _Balthisar Tidy_ and don’t wish to
depend on an external build system for help file, you can still modify the
built help files in the `Balthisar Tidy.help` bundle. On the other hand if you
wish to participate in the development of _Balthisar Tidy_ and issue pull
requests, please make changes to the source files in the build system in this
directory, in `source`.

The build system is [middleman](http://middlemanapp.com/) and is a well-known
static website development tool that's available for all platforms that can
run Ruby. The templating system depends on very basic Ruby knowledge, but the
learning curve is quite small.

The `.idea` folder is included in version control so that I can replicate my
editor development across machines. If you are using a JetBrains IDE to open
the project folder, then your editor will inherit my settings. Please make
sure that your pull requests do not include anything from this file (please
.gitignore it on your system).


Build Configurations
--------------------
In order to tailor the help file to each specific version of Balthisar Tidy
the there are multiple build configurations for Tidy help, too. This avoids,
for example, any mention of the Sparkle Update Framework for versions that
appear in the App Store.

It's important to use the included `build_help` script when getting ready
for deployment, as it will ensure that `.plists` and `.strings` are properly
set and will create the correct folder hierarchy.

Execute `build_help` without any parameters to see the currently supported
builds.


Editing the Title Page / Landing Page
-------------------------------------
Note that the standard Apple Help Book “title page” content should only be
edited in `_title_page.erb`, and if you want to set the page title, you
should modify `layouts/layout-title_page.erb`. Apple Help requires that the
main title page be and XHTML file, while the remaining files are HTML 4.0.1
(this the purpose of having two layout files).

Additionally, by modifying only `_title_page.erb`, the build system can
properly manage the name of the file for the title page (it just makes a
duplicate of `_title_page.html.erb`, which includes `_title_page.erb` as a
partial. This allows you to execute `middleman build` during development
without having to run the whole of `build_help` all the time.

Dependencies
------------
Middleman itself should work without any external dependencies, i.e., after
installing the Ruby Gem, everything should "just work." However the build
script uses Nokogiri to manipulate the plists in order to allow the script
to run on non-Mac platforms where PlistBuddy is not available. A simple
`(sudo) gem install nokogiri` should work on any platform.
