/**************************************************************************************************

	TidyDocument.h
	 
	part of Balthisar Tidy

	The main document controller. Here we'll control the following:

		o


	The MIT License (MIT)

	Copyright (c) 2001 to 2013 James S. Derry <http://www.balthisar.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software
	and associated documentation files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell	copies of the Software, and to permit persons to whom the
	Software is	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 **************************************************************************************************/

#import <Cocoa/Cocoa.h>
#import "JSDTidyDocument.h"
#import "OptionPaneController.h"

@interface TidyDocument : NSDocument
{
	// view outlets
	IBOutlet NSTextView *sourceView;		// pointer to the source HTML view.
	IBOutlet NSTextView *tidyView;			// pointer to the tidy'd HTML view.
	IBOutlet NSTableView *errorView;		// pointer to where to display the error messages.

	// items for the option controller and pane
	IBOutlet NSView *optionPane;			// pointer to our empty optionPane.
	OptionPaneController *optionController;	// this will control the real option pane loaded into optionPane

	// internally-used instance variables.
	JSDTidyDocument* tidyProcess;			// our tidy wrapper/processor.
	NSInteger saveBehavior;					// the save behavior from the preferences.
	bool saveWarning;						// the warning behavior for when saveBehavior == 1;
	bool yesSavedAs;						// disable warnings and protections once a save-as has been done.
	bool tidyOriginalFile;					// flags whether the file was CREATED by Tidy, for writing type/creator codes.
}

- (IBAction)optionChanged:(id)sender;		// react to a tidy'ing control being changed.

- (IBAction)errorClicked:(id)sender;		// react to an error row being clicked.

- (void)retidy;								// tidy's itself.
@end
