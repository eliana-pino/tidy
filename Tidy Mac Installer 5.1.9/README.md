HTACG HTML Tidy Installer for Mac OS X
======================================

About
-----

This directory contains the project files that are required to build the installer package
for HTACG **HTML Tidy**. Although CMAKE is capable of generating DMG installer packages,
Mac users have higher expectations of installers than the rudimentary installer provided
by CMAKE.


Requirements
------------

The project requires two pieces of freely available software in order to build:

- [Packages][1] by Stéphane Sudre (free of charge), for the `HTML Tidy.pkgproj` file.
- [DMG Architect][2] by Spoonjuice LLC (free of charge), for the `DMG Project.dmgpkg` file.

 [1]: http://s.sudre.free.fr/Software/Packages/about.html
 [2]: https://itunes.apple.com/us/app/dmg-architect-disk-builder/id426104753?mt=12
 

Prerequisites
-------------

Of course you have to have used CMAKE to build tidy, its libraries, and its documentation.

~~~
cd tidy-html5-xxx/build/cmake/
cmake ../..
make
cmake ../.. -DBUILD_DOCUMENTATION=YES
make

~~~


Version Changes
---------------

Versions management is not currently automated, therefore we've tried to minimize the
number of references to the version number. Here is where you should update the version
number.

### Packages

- **Project** > **Presentation** (tab) > **Title** (popup menu)
- **Packages** > **HTML Tidy** > **Scripts** > **Installer-Post.sh** > V_ORIG, V_MAJOR, V_GEN


Package Signing
---------------

We should strive to deliver signed installer packages in order to maintain user trust.
Mac OS X GateKeeper policies will, by default, prevent installation of unsigned packages.
Although there are workarounds for this, it’s very unfriendly for unsophisticated users
who may give up and decide not to install.

A valid Apple Developer ID certificate is required to sign packages.

### Sign a package:

~~~
/usr/bin/productsign --sign "Developer ID Installer: FirstName LastName" unsigned_package.pkg new_package.pkg
~~~

### Verify signatures

Signing information can be verified with either of the following two terminal commands:

~~~
pkgutil --check-signature new_package.pkg
~~~

Or

~~~
spctl -a -v --type install new_package.pkg
~~~
