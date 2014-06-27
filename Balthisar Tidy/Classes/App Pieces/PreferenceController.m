/**************************************************************************************************

	PreferenceController

	The main preference controller. Here we'll control the following:

	- Handles the application preferences.
	- Implements class methods to be used before instantiation.


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

#ifdef FEATURE_SPARKLE
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
	[defaultValues setObject:@NO  forKey:JSDKeyShowNewDocumentSideBySide];
	[defaultValues setObject:@YES forKey:JSDKeyShowNewDocumentSyncInOut];

	/* File Saving Options */
	[defaultValues setObject:@(kJSDSaveAsOnly) forKey:JSDKeySavingPrefStyle];

	/* Miscellaneous Options */
	[defaultValues setObject:@NO forKey:JSDKeyAllowMacOSTextSubstitutions];
	[defaultValues setObject:@NO forKey:JSDKeyFirstRunComplete];
	[defaultValues setObject:@NO forKey:JSDKeyIgnoreInputEncodingWhenOpening];

	/* Updates */
	// none - handled by Sparkle

	/* Sort Descriptor Defaults */
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"locationString" ascending:YES];
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:@[descriptor]]
					  forKey:JSDKeyMessagesTableSortDescriptors];

	/* Other Defaults */
	[defaultValues setObject:@NO  forKey:@"NSPrintHeaderAndFooter"];


	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionsInEffect (class)
		Because JSDTidyModel pretty successfully integrates with the
		native TidyLib without having to hardcode everything, it
		will use *all* tidy options if we let it. We don't want
		to use every tidy option, though, so here we will provide
		an array of tidy options that we will support.
 
		Note that this replaces the old `optionsInEffect.txt` file
		that was previously used for this purpose.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray*)optionsInEffect
{
	/*
		Note that EVERY tidy option available (as of the current
		linked in version) is listed below; we're excluding the
		ones we don't want simply by commenting them out.
	 */

	return @[
			 @"add-xml-decl",
			 @"add-xml-space",
			 @"accessibility-check",
			 @"alt-text",
			 @"anchor-as-name",
			 @"ascii-chars",
			 @"assume-xml-procins",
			 @"bare",
			 @"break-before-br",
			 //@"char-encoding",                // Balthisar Tidy handles this directly
			 @"clean",
			 @"coerce-endtags",
			 @"css-prefix",
			 @"decorate-inferred-ul",
			 @"doctype",
			 //@"doctype-mode",                 // Read-only; should use `doctype`.
			 @"drop-empty-elements",
			 @"drop-empty-paras",
			 @"drop-font-tags",
			 @"drop-proprietary-attributes",
			 @"enclose-block-text",
			 @"enclose-text",
			 //@"error-file",                   // Balthisar Tidy handles this directly.
			 @"escape-cdata",
			 @"fix-backslash",
			 @"fix-bad-comments",
			 @"fix-uri",
			 @"force-output",
			 @"gdoc",
			 //@"gnu-emacs".                    // Balthisar Tidy handles this directly.
			 //@"gnu-emacs-file",               // Balthisar Tidy handles this directly.
			 @"hide-comments",
			 //@"hide-endtags",                 // Is a dupe of `omit-optional-tags`
			 @"indent",
			 @"indent-attributes",
			 @"indent-cdata",
			 @"indent-spaces",
			 @"input-encoding",
			 @"input-xml",
			 @"join-classes",
			 @"join-styles",
			 //@"keep-time",                    // Balthisar Tidy handles this directly.
			 //@"language",                     // Not currently used; Mac OS X supports localization natively.
			 @"literal-attributes",
			 @"logical-emphasis",
			 @"lower-literals",
			 @"markup",
			 @"merge-divs",
			 @"merge-emphasis",
			 @"merge-spans",
			 @"ncr",
			 @"new-blocklevel-tags",
			 @"new-empty-tags",
			 @"new-inline-tags",
			 @"new-pre-tags",
			 @"newline",
			 @"numeric-entities",
			 @"omit-optional-tags",
			 //@"output-bom",                   // Balthisar Tidy handles this directly.
			 @"output-encoding",
			 //@"output-file",                  // Balthisar Tidy handles this directly.
			 @"output-html",
			 @"output-xhtml",
			 @"output-xml",
			 @"preserve-entities",
			 @"punctuation-wrap",
			 //@"quiet",                        // Balthisar Tidy handles this directly.
			 @"quote-ampersand",
			 @"quote-marks",
			 @"quote-nbsp",
			 @"repeated-attributes",
			 @"replace-color",
			 @"show-body-only",
			 //@"show-error",                   // Balthisar Tidy handles this directly.
			 //@"show-info",                    // Balthisar Tidy handles this directly.
			 //@"show-warnings",                // Balthisar Tidy handles this directly.
			 //@"slide-style",                  // marked as `obsolete` in TidyLib source code.
			 @"sort-attributes",
			 //@"split",                        // marked as `obsolete` in TidyLib source code.
			 @"tab-size",
			 @"uppercase-attributes",
			 @"uppercase-tags",
			 @"vertical-space",
			 @"word-2000",
			 @"wrap",
			 @"wrap-asp",
			 @"wrap-attributes",
			 @"wrap-jste",
			 @"wrap-php",
			 @"wrap-script-literals",
			 @"wrap-sections",
			 @"tidy-mark",
			 //@"write-back",                   // Balthisar Tidy handles this directly.
			 ];
}


#pragma mark - Initialization and Deallocation and Setup


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (instancetype)init
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		// Nothing to see here!
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

	/* Create and setup the option controller. */

	self.optionController = [[OptionPaneController alloc] init];

	self.optionController.isInPreferencesView = YES;

	[self.optionPane addSubview:self.optionController.view];

	self.optionController.optionsInEffect = [[self class] optionsInEffect];

	
	/* Setup Sparkle versus No-Sparkle versions */

#ifdef FEATURE_SPARKLE

	SUUpdater *sharedUpdater = [SUUpdater sharedUpdater];

	[[self buttonAllowUpdateChecks] bind:@"value" toObject:sharedUpdater withKeyPath:@"automaticallyChecksForUpdates" options:nil];

	[[self buttonUpdateInterval] bind:@"enabled" toObject:sharedUpdater withKeyPath:@"automaticallyChecksForUpdates" options:nil];

	[[self buttonUpdateInterval] bind:@"selectedTag" toObject:sharedUpdater withKeyPath:@"updateCheckInterval" options:nil];

	[[self buttonAllowSystemProfile] bind:@"value" toObject:sharedUpdater withKeyPath:@"sendsSystemProfile" options:nil];

#else

	NSTabView *theTabView = [[self tabViewUpdates] tabView];

	[theTabView removeTabViewItem:[self tabViewUpdates]];

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
