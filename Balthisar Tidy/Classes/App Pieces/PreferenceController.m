/**************************************************************************************************

	PreferenceController.m

	part of Balthisar Tidy

	The main preference controller. Here we'll control the following:

		o Handles the application preferences.
		o Implements class methods to be used before instantiation.


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

#import <Cocoa/Cocoa.h>
#import "PreferenceController.h"
#import "JSDTidyDocument.h"


#pragma mark - CATEGORY - Non-Public


@interface PreferenceController ()


#pragma mark - Properties

// File Saving Pane Preferences
@property (nonatomic, weak) IBOutlet NSButton *buttonSaving1;			// "Enable save" button in the nib.
@property (nonatomic, weak) IBOutlet NSButton *buttonSaving2;			// "Disable save" button in the nib.
@property (nonatomic, weak) IBOutlet NSButton *buttonSavingWarn;		// "Warn on save" button in the nib.
@property (nonatomic, weak) IBOutlet NSTextField *savingWarnText;		// Extra text for warn on save button.

// Miscellaneous Pane Preferences
@property (nonatomic, weak) IBOutlet NSButton *buttonShowEncodingHelper;
@property (nonatomic, weak) IBOutlet NSButton *buttonShowNewUserHelper;

// Software Updater Pane Preferences and Objects
@property (nonatomic, weak) IBOutlet NSButton *buttonAllowUpdateChecks;
@property (nonatomic, weak) IBOutlet NSButton *buttonAllowSystemProfile;


// Other Properties
@property (nonatomic, weak) IBOutlet NSView *optionPane;				// The empty pane in the nib that we will inhabit.

@property (nonatomic, strong) OptionPaneController *optionController;	// The real option pane loaded into optionPane.

@property (nonatomic, strong) JSDTidyDocument *tidyProcess;				// The optionController's tidy process.


#pragma mark - Methods

- (IBAction)preferenceChanged:(id)sender;								// Handler for a configuration option change.

@end


#pragma mark - IMPLEMENTATION


@implementation PreferenceController


#pragma mark - Class Methods


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	sharedPreferences
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
	registerUserDefaults
		Register all of the user defaults. Implemented as a CLASS
		method in order to keep this with the preferences controller.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (void)registerUserDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	// Put all of the defaults in the dictionary
	defaultValues[JSDKeySavingPrefStyle] = @(kJSDSaveAsOnly);
	defaultValues[JSDKeyIgnoreInputEncodingWhenOpening] = @NO;
	defaultValues[JSDKeyFirstRunComplete] = @NO;
	
	// Get the defaults from the linked-in TidyLib
	[JSDTidyDocument addDefaultsToDictionary:defaultValues];
	
	// Register the defaults with the defaults system
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


#pragma mark - Initialization and Deallocation and Setup


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)init
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		[self setWindowFrameAutosaveName:@"PrefWindow"];
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
												  object:nil];
	_tidyProcess = nil;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	awakeFromNib
		Create an |OptionPaneController| and put it
		in place of the empty optionPane in the xib.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void) awakeFromNib
{
	if (![self optionController])
	{
		self.optionController = [[OptionPaneController alloc] init];
	}
	
	[[self optionController] putViewIntoView:[self optionPane]];
	
	self.tidyProcess = [[self optionController] tidyDocument];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	windowDidLoad
		Use the defaults to setup the correct preferences settings.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)windowDidLoad
{
	[self setupPreferenceStates];

	
	// Put the Tidy defaults into the |tidyProcess|.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[[self tidyProcess] takeOptionValuesFromDefaults:defaults];
	
	
	// NSNotifications from |optionController| indicate that one or more Tidy options changed.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyOptionChange:)
												 name:tidyNotifyOptionChanged
											   object:[[self optionController] tidyDocument]];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setupPreferenceStates
		Have the preferences items reflect the correct state.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setupPreferenceStates
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// File Saving Preferences Panel
	[[self buttonSaving1] setState:([defaults integerForKey:JSDKeySavingPrefStyle] != kJSDSaveAsOnly)];
	[[self buttonSaving2] setState:([defaults integerForKey:JSDKeySavingPrefStyle] == kJSDSaveAsOnly)];
	[[self buttonSavingWarn] setState:([defaults integerForKey:JSDKeySavingPrefStyle] == kJSDSaveButWarn)];
	[[self buttonSavingWarn] setEnabled:[[self buttonSaving1] state]];
	NSColor *newColor = [[self buttonSaving1] state] ? [NSColor controlTextColor] : [NSColor disabledControlTextColor];
	[[self savingWarnText] setTextColor:newColor];

	// Miscellaneous Preferences Panel
	[[self buttonShowEncodingHelper] setState:![defaults boolForKey:JSDKeyIgnoreInputEncodingWhenOpening]];
	[[self buttonShowNewUserHelper] setState:![defaults boolForKey:JSDKeyFirstRunComplete]];
}


#pragma mark - Events


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	preferenceChanged
		We're here because we're the action for *all* of the non-
		Tidy controls in the preferences window. Overhead is low
		and we want to keep this to a single method.
		Here we're only interested in recording the new preference,
		and then we'll dispatch off to setupPreferenceStates and
		then post the notification.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (IBAction)preferenceChanged:(id)sender
{
	/*
		Buttons saving1 and saving2 aren't in a matrix, and so we
		will deal with their radio button logic directly.
	*/
		
	if ( (sender == [self buttonSaving1]) || (sender == [self buttonSaving2]) || (sender == [self buttonSavingWarn]) )
	{
		JSDSaveType saveType = kJSDSaveButWarn;
		if ( sender == [self buttonSaving2] )
		{
			saveType = kJSDSaveAsOnly;
		}
		else
		{
			// only save1 could have just come high, or saveWarn was activated,
			// meaning that save1 is active anyway.
			saveType = [[self buttonSavingWarn] state] ? kJSDSaveButWarn : kJSDSaveNormal;
		}
		
		[[NSUserDefaults standardUserDefaults] setInteger:saveType forKey:JSDKeySavingPrefStyle];
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:![[self buttonShowEncodingHelper] state] forKey:JSDKeyIgnoreInputEncodingWhenOpening];

	[[NSUserDefaults standardUserDefaults] setBool:![[self buttonShowNewUserHelper] state] forKey:JSDKeyFirstRunComplete];

	[self setupPreferenceStates];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:JSDSavePrefChange object:self];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	handleTidyOptionChange
		We're here because we registered for NSNotification.
		One of the preferences changed in the option pane.
		We're going to record the preference, but we're not
		going to post a notification, because new documents
		will read the preferences themselves.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)handleTidyOptionChange:(NSNotification *)note
{
	[[self tidyProcess] writeOptionValuesWithDefaults:[NSUserDefaults standardUserDefaults]];
}

@end
