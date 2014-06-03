/**************************************************************************************************

	PreferencesDefinitions.h
 
	Application wide keys for top-hierarchy preferences managed by this application.


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

#ifndef Balthisar_Tidy_PreferencesDefinitions_h
#define Balthisar_Tidy_PreferencesDefinitions_h

#pragma mark - User Defaults Keys


	/* Options List Appearance */

	#define JSDKeyOptionsAlternateRowColors       @"OptionsAlternateRowColors"
	#define JSDKeyOptionsAreGrouped               @"OptionsAreGrouped"
	#define JSDKeyOptionsShowHumanReadableNames   @"OptionsShowHumanReadableNames"
	#define JSDKeyOptionsUseHoverEffect           @"OptionsUseHoverEffect"


	/** Document Appearance */

	#define JSDKeyShowNewDocumentLineNumbers      @"ShowNewDocumentLineNumbers"
	#define JSDKeyShowNewDocumentMessages         @"ShowNewDocumentMessages"
	#define JSDKeyShowNewDocumentTidyOptions      @"ShowNewDocumentTidyOptions"
	#define JSDKeyShowNewDocumentSideBySide       @"ShowNewDocumentSideBySide"
	#define JSDKeyShowNewDocumentSyncInOut        @"ShoeNewDocumentSyncInOut"


	/* File Saving Options */

	#define JSDKeySavingPrefStyle                 @"SavingPrefStyle"


	/* Miscellaneous Options */

	#define JSDKeyAllowMacOSTextSubstitutions     @"AllowMacOSTextSubstitutions"
	#define JSDKeyFirstRunComplete                @"FirstRunComplete"
	#define JSDKeyIgnoreInputEncodingWhenOpening  @"IgnoreInputEncodingWhenOpeningFiles"


	/* Application preferences */

	#define JSDKeyMessagesTableInitialSortKey     @"MessagesTableInitialSortKey"
	#define JSDKeyMessagesTableSortDescriptors    @"MessagesTableSortDescriptors"


	/* Other */


	/* Key under which to store TidyOptions */

	#ifdef JSDKeyTidyTidyOptionsKey
		#undef JSDKeyTidyTidyOptionsKey
		#define JSDKeyTidyTidyOptionsKey          @"JSDTidyTidyOptions"
	#endif


	/*
		Note that builds that include Sparkle have Sparkle-related
		preferences keys that are implemented automatically by
		Sparkle. Nothing is defined for them.
	 */


#pragma mark - Other Definitions

	/* The values for the save type behaviours related to app preferences. */
	typedef enum : NSInteger
	{
		kJSDSaveNormal = 0,
		kJSDSaveButWarn = 1,
		kJSDSaveAsOnly = 2
	} JSDSaveType;


#endif
