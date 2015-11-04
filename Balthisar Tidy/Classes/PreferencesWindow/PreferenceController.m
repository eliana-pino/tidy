/**************************************************************************************************

	PreferenceController
 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

#import "PreferenceController.h"
#import "CommonHeaders.h"

#import "JSDTidyModel.h"

#import "DocumentAppearanceViewController.h"
#import "OptionListAppearanceViewController.h"
#import "OptionListViewController.h"
#import "MiscOptionsViewController.h"
#import "SavingOptionsViewController.h"
#import "UpdaterOptionsViewController.h"


#pragma mark - IMPLEMENTATION


@implementation PreferenceController
{
	NSUserDefaults *_mirroredDefaults;
}


#pragma mark - Class Methods


#pragma mark - Initialization and Deallocation and Setup


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
  - init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (instancetype)init
{
	NSViewController *optionListViewController = [[OptionListViewController alloc] init];
	NSViewController *optionListAppearanceViewController = [[OptionListAppearanceViewController alloc] init];
	NSViewController *documentAppearanceViewController = [[DocumentAppearanceViewController alloc] init];
	NSViewController *savingOptionsViewController = [[SavingOptionsViewController alloc] init];
	NSViewController *miscOptionsViewController = [[MiscOptionsViewController alloc] init];

#if defined(FEATURE_SPARKLE) || defined(FEATURE_FAKE_SPARKLE)

	NSViewController *updaterOptionsViewController = [[UpdaterOptionsViewController alloc] init];

	NSArray *controllers = @[optionListViewController,
							 optionListAppearanceViewController,
							 documentAppearanceViewController,
							 savingOptionsViewController,
							 miscOptionsViewController,
							 updaterOptionsViewController];
#else
	NSArray *controllers = @[optionListViewController,
							 optionListAppearanceViewController,
							 documentAppearanceViewController,
							 savingOptionsViewController,
							 miscOptionsViewController];
#endif

    self = [super initWithViewControllers:controllers];

    /* Handle Preferences Mirroring -- @NOTE: only on OS X 10.9 and above. */
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber10_9)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUserDefaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:[NSUserDefaults standardUserDefaults]];
        
        _mirroredDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_PREFS];
    }


	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
  + sharedPreferences
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
  + optionsInEffect
    Because JSDTidyModel pretty successfully integrates with the
    native `libtidy` without having to hardcode everything, it
    will use *all* tidy options if we let it. We don't want
    to use every tidy option, though, so here we will provide
    an array of tidy options that we will support.
   @TODO Check current 5.0.0+ libtidy for added selectors. We can
    check the library version. In general, now that we support the
    use of /usr/local/lib, we should have a general version check
    to ensure a certain minimum version is used.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray*)optionsInEffect
{
	/*
		To better support new libtidy versions, we're going to
		start blacklist options instead of the previous approach
		of whitelisting.
	 */
	
	NSMutableArray *allOptions = [NSMutableArray arrayWithArray:[JSDTidyModel optionsBuiltInOptionList]];
	
	NSArray *blacklist = @[
						   @"char-encoding",                // Balthisar Tidy handles this directly
						   @"doctype-mode",                 // Read-only; should use `doctype`.
						   @"drop-font-tags",               // marked as `obsolete` in TidyLib source code.
						   @"error-file",                   // Balthisar Tidy handles this directly.
						   @"gnu-emacs",                    // Balthisar Tidy handles this directly.
						   @"gnu-emacs-file",               // Balthisar Tidy handles this directly.
						   @"hide-endtags",                 // Is a dupe of `omit-optional-tags`
						   //@"indent-with-tabs",             // @TODO: new, will support, must test.
						   @"keep-time",                    // Balthisar Tidy handles this directly.
						   @"language",                     // Not currently used; Mac OS X supports localization natively.
						   @"output-bom",                   // Balthisar Tidy handles this directly.
						   @"output-file",                  // Balthisar Tidy handles this directly.
						   @"quiet",                        // Balthisar Tidy handles this directly.
						   @"show-errors",                   // Balthisar Tidy handles this directly.
						   @"show-info",                    // Balthisar Tidy handles this directly.
						   @"show-warnings",                // Balthisar Tidy handles this directly.
						   @"skip-quotes",                  // @TODO NOT IMPLEMENTED YES - need update Tidy
						   @"skip-nested",                  // @TODO Possible future name of skip-quotes.
						   @"slide-style",                  // marked as `obsolete` in TidyLib source code.
						   @"split",                        // marked as `obsolete` in TidyLib source code.
						   @"write-back",                   // Balthisar Tidy handles this directly.
			 ];
	
	[allOptions removeObjectsInArray:blacklist];
	
	return allOptions;
}


#pragma mark - Instance Methods


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
  - registerUserDefaults
    Register all of the user defaults. Implemented as a CLASS
    method in order to keep this with the preferences controller.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)registerUserDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	/* Tidy Options */
	[JSDTidyModel addDefaultsToDictionary:defaultValues];

	/** Options List Appearance */
	[defaultValues setObject:@YES forKey:JSDKeyOptionsAlternateRowColors];
	[defaultValues setObject:@YES forKey:JSDKeyOptionsAreGrouped];
	[defaultValues setObject:@YES forKey:JSDKeyOptionsShowDescription];
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

	/* Advanced Options */
	[defaultValues setObject:@NO forKey:JSDKeyAllowMacOSTextSubstitutions];
	[defaultValues setObject:@NO forKey:JSDKeyFirstRunComplete];
	[defaultValues setObject:@NO forKey:JSDKeyIgnoreInputEncodingWhenOpening];
	[defaultValues setObject:@NO forKey:JSDKeyAllowServiceHelperTSR];
	[defaultValues setObject:@NO forKey:JSDKeyAlreadyAskedServiceHelperTSR];

	/* Updates */
	// none - handled by Sparkle

	/* Sort Descriptor Defaults */
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"locationString" ascending:YES];
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:@[descriptor]]
					  forKey:JSDKeyMessagesTableSortDescriptors];

	/* Other Defaults */
	[defaultValues setObject:@NO  forKey:@"NSPrintHeaderAndFooter"];

	/* Perform the registration. */
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
  - handleUserDefaultsChanged:
    Support App Groups so that our Service app and Action extensions
    have access to Balthisar Tidy's preferences. The strategy is to
    mirror standardUserDefaults to the App Group defaults, uni-
    directionally only. The user interface uses several instances
    of NSUserDefaultsController which cannot be tied to anything
    other than standardUserDefaults. Rather than subclass it and
    change all of Balthisar Tidy's source code to use a different
    defaults domain, we will use the same defaults as always but
    copy them out to the shared domain as needed.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleUserDefaultsChanged:(NSNotification*)note
{
	NSDictionary *localDict = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:JSDKeyTidyTidyOptionsKey];
	[_mirroredDefaults setObject:localDict forKey:JSDKeyTidyTidyOptionsKey];
	[_mirroredDefaults synchronize];
}

@end
