/**************************************************************************************************

	TidyDocumentWindowController
	 
	The main document window controller; manages the view and UI for a TidyDocument window.


	The MIT License (MIT)

	Copyright (c) 2001 to 2014 James S. Derry <http://www.balthisar.com>

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

#import <Cocoa/Cocoa.h>

@class OptionPaneController;
@class EncodingHelperController;
@class FirstRunController;
@class JSDTidyModel;


@interface TidyDocumentWindowController : NSWindowController <NSTableViewDelegate, NSSplitViewDelegate, NSTextViewDelegate>


/* Document references */

@property (readonly) JSDTidyModel *tidyProcess;

@property (readonly) NSData *documentOpenedData;



/* View Outlets */

@property (assign) IBOutlet NSTextView  *sourceView;

@property (assign) IBOutlet NSTextView  *tidyView;

@property (weak)   IBOutlet NSTableView *errorView;


/* ArrayController linked to tidyProcess' error array. */

@property (strong) IBOutlet NSArrayController *messagesArrayController;


/* Window Splitters */

@property (weak) IBOutlet NSSplitView *splitLeftRight;

@property (weak) IBOutlet NSSplitView *splitTopDown;


/* Option Controller */

@property (weak)   IBOutlet NSView      *optionPane;         // Our empty optionPane in the nib.

@property          OptionPaneController *optionController;   // The real option pane we load into optionPane.


/* Document Control */

@property (assign) BOOL documentIsLoading;     // Flag to supress certain event updates.


/* Helpers */

@property FirstRunController *firstRun;

@property EncodingHelperController *encodingHelper;


/* React after saving a file */

- (void)documentDidWriteFile;


@end
