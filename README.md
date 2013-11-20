Balthisar Tidy and JSDTidyDocument
==================================
(a Cocoa adaptation of TidyLib)
-------------------------------

_©2003-2013 by James S. Derry and balthisar.com_

_Portions Copyright ©1998-2003 World Wide Web Consortium (Massachusetts Institute of Technology, Institut National de Recherche en Informatique et en Automatique, Keio University). All Rights Reserved._

Welcome
-------

Welcome to _Balthisar Tidy_ and `JSDTidyDocument`. You’ve successfully uncovered the source code, so good luck using it. At this point you should be aware that is an almalgamation of two separate projects with very different groups working on them. `TidyLib`, in the `tidylib-src` group is a product of the fine people at <http://tidy.sourceforge.net>, and they have full responsibility for that code. The Cocoa portions are my work, and comments, suggestions, bug fixes, code contributions, and so on can be addressed to me.

I can’t guarantee complete or prompt support, but I’ll do what I can. Please try to understand the source code before you ask too many questions!

TidyLib Licensing
-----------------

I don’t own TidyLib and TidyLib is licensed under the MIT license. In short, it means you can do what you want with the code providing you leave the original copyright notice in place. This covers everything in this distribution that’s found in the `tidylib-src` group. For full details of the MIT license, you can see <http://www.opensource.org/licenses/mit-license.php>.

JSDTidyDocument Licensing
-------------------------

JSDTidyDocument files and class are also licensed under the MIT license. Do what you want with them in the bounds of the license, but please consider giving credit where it’s due, and bounce any positive changes back to me. This covers the contents of the `JSDTidy` files in the `JSDTidy` group. For full details of the MIT license, you can see <http://www.opensource.org/licenses/mit-license.php>.

Balthisar Tidy Licensing
------------------------

_Balthisar Tidy_ as a whole is also licensed under the MIT license. For full details of the MIT license, you can see <http://www.opensource.org/licenses/mit-license.php>.


The MIT License (MIT)
---------------------
_Copyright ©2013 James S. Derry_

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Change Log
----------
2013-11-10	Migrated to XCode 5.

Known Issues
------------

* Lots of bugs.

Todo
----

- if any of the errors are REMOVED something, then don't save!
- Substitute the NoodleKit text views.
- Redesign the main document interface with modern style.
- Make the batch mode work.
- Get the configuration dynamically at startup instead of using the file.
	- We can maintain a list of exceptions separately.
		- things to leave out
		- things to override with a text value
	-Probably add a method to support this directly.
