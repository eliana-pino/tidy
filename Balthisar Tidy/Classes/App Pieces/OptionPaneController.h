/**************************************************************************************************
    OptionPaneController.h
 
	part of Balthisar Tidy

    The main controller for the multi-use option pane. implemented separately for

        o use on a document window
        o use on the preferences window
        
    This controller parses optionsInEffect.txt in the application bundle, and compares
    the options listed there with the linked-in TidyLib to determine which options are
    in effect and valid. We use an instance of |JSDTidyDocument| to deal with this.


	The MIT License (MIT)

	Copyright (c) 2001 to 2013 James S. Derry <http://www.balthisar.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

 **************************************************************************************************/

#import <Cocoa/Cocoa.h>
#import "JSDTidy.h"

@interface OptionPaneController : NSObject {
    IBOutlet NSView 	 *myView;		// pointer to the view -- will be returned by getView.
    IBOutlet NSTableView *theTable;		// pointer to the table
    IBOutlet NSTextField *theDescription;	// pointer to the description field.
    
    SEL _action;				// routine to be called (action method) when an option changes.
    id _target;					// the target for the action method (optional--can be nil targeted).
    
    NSArray 		 *optionsInEffect;	// array of NSString that holds the options we really want to use.
    NSArray		 *optionsExceptions;	// array of NSString that holds the options we want to treat as STRINGS
    JSDTidyDocument      *tidyProcess;		// our tidy wrapper/processor for dealing with valid options dynamically.

}

-(id)init;					// initialize the view so we can use it.
-(NSView *)getView;				// return the view so that it can be used in a parent window.
-(void)putViewIntoView:(NSView *)dstView;	// make the view of this controller the view of dstView.

-(IBAction)optionChanged:(id)sender;		// handle an option changing in the tableview.

-(SEL)action;					// returns the action for this controller when options change.
-(void)setAction:(SEL)theAction;		// sets the action for this controller when options change.
-(id)target;					// returns the target for this controller.
-(void)setTarget:(id)theTarget;			// sets the target -- optional, can be nil-targeted action.

-(void)tidyDocument:(JSDTidyDocument *)theDoc;	// set method for tidyProcess
-(JSDTidyDocument *)tidyDocument;		// get method for tidyProcess

@end
