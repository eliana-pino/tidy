README
======

About the Build System for Help
-------------------------------
This directory is the help project for _Balthisar Tidy_ series of applications.
Because of the differing build and feature configurations for _Balthisar Tidy_,
a more flexible build system for its help files is necessary, too.

If you're working on your own forks of _Balthisar Tidy_ and don’t wish to
depend on an external build system for help file, you can still modify the
built help files in the `Balthisar Tidy (xxx).help` bundles. On the other hand
if you wish to participate in the development of _Balthisar Tidy_ and issue pull
requests, please make changes to the source files in the build system in this
directory, in `Contents/`.

The build system is [middleman](http://middlemanapp.com/) and is a well-known
static website development tool that's available for all platforms that can
run Ruby. The template system depends on very basic Ruby knowledge, but the
learning curve is quite small. If you can develop Objective-C, then you can
very easily understand the small amount of Ruby that's used.

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
appear in the App Store, and avoids mention of features in the help files of
applications that don't have those features.

`middleman build` will build the “pro” target by default. Because middleman
won't accept CLI parameters, we have to pass targets to it in an environment
variable, e.g.,

`HBTARGET=pro middleman build`

Current valid targets are

 - app
   : the App Store version of _Balthisar Tidy_
 - pro
   : Balthisar Tidy for Work_
 - test
   : Enables every feature in the help file.
 - web
   : _Balthisar Tidy_ as distributed from balthisar.com
   
A better alternative is to use the `helpbook` tool, which is cleverly hidden
in the `helpbook` extension that Middleman uses to build HelpBooks. You can
invoke it like this:

`helpbook TARGET... | all  [--verbose | -v] [--quiet | -q]`

For example:

`helpbook web pro --verbose` to build these two targets and show Middleman's
verbose output.



Editing the Title Page / Landing Page
-------------------------------------
Note that the standard Apple Help Book “title page” content should only be
edited in `_title_page.md.erb`, and if you want to set the page title, you
should modify `layouts/layout-apple_main.erb`. Apple Help requires that the
main title page be an XHTML file, while the remaining files are HTML 4.0.1
(this the purpose of having two layout files).

Additionally, by modifying only `_title_page.html.md.erb`, the build system can
properly manage the name of the file for the title page (it just makes a
duplicate of `_title_page.html.md.erb`).


Editing the InfoPlist.strings file
----------------------------------
The build system will generate a proper `InfoPlist.strings` file using the
configured data, so don't modify this file. Instead modify its template file
`_InfoPlist.strings` whenever you want to ensure that some new item is
included. If you're contributing to _Balthisar Tidy_ there should be no need
for this.


Build System Configuration
--------------------------
All configuration is performed in `config.rb`, although if you're contributing
to _Balthisar Tidy_ there should be no need for any changes here.


Dependencies
------------
Executing `bundle install` from the project directory should take care of any
dependencies.


Frontmatter Content
-------------------

Frontmatter in yaml format has the following meanings:

~~~~~~~~~~~~
---
title:  Page title
blurb:  A sentence or short paragraph that will be included in TOC's.
layout: Layout file to use.
order:  local sort order (if missing, won't be included in auto TOC's).
targets:
 - array of
 - targets, or
 - features that are true
exclude:
 - array
 - same as above, but will exclude items that equal yes.
 - exclude overrides targets. If something included then excluded, will be excluded.
---
~~~~~~~~~~~~


Examples of the targets array:

targets:
 - pro (equals web)
 - feature_sparkle (equals yes)
 - feature_exports_config (equals no)

This item will be included because all feature_sparkle is allowed.

targets:
 - pro (equals web)
 - features_sparkle (equals no)
 - feature_exports_config (equals no)

None of these is valid, so the item will be excluded.

exclude:
 - pro (equals web)
 - features_sparkle (equals no)

Nothing will be excluded, because we are currently web, and features_sparkle is not yes.
