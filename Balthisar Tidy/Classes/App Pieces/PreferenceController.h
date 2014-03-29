/**************************************************************************************************

	PreferenceController.h
 
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


#import <Cocoa/Cocoa.h>
#import "OptionPaneController.h"


#pragma mark - Some defines


/*
	These convenience definitions for our prefs keys. The
	rest of the prefs keys are generated by JSDTidyModel directly.
 */

/* Application preferences */
#define JSDKeyFirstRunComplete					@"FirstRunComplete"
#define JSDKeyIgnoreInputEncodingWhenOpening	@"IgnoreInputEncodingWhenOpeningFiles"
#define JSDKeySavingPrefStyle					@"SavingPrefStyle"

/* Preferences that apply to all open documents */
#define JSDKeyAllowMacOSTextSubstitutions		@"AllowMacOSTextSubstitutions"
#define JSDKeyOptionsAreGrouped					@"OptionsAreGrouped"
#define JSDKeyOptionsBooleanUseCheckBoxes		@"OptionsBooleanUseCheckBoxes"
#define JSDKeyOptionsShowHumanReadableNames		@"OptionsShowHumanReadableNames"

/* Preferences for new or opening documents */
#define JSDKeyShowLikeFrontDocument				@"ShowLikeFrontDocument"

#define JSDKeyShowNewDocumentDescription		@"ShowNewDocumentDescription"
#define JSDKeyShowNewDocumentLineNumbers		@"ShowNewDocumentLineNumbers"
#define JSDKeyShowNewDocumentMessages			@"ShowNewDocumentMessages"
#define JSDKeyShowNewDocumentTidyOptions		@"ShowNewDocumentTidyOptions"
#define JSDKeyShowNewDocumentSideBySide			@"ShowNewDocumentSideBySide"
#define JSDKeyShowNewDocumentSyncInOut			@"ShoeNewDocumentSyncInOut"


/*
	Note that builds that include Sparkle have Sparkle-related
	preferences keys that are implemented automatically by
	Sparkle. Nothing is defined for them.
 */

/* 
	Note
		#define JSDKeyTidyTidyOptionsKey @"JSDTidyTidyOptions"
	Is defined in JSDTidyModel.h where it appropriately belongs.
 */


/*
	The values for the save type behaviours related to app preferences
*/
typedef enum : NSInteger
{
	kJSDSaveNormal = 0,
	kJSDSaveButWarn = 1,
	kJSDSaveAsOnly = 2
} JSDSaveType;


#pragma mark - class PreferenceController

/**
	The PreferenceController handles the preferences window and its interaction
	with the defaults system and the OptionPaneController.
 
	Because this is a singleton class and also for convenience, it is here where
	we will manage the `optionsInEffect` list.
 */
@interface PreferenceController : NSWindowController


#pragma mark - Properties

/**
	Contains a list of TidyOptions that Balthisar Tidy will use.
 */
@property (readonly, nonatomic, strong) NSArray *optionsInEffect;


#pragma mark - Class Methods


/**
	Singleton accessor for this class.
 */
+ (id)sharedPreferences;


/**
	Registers all of Balthisar Tidy's defaults with Mac OS X' defaults system.
 */
+ (void)registerUserDefaults;


#pragma mark - Preferences Access Support via KVC


/*
	We will manage most of our application options via KVC instead of
	constantly using NSUSerDefaults. Although this PreferenceController
	is intended to control the preferences window, it's a good, one-stop
	shopping experience for accessing preferences on demand, too.
 */

/** Getter for keyed subscripts. */
- (id)objectForKeyedSubscript:(id <NSCopying>)key;


/** Setter for keyed subscripts. */
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;


@end
