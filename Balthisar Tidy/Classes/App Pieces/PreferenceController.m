/**************************************************************************************************

	PreferenceController.m

	The main preference controller. Here we'll control the following:

	- Handles the application preferences.
	- Implements class methods to be used before instantiation.

	This controller parses `optionsInEffect.txt` in the application bundle, and compares
	the options listed there with the linked-in TidyLib to determine which options are
	in effect and valid. We use an instance of `JSDTidyModel` to deal with this.
 

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

#import "PreferenceController.h"
#import "PreferencesDefinitions.h"
#import "OptionPaneController.h"
#import "JSDTidyModel.h"

#if INCLUDE_SPARKLE == 1
	#import <Sparkle/Sparkle.h>
#endif


#pragma mark - CATEGORY - Non-Public


@interface PreferenceController ()


#pragma mark - Properties


/* Software Updater Pane Preferences and Objects */
@property (weak) IBOutlet NSTabViewItem *tabViewUpdates;
@property (weak) IBOutlet NSButton      *buttonAllowUpdateChecks;
@property (weak) IBOutlet NSButton      *buttonAllowSystemProfile;
@property (weak) IBOutlet NSPopUpButton * buttonUpdateInterval;


/* Other Properties */
@property (weak) IBOutlet NSTabView *tabView;            // The tab view.
@property (weak) IBOutlet NSView    *optionPane;         // The empty pane in the nib that we will inhabit.
@property OptionPaneController      *optionController;   // The real option pane loaded into optionPane.


@end


#pragma mark - IMPLEMENTATION


@implementation PreferenceController


#pragma mark - Class Methods


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	sharedPreferences (class)
		Implement this class as a singleton.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (id)sharedPreferences
{
    static PreferenceController *sharedMyPrefController = nil;
	
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{ sharedMyPrefController = [[self alloc] init]; });
	
    return sharedMyPrefController;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	registerUserDefaults (class)
		Register all of the user defaults. Implemented as a CLASS
		method in order to keep this with the preferences controller.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (void)registerUserDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	/* Tidy Options */
	[JSDTidyModel addDefaultsToDictionary:defaultValues];

	/** Options List Appearance */
	[defaultValues setObject:@YES forKey:JSDKeyOptionsAlternateRowColors];
	[defaultValues setObject:@YES forKey:JSDKeyOptionsAreGrouped];
	[defaultValues setObject:@NO  forKey:JSDKeyOptionsShowHumanReadableNames];
	[defaultValues setObject:@YES forKey:JSDKeyOptionsUseHoverEffect];

	/** Document Appearance */
	[defaultValues setObject:@YES forKey:JSDKeyShowNewDocumentLineNumbers];
	[defaultValues setObject:@YES forKey:JSDKeyShowNewDocumentMessages];
	[defaultValues setObject:@YES forKey:JSDKeyShowNewDocumentTidyOptions];
	[defaultValues setObject:@YES forKey:JSDKeyShowNewDocumentSideBySide];
	[defaultValues setObject:@YES forKey:JSDKeyShowNewDocumentSyncInOut];

	/* File Saving Options */
	[defaultValues setObject:@(kJSDSaveAsOnly) forKey:JSDKeySavingPrefStyle];

	/* Miscellaneous Options */
	[defaultValues setObject:@NO forKey:JSDKeyAllowMacOSTextSubstitutions];
	[defaultValues setObject:@NO forKey:JSDKeyFirstRunComplete];
	[defaultValues setObject:@NO forKey:JSDKeyIgnoreInputEncodingWhenOpening];

	/* Updates */
	// none - handled by Sparkle


	/* Other Defaults */
	[defaultValues setObject:@YES forKey:@"NSPrintHeaderAndFooter"];
	[defaultValues setObject:@"line" forKey:JSDKeyMessagesTableInitialSortKey];


	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


#pragma mark - Initialization and Deallocation and Setup


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (instancetype)init
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		[self setWindowFrameAutosaveName:@"PrefWindow"];

		/*
			We might not load the NIB right away, because this class
			is also acting as our singleton host for preferences, etc.
			Let's create the optionController and set optionsInEffect
			now instead of later.
		 */
		self.optionController = [[OptionPaneController alloc] init];

		self.optionController.isInPreferencesView = YES;

		self.optionsInEffect = [JSDTidyModel loadOptionsInUseListFromResource:@"optionsInEffect" ofType:@"txt"];
	}

	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	dealloc
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:tidyNotifyOptionChanged
												  object:[[self optionController] tidyDocument]];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	awakeFromNib
		  in place of the empty optionPane in the xib.
		- Setup Sparkle vs No-Sparkle.
		- Give the OptionPaneController its optionsInEffect
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)awakeFromNib
{
	[self.optionController putViewIntoView:self.optionPane];


	/* Setup Sparkle versus No-Sparkle versions */

#if INCLUDE_SPARKLE == 0

	NSTabView *theTabView = [[self tabViewUpdates] tabView];
	
	[theTabView removeTabViewItem:[self tabViewUpdates]];
	
#else

	SUUpdater *sharedUpdater = [SUUpdater sharedUpdater];

	[[self buttonAllowUpdateChecks] bind:@"value" toObject:sharedUpdater withKeyPath:@"automaticallyChecksForUpdates" options:nil];

	[[self buttonUpdateInterval] bind:@"enabled" toObject:sharedUpdater withKeyPath:@"automaticallyChecksForUpdates" options:nil];

	[[self buttonUpdateInterval] bind:@"selectedTag" toObject:sharedUpdater withKeyPath:@"updateCheckInterval" options:nil];

	[[self buttonAllowSystemProfile] bind:@"value" toObject:sharedUpdater withKeyPath:@"sendsSystemProfile" options:nil];
	
#endif


	/* Set the option values in the optionController from user defaults. */
	
	[[[self optionController] tidyDocument] takeOptionValuesFromDefaults:[NSUserDefaults standardUserDefaults]];


	/* 
		NSNotifications from `optionController` indicate that one or more Tidy options changed.
		This is what we will use to capture changes and record them into user defaults.
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyOptionChange:)
												 name:tidyNotifyOptionChanged
											   object:[[self optionController] tidyDocument]];
}


#pragma mark - Property Accessors


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionsInEffect
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSArray*)optionsInEffect
{
	return self.optionController.tidyDocument.optionsInUse;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOptionsInEffect
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionsInEffect:(NSArray *)optionsInEffect
{
	self.optionController.tidyDocument.optionsInUse = optionsInEffect;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	countOfTabViews
		Returns the number of tab views in the tab view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSInteger)countOfTabViews
{
	return [[self.tabView tabViewItems] count];
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	indexOfCurrentTabView
		Sets/Gets the index of the current tab view. We use and
		expect standard zero-based indices here.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSInteger)indexOfCurrentTabView
{
	return [self.tabView indexOfTabViewItem:[self.tabView selectedTabViewItem]];
}

- (void) setIndexOfCurrentTabView:(NSInteger)indexOfCurrentTabView
{
	if (indexOfCurrentTabView <= [[self.tabView tabViewItems] count] - 1)
	{
		[self.tabView selectTabViewItemAtIndex:indexOfCurrentTabView];
	}
}


#pragma mark - Events


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleTidyOptionChange:
		We're here because we registered for NSNotification.
		One of the preferences changed in the option pane.
		We're going to record the preference, but we're not
		going to post a notification, because new documents
		will read the preferences themselves.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleTidyOptionChange:(NSNotification *)note
{
	[self.optionController.tidyDocument writeOptionValuesWithDefaults:[NSUserDefaults standardUserDefaults]];
}


@end
