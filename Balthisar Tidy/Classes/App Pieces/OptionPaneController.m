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
#import "PreferencesDefinitions.h"
#import "JSDTidyModel.h"
#import "JSDTidyOption.h"
#import "JSDTableCellView.h"


#pragma mark - CATEGORY - Non-Public


@interface OptionPaneController ()


/* Important Stuff in the NIB */

@property (strong) IBOutlet NSView *rootView; // must keep strong

@property (weak) IBOutlet NSTableView *theTable;

@property (strong) IBOutlet NSArrayController *theArrayController; // must keep strong


/* Properties for managing the toggling of theDescription's visibility */

@property (weak) IBOutlet NSTextField *theDescription;

@property NSLayoutConstraint *theDescriptionConstraint;


/* Behavior and display properties */

@property (assign) BOOL isShowingFriendlyTidyOptionNames;

@property (assign) BOOL isShowingOptionsInGroups;


/* Exposing sort descriptors and predicates */

@property (readonly) NSArray *sortDescriptor;

@property (readonly) NSPredicate *filterPredicate;


/* Gradient button actions */

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
- (instancetype)init
{
	self = [super init];

	if (self)
	{
		[[NSBundle mainBundle] loadNibNamed:@"OptionPane" owner:self topLevelObjects:nil];

		_tidyDocument = [[JSDTidyModel alloc] init];

		
		/* This constraint will be modifed as needed to allow showing and hiding of the description field. */

		self.theDescriptionConstraint = [NSLayoutConstraint constraintWithItem:self.theDescription
																	 attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:0.0];


		/* These options are on a per-window basis, but originate from user defauts */

		self.isShowingFriendlyTidyOptionNames = [[NSUserDefaults standardUserDefaults] boolForKey:JSDKeyOptionsShowHumanReadableNames];

		self.isShowingOptionsInGroups = [[NSUserDefaults standardUserDefaults] boolForKey:JSDKeyOptionsAreGrouped];

		self.isInPreferencesView = NO;

	}

	return self;
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

	[self.rootView setFrame:[dstView bounds]];

	[dstView addSubview:self.rootView];
}


#pragma mark - Options Related


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionsInEffect:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSArray *)optionsInEffect
{
	return self.tidyDocument.optionsInUse;
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOptionsInEffect:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionsInEffect:(NSArray *)optionsInEffect
{
	self.tidyDocument.optionsInUse = optionsInEffect;

	[self.theArrayController bind:NSContentBinding toObject:self withKeyPath:@"tidyDocument.tidyOptionsBindable" options:nil];

	[self.theTable reloadData];
}


#pragma mark - Table Handling - Datasource and Delegate Methods


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


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tableView:keyWasPressed:row:
		Respond to table view keypresses.
		In this case we're allowing the left and right cursors keys
		to increment/decrement option values.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)tableView:(NSTableView *)aTableView keyWasPressed:(NSInteger)keyCode row:(NSInteger)rowIndex
{

	if ((rowIndex >= 0) && (( keyCode == 123) || (keyCode == 124)))
	{
		JSDTidyOption *localOption = self.theArrayController.arrangedObjects[rowIndex];
		
		if (keyCode == 123)
		{
			[localOption optionUIValueDecrement];
		}
		else
		{
			[localOption optionUIValueIncrement];
		}
		
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
	handleToggleDescription:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (IBAction)handleToggleDescription:(NSButton *)sender
{
	[self.rootView layoutSubtreeIfNeeded];

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
		{
			[context setAllowsImplicitAnimation: YES];

			/* This little function makes a nice acceleration curved based on the height. */
			context.duration = pow(1 / self.theDescription.intrinsicContentSize.height,1/3) / 5;

			if (sender.state)
			{
				[self.theDescription addConstraint:self.theDescriptionConstraint];
			}
			else
			{
				[self.theDescription removeConstraint:self.theDescriptionConstraint];
			}
			[self.rootView layoutSubtreeIfNeeded];
		}
		completionHandler:^
		{
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
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleResetOptionsToPreferences:
		- tell the tidyDocument to use the stored defaults.
		- notification system should handle the rest.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleResetOptionsToPreferences:(id)sender
{
	[self.tidyDocument takeOptionValuesFromDefaults:[NSUserDefaults standardUserDefaults]];
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
