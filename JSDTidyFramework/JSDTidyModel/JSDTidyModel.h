/**************************************************************************************************

	JSDTidyModel

	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

#import "JSDTidyModelDelegate.h"

@class JSDTidyOption;


#pragma mark - class JSDTidyModel


/**
 *  **JSDTidyFramework** provides a wrapper for the [HTML Tidy project][1]’s `tidylib` for
 *  Objective-C and Cocoa. It consists of a fat wrapper geared towards GUI development.
 *
 *  In general once an instance of **JSDTidyModel** is instantiated it's easy to use.
 *
 *  - Set sourceText with untidy data.
 *  - Use tidyOptions to set the tidy options that you want.
 *  - Retrieve the Tidy'd text from tidyText.
 *
 *  In addition there is wide support for GUI applications both in **JSDTidyModel** and
 *  **JSDTidyOption**.
 *
 *  [1]: http://www.html-tidy.org
 *
 *  See also JSDTidyModelDelegate for delegate methods and **NSNotification**s.
 */
@interface JSDTidyModel : NSObject


#pragma mark - Initialization and Deallocation
/** @name Initialization and Deallocation */


/**
 *  Initializes an instance of **JSDTidyModel** with no default data. This method is the designated intializer
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 *  Initializes an instance of **JSDTidyModel** with initial source text.
 *  **JSDTidyModel** assumes that this string is already a satisfactory string with no
 *  encoding issues, and no efforts to decode the string are made.
 *  @param sourceText Initial, untidy'd source text.
 */
- (instancetype)initWithString:(NSString *)sourceText;

/**
 *  Initializes an instance of **JSDTidyModel** with initial source text, and also copies
 *  option values from another specified instance of **JSDTidyModel**.
 *  **JSDTidyModel** assumes that this string is already a satisfactory string with no
 *  encoding issues, and no efforts to decode the string are made.
 *  @param sourceText Initial, untidy'd source text.
 *  @param theModel The **JSDTidyModel** instance from which to copy option values.
 */
- (instancetype)initWithString:(NSString *)sourceText copyOptionValuesFromModel:(JSDTidyModel *)theModel;

/**
 *  Initializes an instance of **JSDTidyModel** with initial source text in an **NSData** instance.
 *  **JSDTidyModel** will use its `input-encoding` option value to decode this file, and
 *  will sanity check the decoded text.
 *
 *  If **JSDTidyModel** thinks that the specified `input-encoding` is not correct, then
 *  `tidyNotifyPossibleInputEncodingProblem` notification will be sent, and the delegate
 *  [JSDTidyModelDelegate tidyModelDetectedInputEncodingIssue:currentEncoding:suggestedEncoding:] will be called.
 *  @param data An NSData instance containing a string of the initial, untidy'd source text.
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *  Initializes an instance of **JSDTidyModel** with initial source text in an **NSData** instance,
 *  and also copies option values from another specified instance of **JSDTidyModel**.
 *  **JSDTidyModel** will use its `input-encoding` option value to decode this file, and
 *  will sanity check the decoded text.
 *
 *  If **JSDTidyModel** thinks that the specified `input-encoding` is not correct, then
 *  `tidyNotifyPossibleInputEncodingProblem` notification will be sent, and the delegate
 *  [JSDTidyModelDelegate tidyModelDetectedInputEncodingIssue:currentEncoding:suggestedEncoding:] will be called.
 *  @param data An **NSData** instance containing a string of the initial, untidy'd source text.
 *  @param theModel The **JSDTidyModel** instance from which to copy option values.
 */
- (instancetype)initWithData:(NSData *)data copyOptionValuesFromModel:(JSDTidyModel *)theModel;

/**
 *  Initializes an instance of **JSDTidyModel** with initial source text from a file.
 *  **JSDTidyModel** will use its `input-encoding` option value to decode this file, and
 *  will sanity check the decoded text.
 *
 *  If **JSDTidyModel** thinks that the specified `input-encoding` is not correct, then
 *  `tidyNotifyPossibleInputEncodingProblem` notification will be sent, and the delegate
 *  [JSDTidyModelDelegate tidyModelDetectedInputEncodingIssue:currentEncoding:suggestedEncoding:] will be called.
 *  @param path The complete path to the file containing the initial, untidy'd source text.
 */
- (instancetype)initWithFile:(NSString *)path;

/**
 *  Initializes an instance of **JSDTidyModel** with initial source text from a file.
 *  **JSDTidyModel** will use its `input-encoding` option value to decode this file, and
 *  will sanity check the decoded text.
 *
 *  If **JSDTidyModel** thinks that the specified `input-encoding` is not correct, then
 *  `tidyNotifyPossibleInputEncodingProblem` notification will be sent, and the delegate
 *  [JSDTidyModelDelegate tidyModelDetectedInputEncodingIssue:currentEncoding:suggestedEncoding:] will be called.
 *  @param path The complete path to the file containing the initial, untidy'd source text.
 *  @param theModel The **JSDTidyModel** instance from which to copy option values.
 */
- (instancetype)initWithFile:(NSString *)path copyOptionValuesFromModel:(JSDTidyModel *)theModel;


#pragma mark - Delegate Support
/** @name Delegate Support */

/**
 *  Assigns the delegate for this instance of **JSDTidyModel**. Refer to JSDTidyModelDelegate to
 *  see what delegate methods (and **NSNotification**s) are used.
 */
@property (nonatomic, weak) id <JSDTidyModelDelegate> delegate;


#pragma mark - String Encoding Support
/** @name String Encoding Support */


/**
 *  A convenience method for accessing this instance's `input-encoding` Tidy option.
 */
@property (nonatomic, assign, readonly) NSStringEncoding inputEncoding;

/**
 *  A convenience method for accessing this instance's `output-encoding` Tidy option.
 */
@property (nonatomic, assign, readonly) NSStringEncoding outputEncoding;


#pragma mark - Text
/** @name Text (the important, good stuff) */


/**
 *  This is the text that Tidy will actually tidy up.
 *  **JSDTidyModel** assumes that this string is already a satisfactory string with no
 *  encoding issues, and no efforts to decode the string are made.
 */
@property (nonatomic, strong) NSString *sourceText;

/**
 *  This sets the text that Tidy will actually tidy up, encapsulated as **NSData**.
 *  **JSDTidyModel** will use its `input-encoding` option value to decode this file, and
 *  will sanity check the decoded text.
 *
 *  If **JSDTidyModel** thinks that the specified `input-encoding` is not correct, then
 *  `tidyNotifyPossibleInputEncodingProblem` notification will be sent, and the delegate
 *  [JSDTidyModelDelegate tidyModelDetectedInputEncodingIssue:currentEncoding:suggestedEncoding:] will be called.
 *  @param data The **NSData** object containing the source text string.
 */
- (void)setSourceTextWithData:(NSData *)data;

/**
 *  This sets the text that Tidy will actually tidy up, loaded from a file.
 *  **JSDTidyModel** will use its `input-encoding` option value to decode this file, and
 *  will sanity check the decoded text.
 *
 *  If **JSDTidyModel** thinks that the specified `input-encoding` is not correct, then
 *  `tidyNotifyPossibleInputEncodingProblem` notification will be sent, and the delegate
 *  [JSDTidyModelDelegate tidyModelDetectedInputEncodingIssue:currentEncoding:suggestedEncoding:] will be called.
 *  @param path Indicates the complete path to the file containing the source text.
 */
- (void)setSourceTextWithFile:(NSString *)path;

/**
 *  The result of the tidying operation.
 */
@property (nonatomic, strong, readonly) NSString *tidyText;

/**
 *  The result of the tidying operation, available as an **NSData** object, using
 *  the instance's current `output-encoding` Tidy option.
 */
@property (nonatomic, strong, readonly) NSData *tidyTextAsData;

/**
 *  Writes the result of the tidying operation to the file system, using
 *  the instance's current `output-encoding` Tidy option.
 *
 *  This method writes using native Cocoa file-writing, and not any file-writing
 *  methods from `libtidy`.
 *  @param path The complete path and filename to write.
 */
- (void)tidyTextToFile:(NSString *)path;

/**
 *  Indicates whether or not sourceText is considered "dirty", meaning that sourceText has changed,
 *  or sourceText is not equal to tidyText.
*/
@property (nonatomic, assign, readonly) BOOL isDirty;


#pragma mark - Messages
/** @name Messages */


@property (nonatomic, strong, readonly) NSString *errorText;      // Return the error text in traditional tidy format.

@property (nonatomic, strong, readonly) NSArray  *errorArray;     // Message text as an array of NSDictionary of the errors.


#pragma mark - Options Overall Management
/** @name Options Overall Management */


+ (void)      optionsBuiltInDumpDocsToConsole;     // Dumps all TidyLib descriptions to error console.

+ (int)       optionsBuiltInOptionCount;           // Returns the number of options built into Tidy.

+ (NSArray *) optionsBuiltInOptionList;            // Returns an NSArray of NSString for all options built into Tidy.

- (void)      optionsCopyValuesFromModel:(JSDTidyModel *)theModel;            // Sets options based on those in theModel.

- (void)      optionsCopyValuesFromDictionary:(NSDictionary *)theDictionary;  // Sets options from values in a dictionary.

- (void)      optionsResetAllToBuiltInDefaults;							      // Resets all options to factory default.

- (NSString *)tidyOptionsConfigFile:(NSString*)baseFileName;                  // Returns a string of current config.

@property (nonatomic, strong) NSArray* optionsInUse;                          // Default is all options; otherwise is list of options.


#pragma mark - Diagnostics and Repair
/** @name Diagnostics and Repair */


@property (nonatomic, assign, readonly) int tidyDetectedHtmlVersion;   // Returns 0, 2, 3, 4, or 5.

@property (nonatomic, assign, readonly) bool tidyDetectedXhtml;        // Indicates whether the document is XHTML.

@property (nonatomic, assign, readonly) bool tidyDetectedGenericXml;   // Indicates if the document is generic XML.

@property (nonatomic, assign, readonly) int tidyStatus;                // Returns 0 if there are no errors, 2 for doc errors, 1 for other.

@property (nonatomic, assign, readonly) uint tidyErrorCount;           // Returns number of document errors.

@property (nonatomic, assign, readonly) uint tidyWarningCount;         // Returns number of document warnings.

@property (nonatomic, assign, readonly) uint tidyAccessWarningCount;   // Returns number of document accessibility warnings.


#pragma mark - Miscelleneous
/** @name Miscelleneous */


@property (nonatomic, assign, readonly) NSString *tidyReleaseDate;     // Returns the TidyLib release date.

@property (nonatomic, assign, readonly) NSString *tidyLibraryVersion;  // Returns the TidyLib semantic version.


#pragma mark - Configuration List Support
/** @name Configuration List Support */


/*
	Loads a list of named potential tidy options from a file, compares
	them to what TidyLib supports, and returns the array containing
	only the names of the supported options.
 */
+ (NSArray *)loadOptionsInUseListFromResource:(NSString *)fileName
									   ofType:(NSString *)fileType;


#pragma mark - Mac OS X Prefs Support
/** @name Mac OS X Prefs Support */


/* Puts *all* TidyLib defaults values into a dictionary. */
+ (void)addDefaultsToDictionary:(NSMutableDictionary *)defaultDictionary;

/* Puts only the TidyLib defaults specified in a resource file into a dictionary. */
+ (void)addDefaultsToDictionary:(NSMutableDictionary *)defaultDictionary
                   fromResource:(NSString *)fileName
                         ofType:(NSString *)fileType;

/* Puts only the TidyLib defaults specified in an array of strings into a dictionary. */
+ (void)addDefaultsToDictionary:(NSMutableDictionary *)defaultDictionary
                      fromArray:(NSArray *)stringArray;

/* Places the current option values into the specified user defaults instance. */
- (void)writeOptionValuesWithDefaults:(NSUserDefaults *)defaults;

/* Takes option values from the specified user defaults instance. */
- (void)takeOptionValuesFromDefaults:(NSUserDefaults *)defaults;

@property (nonatomic, strong) NSUserDefaults *userDefaults;   // The NSUserDefaults instance to get defaults from.


#pragma mark - Tidy Options
/** @name Tidy Options */


@property (nonatomic, strong, readonly) NSDictionary *tidyOptions;

@property (nonatomic, strong, readonly) NSArray *tidyOptionsBindable;

@end

