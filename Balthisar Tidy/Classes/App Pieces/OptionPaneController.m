/**************************************************************************************************

	OptionPaneController.m

	The main controller for the Tidy Options pane. Used separately by

	- document windows
	- the preferences window

	This controller parses `optionsInEffect.txt` in the application bundle, and compares
	the options listed there with the linked-in TidyLib to determine which options are
	in effect and valid. We use an instance of `JSDTidyModel` to deal with this.


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

#import "OptionPaneController.h"


#pragma mark - CATEGORY - Non-Public


@interface OptionPaneController ()

/* Major interface item outlets */
@property (nonatomic, weak) IBOutlet NSView *View;							// Pointer to the NIB's |View|.
@property (nonatomic, weak) IBOutlet NSTextField *theDescription;			// Pointer to the description field.


/* Miscellaneous properties */
@property (nonatomic, strong) NSLayoutConstraint *theDescriptionConstraint;	// The layout constraint we will apply to theDescription.
@property (nonatomic, assign) BOOL isInPreferencesView;
@property (nonatomic, assign) BOOL isShowingFriendlyTidyOptionNames;
@property (nonatomic, assign) BOOL isShowingOptionsInGroups;


/* Gradient button outlets */
@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemResetOptionsToFactoryDefaults;
@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemResetOptionsToPreferences;
@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemSaveOptionsToPreferences;
@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemShowFriendlyOptionNames;
@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemShowOptionsInGroups;
@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemSaveOptionsToUnixConfigFile;


/* Gradient button actions */
- (IBAction)toggleDescription:(NSButton *)sender;
- (IBAction)handleResetOptionsToFactoryDefaults:(id)sender;
- (IBAction)handleResetOptionsToPreferences:(id)sender;
- (IBAction)handleSaveOptionsToPreferences:(id)sender;
- (IBAction)handleShowFriendlyOptionNames:(id)sender;
- (IBAction)handleShowOptionsInGroups:(id)sender;
- (IBAction)handleSaveOptionsToUnixConfigFile:(id)sender;

@end


#pragma mark - IMPLEMENTATION


@implementation OptionPaneController


#pragma mark - Initialization and Deallocation


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initInternal - designated initializer (private)
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initInternal
{
	self = [super init];

	if (self)
	{
		[[NSBundle mainBundle] loadNibNamed:@"OptionPane" owner:self topLevelObjects:nil];

		_tidyDocument = [[JSDTidyModel alloc] init];
	}
	return self;

}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init - designated initializer
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)init
{
	self.isInPreferencesView = NO;
	return [self initInternal];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initInPreferencesView
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initInPreferencesView
{
	self.isInPreferencesView = YES;
	return [self initInternal];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	dealloc
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)dealloc
{
	_tidyDocument = nil;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	awakeFromNib
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void) awakeFromNib
{
	// Setup the background color
	[self.theTable setBackgroundColor:[NSColor clearColor]];

	// Clean up the table's row-height.
	[self.theTable setRowHeight:20.0f];

	// Setup some changing labels.
	self.theDescriptionConstraint = [NSLayoutConstraint constraintWithItem:self.theDescription
																 attribute:NSLayoutAttributeHeight
																 relatedBy:NSLayoutRelationEqual
																	toItem:nil
																 attribute:NSLayoutAttributeNotAnAttribute
																multiplier:1.0
																  constant:0.0];

	// Setup the isInPreferencesView characteristics
	if (self.isInPreferencesView)
	{
		[[self menuItemResetOptionsToPreferences] setHidden:YES];
		[[self menuItemSaveOptionsToPreferences] setHidden:YES];
	}
	else
	{
		[[self menuItemResetOptionsToFactoryDefaults] setHidden:YES];
	}

	// Other options
	self.isShowingFriendlyTidyOptionNames = [[NSUserDefaults standardUserDefaults] boolForKey:JSDKeyOptionsShowHumanReadableNames];

	self.isShowingOptionsInGroups = [[NSUserDefaults standardUserDefaults] boolForKey:JSDKeyOptionsAreGrouped];
}


#pragma mark - Setup


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	putViewIntoView:
		Whoever calls me will put my `View` into THIER `dstView`.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)putViewIntoView:(NSView *)dstView
{
	for (NSView *trash in [dstView subviews])
	{
		[trash removeFromSuperview];
	}
	
	[[[self theTable] enclosingScrollView] setHasHorizontalScroller:NO];

	[[self View] setFrame:[dstView bounds]];

	[dstView addSubview:_View];
}


#pragma mark - Options Related


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	> optionsInEffect
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionsInEffect:(NSArray *)optionsInEffect
{
	_optionsInEffect = optionsInEffect;
	self.tidyDocument.optionsInEffect = optionsInEffect;

	if (self.isShowingOptionsInGroups)
	{
		_optionsInEffect = [_optionsInEffect sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	}
}


#pragma mark - Action Menu Events


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleResetOptionsToFactoryDefaults
		- get factory default values for all optionsInEffect
		- set the tidyDocument to those.
		- notification system will handle the rest:
			- the tidyDocument will send a notification that the
			  implementor (the PreferenceController) is responsible
			  for detecting.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleResetOptionsToFactoryDefaults:(id)sender
{
	NSMutableDictionary *tidyFactoryDefaults = [[NSMutableDictionary alloc] init];

	[JSDTidyModel addDefaultsToDictionary:tidyFactoryDefaults fromArray:self.tidyDocument.optionsInEffect];

	[self.tidyDocument optionsCopyFromDictionary:tidyFactoryDefaults[JSDKeyTidyTidyOptionsKey]];

	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleResetOptionsToPreferences
		- tell the tidyDocument to use the stored defaults.
		- notification system should handle the rest.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleResetOptionsToPreferences:(id)sender
{
	[self.tidyDocument takeOptionValuesFromDefaults:[NSUserDefaults standardUserDefaults]];

	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleSaveOptionsToPreferences
		- the Preferences window might not exist yet, so all we
		  can really do is write out the preferences, and try
		  sending a notification.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleSaveOptionsToPreferences:(id)sender
{
	[self.tidyDocument writeOptionValuesWithDefaults:[NSUserDefaults standardUserDefaults]];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"appNotifyStandardUserDefaultsChanged" object:self];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleShowFriendlyOptionNames
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleShowFriendlyOptionNames:(id)sender
{
	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleShowOptionsInGroups
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleShowOptionsInGroups:(id)sender
{
	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleSaveOptionsToUnixConfigFile
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleSaveOptionsToUnixConfigFile:(id)sender
{

}


#pragma mark - Table Handling - Datasource and Delegate Methods


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:viewForTableColumn:row:
		We're here because we're the delegate of `theTable`.
		We need to deliver a view to show in the table.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
				  row:(NSInteger)row
{
	// Setup the view if it's a header.
	if ( tableColumn == nil)
	{
		NSTextField *theView = [tableView makeViewWithIdentifier:@"header" owner:self];
		if (theView == nil)
		{
			theView = [[NSTextField alloc] initWithFrame:NSZeroRect];
		}
		[theView setEditable:NO];
		theView.stringValue = self.optionsInEffect[row];
		return theView;
	}


	JSDTidyOption *optionRef = [[self tidyDocument] tidyOptions][self.optionsInEffect[row]];


	// Setup the view if it's a one of the Tidy Option Names.
	if ([tableColumn.identifier isEqualToString:@"name"])
	{
		NSTableCellView *theView = [tableView makeViewWithIdentifier:@"optionName" owner:self];

		[theView.textField setEditable:NO];

		if ( self.isShowingFriendlyTidyOptionNames )
		{
			theView.objectValue = optionRef.localizedHumanReadableName;
		}
		else
		{
			theView.objectValue = self.optionsInEffect[row];
		}

		return theView;
	}


	// Setup the view if it's one of the option values.
	if ( [tableColumn.identifier isEqualToString:@"check"])
	{
		JSDTableCellView *theView;

		// Pure Text View
		if ( optionRef.optionUIType == [NSTextField class] )
		{
			theView = [tableView makeViewWithIdentifier:@"optionString" owner:self];
		}

		// NSPopupMenu View
		if ( optionRef.optionUIType == [NSPopUpButton class] )
		{
			theView = [tableView makeViewWithIdentifier:@"optionPopup" owner:self];
			[[theView popupButtonControl] addItemsWithTitles:optionRef.possibleOptionValues];
		}

		// NSStepper View
		if ( optionRef.optionUIType == [NSStepper class] )
		{
			theView = [tableView makeViewWithIdentifier:@"optionStepper" owner:self];
		}

		[theView.textField setEditable:YES];

		theView.objectValue = optionRef.optionUIValue;

		return theView;

	}

	return nil;

}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:setObjectValue:forTableColumn:row
		We're here because we're the datasource of `theTable`.
		Retrieves the data object for an item in the specified row 
		and column. The user changed a value in `theTable` and so we
		will record that in our own data structure.
 
		NOTE: this is actually deprecated in view-based tables,
		but it's convenient given our data model. Thus it's
		being called (as a datasource) from the CellView.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)inColumn row:(NSInteger)inRow
{
	if ([[inColumn identifier] isEqualToString:@"check"])
	{
		JSDTidyOption *optionRef = [[self tidyDocument] tidyOptions][self.optionsInEffect[inRow]];
				
		if ([object isKindOfClass:[NSString class]])
		{
			optionRef.optionUIValue = [NSString stringWithString:object];
		}
		else
		{
			optionRef.optionUIValue = [object stringValue];
		}
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableViewSelectionDidChange:
		We're here because we're the delegate of the `theTable`.
		This is NOT a notification center notification. Whenever 
		the selection changes, update `theDescription` with the 
		correct, new description from Localizable.strings.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == [self theTable])
	{
		NSString *selectedOptionName = self.optionsInEffect[[[self theTable] selectedRow]];
		
		JSDTidyOption *optionRef = [[self tidyDocument] tidyOptions][selectedOptionName];
		
		[[self theDescription] setAttributedStringValue:optionRef.localizedHumanReadableDescription];
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	numberOfRowsInTableView:
		We're here because we're the datasource of the `theTable`.
		We need to specify how many items are in the table view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self.optionsInEffect count];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:isGroupRow:
		We're here because we're the delegate of the `theTable`.
		We need to specify if the row is a group row or not.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
-(BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	return NO;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:shouldSelectRow:
		We're here because we're the delegate of the `theTable`.
		We need to specify if it's okay to select the row.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return YES;

}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:keyWasPressed:row:
		Respond to table view keypresses.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)tableView:(NSTableView *)aTableView keyWasPressed:(NSInteger)keyCode row:(NSInteger)rowIndex
{

	if ((rowIndex >= 0) && (( keyCode == 123) || (keyCode == 124)))
	{
		NSString *selectedOptionName = self.optionsInEffect[[[self theTable] selectedRow]];

		JSDTidyOption *optionRef = [[self tidyDocument] tidyOptions][selectedOptionName];

		if (keyCode == 123)
		{
			[optionRef optionUIValueDecrement];
		}
		else
		{
			[optionRef optionUIValueIncrement];
		}

		[[aTableView viewAtColumn:[aTableView columnWithIdentifier:@"check"]
							  row:rowIndex makeIfNecessary:NO] setObjectValue:optionRef.optionUIValue];

		return YES;
	}

	return NO;
}


#pragma mark - Description Field Handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	toggleDescription
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (IBAction)toggleDescription:(NSButton *)sender
{
	[_View layoutSubtreeIfNeeded];
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		[context setAllowsImplicitAnimation: YES];
		// This little function makes a nice acceleration curved based on the height.
		context.duration = pow(1 / self.theDescription.intrinsicContentSize.height,1/3) / 5;
		if (sender.state)
		{
			[self.theDescription addConstraint:self.theDescriptionConstraint];
		}
		else
		{
			[self.theDescription removeConstraint:self.theDescriptionConstraint];
		}
		[_View layoutSubtreeIfNeeded];
	} completionHandler:^{
		[[self theTable] scrollRowToVisible:self.theTable.selectedRow];
	}];



}


#pragma mark - Split View Handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:constrainMinCoordinate:ofSubviewAt:
		We're here because we're the delegate of the split view.
		This will impose a minimum limit on the UPPER pane of the
		split.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return 68.0f;
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:constrainMaxCoordinate:ofSubviewAt:
		We're here because we're the delegate of the split view.
		In order to guarantee a minimum size for the LOWER pane,
		we have to setup a dyanmic maximum size for the UPPER.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return [splitView frame].size.height - 40.0f;
}

@end
