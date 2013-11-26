/**************************************************************************************************

	BatchController.m

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

#import "BatchController.h"
#import "TreeNode.h"

@implementation BatchController


#pragma mark -
#pragma mark initialization and deallocation


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 init
 Our creator -- we will do the following:
 o init the window with the "Batch" nib.
 o set out window frame auto-save name.
 o initialize our instance variables.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)init
{
	if (self = [super initWithWindowNibName:@"Batch"])
	{
		/*
		 TreeNode *tempNode = nil;
		 [self setWindowFrameAutosaveName:@"BatchWindow"];
		 fileTree = [[TreeNode treeNodeWithData:@"Invisible Node"] retain];
		 tempNode = [TreeNode treeNodeWithData:@"First Node"];
		 [fileTree insertChild:tempNode atIndex:0];
		 tempNode = [TreeNode treeNodeWithData:@"Second Node"];
		 [fileTree insertChild:tempNode atIndex:1];
		 [tempNode insertChild:[TreeNode treeNodeWithData:@"First Sub Node"] atIndex:0];
		 //[fileTree insertChild:[TreeNode treeNodeWithData:@"First Node"] atIndex:0];
		 //[fileTree insertChild:[TreeNode treeNodeWithData:@"Second Node"] atIndex:1];

		 [self setWindowFrameAutosaveName:@"BatchWindow"];
		 */
	} // if
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 dealloc
 Our destructor. We will:
 o release our instance variables
 o call the inherited method to ensure everything else is ok.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)dealloc
{
	[[self optionsController] release];
	[[self fileTree] release];
	[super dealloc];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 windowDidLoad
 when the window has loaded, let's do:
 o honor the preferences and pre-set the controls.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)windowDidLoad
{
	/*
	 NSUserDefaults *defaults;
	 defaults = [NSUserDefaults standardUserDefaults];
	 colorAsData = [defaults objectForKey: BNRTableBgColorKey];
	 [colorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];
	 [checkbox setState:[defaults boolForKey:BNREmptyDocKey]]; */
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 awakeFromNib
 When we wake from the nib file, setup the option controller
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void) awakeFromNib
{
	// create a OptionPaneController and put it in place of optionPane
	if (![self optionsController])
		_optionsController = [[OptionPaneController alloc] init];
	[_optionsController putViewIntoView:[self optionPane]];
	[_optionsController setTarget:self];
	// [_optionsController setAction:@selector(optionChanged:)];
} // awakeFromNib


/****************************************************************************************************
 DATA SOURCE methods for the NSOutlineView.
 ****************************************************************************************************/


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 outlineView:isItemExpandable
 the NSOutlineView polls this delegate method to determine if an
 item is expandable. We'll say okay if there are children.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return ([item numberOfChildren] > 0);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 outlineView:numberOfChildrenOfItem
 the NSOutlineView polls this delegate method to determine how
 many children an item has.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSUInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	// if item is nil, then we're the root of the VIEW! We should ge the root of the fileTree.
	if (item == nil)
		return [_fileTree numberOfChildren];	// return number of fileList top level nodes.
	else
		return [item numberOfChildren]; 	// return the item number of children already in the view.
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 outlineView:child:ofItem
 the NSOutlineView polls this delegate method to retrieve the
 children of the item. It will be called repeatedly to get the
 sucessive children, based on how many children were returned
 for numberOfChildrenOfItem.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	// if item is nil, then we're the root of the VIEW! We should ge the root of the fileTree.
	if (item == nil)
		return [_fileTree childAtIndex:index];	// return the top-level sibling nodes of fileTree.
	else
		return [item childAtIndex:index]; 	// otherwise, item will be part of fileTree with its own children.
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 outlineView:objectValueForTableColumn:byItem
 the NSOutlineView polls this delegate method to retrieve the
 data to display for each column of each item of the view. We're
 going to retrieve the nodeData for each item, which should be
 a string, which will be displayed by the view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return (NSString *)[item nodeData];
}

-(IBAction)startBatch:(id)sender {

}

@end
