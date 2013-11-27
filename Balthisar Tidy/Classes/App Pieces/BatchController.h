/**************************************************************************************************

	BatchController.h

	part of Balthisar Tidy

	The main controller for the batch-mode interface. Here we'll control the following:

		o We're the Datasource delegate for the |NSOutlineView|, so handle that.
		o We're going to handle drag-and-drop on the |NSOutlineView| for adding files.
		o We're going to implement and control the interface for doing the Tidy'ing.


	The MIT License (MIT)

	Copyright (c) 2001 to 2013 James S. Derry <http://www.balthisar.com>

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
#import "TreeNode.h"
#import "OptionPaneController.h"

@interface BatchController : NSWindowController

	@property (strong) IBOutlet NSOutlineView *fileList;			// Outlet for the |NSOutlineView|
	@property (strong) IBOutlet NSView *optionPane;					// Pointer to the empty |OptionPane|

	@property (strong) OptionPaneController *optionsController;		// The "real" optionPane loaded into |optionPane|
	@property (strong) JSDTidyDocument *tidyProcess;				// Pointer to the local tidy process

	@property (strong) TreeNode *fileTree;							// Holds the list of things we will batch


	- (IBAction)startBatch:(id)sender;								// Handler for the batch button being pressed.

	- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
	- (NSUInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
	- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
	- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end
