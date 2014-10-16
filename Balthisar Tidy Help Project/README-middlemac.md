Middlemac, the Middleman Build System for Mac OS X Help Projects (README)
=========================================================================

_Middlemac_ is the specialized Apple HelpBook building system that uses the
tools of _Middleman_ to make building Apple HelpBooks for your Mac OS X
applications a snap. Whether you are targeting multiple versions of your
application or a single version, once properly (simply!) configured,
_Middlemac_ will take all of the pain out of building Help files.

_Middlemac_ makes it simple to do this in Terminal…

`./helpbook target1 target2 target3`

…and end up with versions of your HelpBooks with all of the Apple-required files
in the Apple-required formats in the correct locations of your XCode build
directory. Simply build your help target, run your application, and find that
it just works!

_Middlemac_ offers:

- Build your help files in HTML, HAML, ERB, or (best bet!) Markdown. Or a
  combination of all of these.
- Single or multiple build targets.
- Multiple features support.
- A single help document code-set that discriminates based on target or feature.
- A low learning curve if you’re a developer.
- A set of conventions and tools that make automatic tables of contents,
  automatic sections, and automatic behavior effortless to implement.
- A basic, Apple-like CSS stylesheet that can be used as-is or easily tweaked
  to suit your needs.


_Middlemac_ uses tools you may already know, or may not know: 

- _Middleman_ is a static HTML site generator, and is the heart of _Middlemac_’s
  abilities, as well as an inspiration for the name.
- Ruby is language that _Middlemac_, _Middlemac_, and much of the others tools
  are written with. _You do not have to learn Ruby to take advantage of
  *Middlemac*_.
- helpbook.rb is the extension to _Middleman_ that makes it effortlessly build
  Apple HelpBooks. It’s also the command-line tool that makes it easier to work
  with Middleman.
- HTML is the markup language that Apple requires for HelpBooks. But _Middlemac_
  promises to make things easy for you, and so…
- Markdown is the text-based, human-readable, easy to use format that will
  make writing your documentation a real pleasure. This file is written using
  Markup.


Middlemac workflow
------------------

The _Middlemac_ workflow is what makes it easy to build Apple HelpBooks compared
to traditional methods.

# Setup your help project

All of the setup required takes place in a single section of a single Ruby
script. Don’t worry! You don’t have to know Ruby. If you’re a software developer
already it will be painless for you to configure _Middlemac_ to your
applications’ exact specifications.

You will find that most of _Middlemac_’s ease-of-use comes from the conventions
you will follow.

# Develop your help content

Following _Middlemac_’s conventions will make sections, tables of contents, and
navigation effortless to implement. Simply put some types of files where
_Middlemac_ expects to find them, and the build system will take care of the
rest. All you have to do is write some HTML, or better yet, Markdown.

# Build your HelpBook

From your help project directory, a single Terminal command can build one, more
or all of your targets, with as much or little on-screen feedback as you want.
In a matter of seconds to minutes (based on your project size), _Middlemac_ will
build your targets anywhere you’ve setup. If you target your application’s
XCode project directory (and have already configured XCode to use your `.help`
bundle, then all that’s left is to…

# Build your application

And then run it. And start your help. It’s that easy.


Getting Started
---------------


Groups
------

- A GROUP is a bunch of files in a directory at a single level.
- A GROUP landing-page should begin with 000_
- Using the table_contents partial will include a TOC for all files at this
  group level except for 000_ files.
- Can include another group's toc by specifying a :group in locals, where the
  GROUP is really just the directory name.
- WANT to include a gather_toc, which looks in the top level of all of the
  directories at the current level to look for 000_ files. Build a list with
  blurbs. 
  

  
Applicable Frontmatter Keys
---------------------------

You can add your own, but Middlemac will use these:

- title
- blurb
- layout
- order
- xhtml

Frontmatter must use HTML; cannot use MD.


Helpful Helpers
---------------
cfBundleIdentifier
cfBundleName
product_name
product_uri
target_name
target_name?
target_feature?
page_name
page_group
current_group_pages
related_pages
pages_related_to
legitimate_children

Helpful Partials
----------------
legitimate_children
table_contents
markdown_images
markdown_links


CSS
---
normalize
github
image_widths
apple_helpbook
style


Link to your site
-----------------
middlemac.webloc (works on Linux?)
Why not document root?

Conventions
-----------
Directory Layout


Getting Started
---------------




Introduction

    Tutorial
        install middleman
        install middlemac
        update gems
        view the sample site
        Middlemac workflow
        
    Middleman Basics
    
    Conventions
        Directory Layout
        Index files 000-
        Images
        CSS
    
    Examples
        Layout samples
        tables
        lists
        
    Reference
        Frontmatter keys
        CSS Classes
        Excluding and Including
        Build Targets
    
    
Customize
    Page titles




About Layouts
=============

This directory contains layouts and templates for your Apple HelpBook
project. Adhering to the following conventions will make things very
easy for you.

Files
-----

None of these files become standalone HTML documents, and as such should have
a single `.erb` or `.haml` extension.

For organization, the convention is to name HTML containers with a `layout`
prefix and visual templates with a `template` prefix.

 - `layout-html4.haml` - This is just an HTML 4.01 wrapper template and if you
   follow all of the conventions there's nothing you should have to change
   here.

 - `layout-xhtml.haml` - Apple's help landing page (the main page) is
   supposed to be an XHTML 1.0 Strict document. If you follow all of the
   conventions there's nothing you should have to change here.

 - `template-logo-large.haml` - This visual template is suitable for “main”-like
   pages. If you follow conventions you should not have to change anything here.

 - `template-logo-medium.erb`  and `template-logo-small.erb` are other
    additional visual templates. If you follow the image conventions there is
    no reason you should have to modify these templates.


“Absolute” Paths
----------------

When using Middleman's helpers, absolute paths will be converted to relative
paths during the build. Absolute paths are relative to the `Contents (source)`
directory and _not_ the filesystem root.

In general it’s _not_ recommended to use absolute paths unless you need assets
outside of Middleman's configuration. Middleman will automatically build the
correct path using only the asset name when you use its helpers, if the assets
are in the correct directories (e.g., images in `images`).

However you will use absolute paths to refer to items in the `shared` directory
since this it outside of Middleman's normal search scope. The view templates
use this approach, for example.
