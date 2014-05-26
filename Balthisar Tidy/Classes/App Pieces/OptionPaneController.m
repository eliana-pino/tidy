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

/* The NIB's root-level view */

@property (nonatomic, weak) IBOutlet NSView *View;


/* Properties for managing the toggling of theDescription's visibility */

@property (nonatomic, weak) IBOutlet NSTextField *theDescription;

@property (nonatomic, strong) NSLayoutConstraint *theDescriptionConstraint;


/* Behavior and display properties */

@property (nonatomic, assign) BOOL isShowingFriendlyTidyOptionNames;

@property (nonatomic, assign) BOOL isShowingOptionsInGroups;


/* Exposing sort descriptors and predicates */

@property (nonatomic, strong) NSArray *sortDescriptor;

@property (nonatomic, strong) NSPredicate *filterPredicate;


/* Gradient button actions */

- (IBAction)handleGenericReloadData:(id)sender;

- (IBAction)handleToggleDescription:(NSButton *)sender;

- (IBAction)handleResetOptionsToFactoryDefaults:(id)sender;

- (IBAction)handleResetOptionsToPreferences:(id)sender;

- (IBAction)handleSaveOptionsToPreferences:(id)sender;

- (IBAction)handleSaveOptionsToUnixConfigFile:(id)sender;


@end


#pragma mark - IMPLEMENTATION


@implementation OptionPaneController


#pragma mark - Initialization and Deallocation


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init - designated initializer
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)init
{
	self = [super init];

	if (self)
	{
		[[NSBundle mainBundle] loadNibNamed:@"OptionPane" owner:self topLevelObjects:nil];

		_tidyDocument = [[JSDTidyModel alloc] init];

		self.isInPreferencesView = NO;
	}
	return self;

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
	/*
		This constraint will be modifed as needed in order to
		allow showing and hiding of the description field.
	 */
	self.theDescriptionConstraint = [NSLayoutConstraint constraintWithItem:self.theDescription
																 attribute:NSLayoutAttributeHeight
																 relatedBy:NSLayoutRelationEqual
																	toItem:nil
																 attribute:NSLayoutAttributeNotAnAttribute
																multiplier:1.0
																  constant:0.0];


	/* These options are on a per-window basis, but default from user defauts */

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

	[self.theTable.enclosingScrollView setHasHorizontalScroller:NO];

	[self.View setFrame:[dstView bounds]];

	[dstView addSubview:_View];
}


#pragma mark - Options Related


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOptionsInEffect:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionsInEffect:(NSArray *)optionsInEffect
{
	_optionsInEffect = optionsInEffect;

	self.tidyDocument.optionsInUse = optionsInEffect;

	[self.theArrayController bind:NSContentBinding toObject:self withKeyPath:@"tidyDocument.tidyOptionsBindable" options:nil];
}


#pragma mark - Table Handling - Datasource and Delegate Methods


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:viewForTableColumn:row:
		We're here because we're the delegate of `theTable`.
		We need to deliver a view to show in the table. Note that
		the data still comes from Cocoa bindings, but this delegate
		method is still required to provide the correct type of
		view based on the tidy optionUIType.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
				  row:(NSInteger)row
{
	/* Setup the view if it's a header. */
	
	if (tableColumn == nil)
	{
		NSTableCellView *theView = [tableView makeViewWithIdentifier:@"categoryHeader" owner:nil];

		//[theView.textField setEditable:NO];

		return theView;
	}


	/* Setup the view if it's a one of the Tidy Option Names. */
	
	if ([tableColumn.identifier isEqualToString:@"name"])
	{
		NSTableCellView *theView;

		if (self.isShowingFriendlyTidyOptionNames)
		{
			theView = [tableView makeViewWithIdentifier:@"optionNameLocalized" owner:nil];
		}
		else
		{
			theView = [tableView makeViewWithIdentifier:@"optionName" owner:nil];
		}

		return theView;
	}


	JSDTidyOption *optionRef = self.theArrayController.arrangedObjects[row];

	/* Setup the view if it's one of the option values. */
	
	if ( [tableColumn.identifier isEqualToString:@"check"])
	{
		JSDTableCellView *theView;

		/* Pure Text View */
		if ( optionRef.optionUIType == [NSTextField class] )
		{
			theView = [tableView makeViewWithIdentifier:@"optionString" owner:nil];
		}

		/* NSPopupMenu View */
		if (optionRef.optionUIType == [NSPopUpButton class])
		{
			theView = [tableView makeViewWithIdentifier:@"optionPopup" owner:nil];
		}

		/* NSStepper View */
		if (optionRef.optionUIType == [NSStepper class])
		{
			theView = [tableView makeViewWithIdentifier:@"optionStepper" owner:nil];
		}

		return theView;

	}

	return nil;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:isGroupRow:
		We're here because we're the delegate of the `theTable`.
		We need to specify if the row is a group row or not.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
-(BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	JSDTidyOption *localOption = self.theArrayController.arrangedObjects[row];

	return localOption.optionIsHeader;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:shouldSelectRow:
		We're here because we're the delegate of the `theTable`.
		We need to specify if it's okay to select the row.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	JSDTidyOption *localOption = self.theArrayController.arrangedObjects[rowIndex];

	return !localOption.optionIsHeader;
}




///*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
//	tableView:setObjectValue:forTableColumn:row
//		We're here because we're the datasource of `theTable`.
//		Retrieves the data object for an item in the specified row 
//		and column. The user changed a value in `theTable` and so we
//		will record that in our own data structure.
// 
//		NOTE: this is actually deprecated in view-based tables,
//		but it's convenient given our data model. Thus it's
//		being called (as a datasource) from the CellView.
// *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
//- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)inColumn row:(NSInteger)inRow
//{
//	if ([[inColumn identifier] isEqualToString:@"check"])
//	{
//		JSDTidyOption *optionRef = self.tidyDocument.tidyOptions[self.optionsInEffect[inRow]];
//				
//		if ([object isKindOfClass:[NSString class]])
//		{
//			optionRef.optionUIValue = [NSString stringWithString:object];
//		}
//		else
//		{
//			optionRef.optionUIValue = [object stringValue];
//		}
//	}
//}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:keyWasPressed:row:
		Respond to table view keypresses.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)tableView:(NSTableView *)aTableView keyWasPressed:(NSInteger)keyCode row:(NSInteger)rowIndex
{

	if ((rowIndex >= 0) && (( keyCode == 123) || (keyCode == 124)))
	{
		JSDTidyOption *localOption = self.theArrayController.arrangedObjects[row];
		
		if (keyCode == 123)
		{
			[localOption optionUIValueDecrement];
		}
		else
		{
			[localOption optionUIValueIncrement];
		}

		// @todo: this should cause everything to update automatically; verify in debugger! */
		// Maybe need this -> [self.theTable reloadData];
		
		return YES;
	}

	return NO;
}


#pragma mark - Sorting and Filtering Handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	keyPathsForValuesAffectingFilterPredicate
		Signal to KVO that if one of the included keys changes,
		then it should also be aware that filterPredicate changed.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSSet *)keyPathsForValuesAffectingFilterPredicate
{
    return [NSSet setWithObjects:@"isShowingFriendlyTidyOptionNames", @"isShowingOptionsInGroups", nil];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	filterPredicate
		We never want to show option that are supressed. If we are
		not showing options in groups, then we want to also hide
		the groups.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSPredicate*)filterPredicate
{
	if (self.isShowingOptionsInGroups)
	{
		return [NSPredicate predicateWithFormat:@"(optionIsSuppressed == %@)", @(NO)];
	}
	else
	{
		return [NSPredicate predicateWithFormat:@"(optionIsSuppressed == %@) AND (optionIsHeader == NO)", @(NO)];
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	keyPathsForValuesAffectingSortDescriptor
		Signal to KVO that if one of the included keys changes,
		then it should also be aware that sortDescriptor changed.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSSet *)keyPathsForValuesAffectingSortDescriptor
{
    return [NSSet setWithObjects:@"isShowingFriendlyTidyOptionNames", @"isShowingOptionsInGroups", nil];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	sortDescriptor
		We have four ways that we have to sort. 
		
		If we are not in groups, then we have to sort by name or by
		localizedHumanReadableName.
 
		If we are grouped, then we also have to get the headers
		and sort by name or localizedHumanReadableName.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSArray*)sortDescriptor
{
	NSString *nameSortKey;
	SEL sortingSelector;

	if (self.isShowingFriendlyTidyOptionNames)
	{
		nameSortKey = @"localizedHumanReadableName";
		sortingSelector = @selector(tidyGroupedHumanNameCompare:);
	}
	else
	{
		nameSortKey = @"name";
		sortingSelector = @selector(tidyGroupedNameCompare:);
	}
	

	if (self.isShowingOptionsInGroups)
	{
		return @[[NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES selector:sortingSelector]];
	}
	else
	{
		return @[[NSSortDescriptor sortDescriptorWithKey:nameSortKey ascending:YES selector:@selector(localizedStandardCompare:)]];
	}

}


#pragma mark - Gradient Button Event Handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleGenericReloadData:
		Properties control a lot of things, but sometimes the
		table needs to be refresh in order to show the results.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleGenericReloadData:(id)sender
{
	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleToggleDescription:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (IBAction)handleToggleDescription:(NSButton *)sender
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

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleResetOptionsToFactoryDefaults:
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

	[JSDTidyModel addDefaultsToDictionary:tidyFactoryDefaults fromArray:self.tidyDocument.optionsInUse];

	[self.tidyDocument optionsCopyValuesFromDictionary:tidyFactoryDefaults[JSDKeyTidyTidyOptionsKey]];

	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleResetOptionsToPreferences:
		- tell the tidyDocument to use the stored defaults.
		- notification system should handle the rest.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleResetOptionsToPreferences:(id)sender
{
	[self.tidyDocument takeOptionValuesFromDefaults:[NSUserDefaults standardUserDefaults]];

	[self.theTable reloadData];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleSaveOptionsToPreferences:
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
	handleSaveOptionsToUnixConfigFile:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleSaveOptionsToUnixConfigFile:(id)sender
{

}


@end
