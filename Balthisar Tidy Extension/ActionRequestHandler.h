/**************************************************************************************************

	ActionRequestHandler

	Handles the Action Extension actions for Balthisar Tidy, in order to tidy selected text
    in a host application.


	The MIT License (MIT)

	Copyright (c) 2003 to 2015 Jim Derry <http://www.balthisar.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software
	and associated documentation files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 **************************************************************************************************/

@import Cocoa;

/*
	Apple pointed out that the extension endpoint com.apple.services is only
	for iOS, which means that we *must* use com.apple.ui-services. This means
	on Mac OS X we *have* to inherit from NSViewController. There's a dummy
	nib, too, to facilitate this.
 */

@interface ActionRequestHandler : NSViewController <NSExtensionRequestHandling>

@end
