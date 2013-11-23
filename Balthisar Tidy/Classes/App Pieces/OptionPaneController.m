/**************************************************************************************************
 
	OptionPaneController.m

	part of Balthisar Tidy

	The main controller for the multi-use option pane. implemented separately for

		o use on a document window
		o use on the preferences window

	This controller parses optionsInEffect.txt in the application bundle, and compares
	the options listed there with the linked-in TidyLib to determine which options are
	in effect and valid. We use an instance of |JSDTidyDocument| to deal with this.


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

#import "OptionPaneController.h"
#import "JSDTableColumn.h"


#pragma mark -
#pragma mark Non-Public iVars, Properties, and Method declarations

@interface OptionPaneController ()
{
    NSArray *optionsInEffect;		// Array of NSString that holds the options we really want to use.
    NSArray	*optionsExceptions;		// Array of NSString that holds the options we want to treat as STRINGS
}

	@property (nonatomic) IBOutlet NSTableView *theTable;			// Pointer to the table
	@property (nonatomic) IBOutlet NSTextField *theDescription;		// Pointer to the description field.

@end


#pragma mark -
#pragma mark Implementation

@implementation OptionPaneController


#pragma mark -
#pragma mark initializers and deallocs


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init - designated initializer
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
-(id)init
{
	if ([super init])
	{
		[[NSBundle mainBundle] loadNibNamed:@"OptionPane" owner:self topLevelObjects:nil];

		_tidyDocument = [[JSDTidyDocument alloc] init];

		// Get our options list
		optionsInEffect = [[NSArray arrayWithArray:[JSDTidyDocument loadConfigurationListFromResource:@"optionsInEffect" ofType:@"txt"]] retain];

		// Get our exception list (items to treat as string regardless of tidylib definition)
		optionsExceptions = [[NSArray arrayWithArray:[JSDTidyDocument loadConfigurationListFromResource:@"optionsTypesExceptions" ofType:@"txt"]] retain];

		// Create a custom column for the NSTableView -- the table will retain and control it.
		[[JSDTableColumn alloc] initReplacingColumn:[_theTable tableColumnWithIdentifier:@"check"]];
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	dealloc
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)dealloc
{   
    [_tidyDocument release];
    [optionsInEffect release];
    [optionsExceptions release];
    [super dealloc];
}


#pragma mark -
#pragma mark Setup


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	putViewIntoView:
	Whoever calls me will put my |View| into THIER |dstView|.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
-(void)putViewIntoView:(NSView *)dstView
{
    NSEnumerator *enumerator = [[dstView subviews] objectEnumerator];
    NSView *trash;

    while (trash = [enumerator nextObject])
	{
        [trash removeFromSuperview];
	}

	[_View setFrame:[dstView frame]];


	[dstView setAutoresizesSubviews:YES];
	[_View setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[[_theTable enclosingScrollView] setHasHorizontalScroller:NO];

    [dstView addSubview:_View];
}


#pragma mark -
#pragma mark Table Handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableViewSelectionDidChange:
		We arrived here by virtue of this controller class being the
		delegate of |theTable|. Whenever the selection changes
		update |theDescription| with the correct, new description
		from Localizable.strings.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    // Get the description of the selected row.
    if ([aNotification object] == _theTable)
	{
        [_theDescription setStringValue:NSLocalizedString(optionsInEffect[[_theTable selectedRow]], nil)];
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	numberOfRowsInTableView
		We're here because we're the datasource of the |theTable|.
		We need to specify how many items are in the table view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [optionsInEffect count];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:objectValueForTableColumn:row
		We're here because we're the datasource of |theTable|.
		We need to specify what to show in the row/column.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    // Get the id for the option at this row.
    TidyOptionId optId = [JSDTidyDocument optionIdForName:optionsInEffect[rowIndex]]; 

    // Handle returning the 'name" of the option.
    if ([[aTableColumn identifier] isEqualToString:@"name"])
	{
        return optionsInEffect[rowIndex];
	}

    // Handle returning the 'value' column of the option.
    if ([[aTableColumn identifier] isEqualToString:@"check"])
	{
        // if we're working on Encoding, then return the INDEX in allAvailableStringEncodings of the value.
        if ( (optId == TidyCharEncoding) || (optId == TidyInCharEncoding) || (optId == TidyOutCharEncoding) )
		{
            int i = [[_tidyDocument optionValueForId:optId] intValue];									// Value of option
            NSUInteger j = [[[_tidyDocument class] allAvailableStringEncodings] indexOfObject:@(i)];	// Index of option
            return [[NSNumber numberWithLong:j] stringValue];											// Return Index as a string
        } else {
            return [_tidyDocument optionValueForId:optId];
		}
	}
    return @"";
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableColumn:customDataCellForRow
		We're here because we're the datasource of |theTable|.
		We need to specify which cell to use for this particular row.
		Here we are providing the cell for use by the table.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)tableColumn:(JSDTableColumn *)aTableColumn customDataCellForRow:(NSInteger)row
{
    // Get the id for the option at this row
    TidyOptionId optId = [JSDTidyDocument optionIdForName:optionsInEffect[row]]; 

    if ([[aTableColumn identifier] isEqualToString:@"check"])
	{
           NSArray *picks = [JSDTidyDocument optionPickListForId:optId];

           // Return a popup only if there IS a picklist and the item is not in the optionsExceptions array
           if ( ([picks count] != 0) && (![optionsExceptions containsObject:optionsInEffect[row]] ) )
                return [aTableColumn usefulPopUpCell:picks];     
    }

    return nil;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:shouldEditTableColumn:row
		We're here because we're the delegate of |theTable|.
		We need to disable for text editing cells with widgets.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"check"])
	{
        if ([[aTableColumn dataCellForRow:rowIndex] class] != [NSTextFieldCell class])
		{
            return NO;
        } else {
            return YES;
		}
    }

    return NO;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:setObjectValue:forTableColumn:row
		user changed a value -- let's record it!
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)inColumn row:(int)inRow
{
    TidyOptionId optId = [JSDTidyDocument optionIdForName:optionsInEffect[inRow]]; 
    if ([[inColumn identifier] isEqualToString:@"check"])
	{
        // if we're working with encoding, we need to get the NSStringEncoding instead of the index of the item.
        if ( (optId == TidyCharEncoding) || (optId == TidyInCharEncoding) || (optId == TidyOutCharEncoding) ) {
            id myNumber = [[_tidyDocument class] allAvailableStringEncodings][[object unsignedLongValue]];
            [_tidyDocument setOptionValueForId:optId fromObject:myNumber];
        } else {
            [_tidyDocument setOptionValueForId:optId fromObject:object];
		}
		// signal the update
		[NSApp sendAction:_action to:_target from:self];
    }
}


@end
