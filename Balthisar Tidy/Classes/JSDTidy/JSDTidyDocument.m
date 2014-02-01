/**************************************************************************************************

	JSDTidyDocument.m

	A Cocoa wrapper for tidylib.


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

#import "JSDTidyDocument.h"
#import "buffio.h"
#import "config.h"


#pragma mark - Non-Public iVars, Properties, and Method declarations

@interface JSDTidyDocument ()
{
@private
	
	__strong NSDictionary* tidyOptionsThatCannotAcceptNULLSTR;
	
	__strong NSMutableArray* _errorArray;						// This backing iVar must be NSMutableArray
}

@property TidyDoc prefDoc;										// |TidyDocument| instance for HOLDING PREFERENCES and nothing more.

@property (nonatomic, assign) NSStringEncoding inputEncoding;	// User-specified input-encoding. OVERRIDE TidyLib.

@property (nonatomic, assign) NSStringEncoding outputEncoding;	// User-specified output-encoding. OVERRIDE TidyLib.

@property (nonatomic, strong) NSData *originalData;				// The original data that the file was loaded from.


@end


@implementation JSDTidyDocument


#pragma mark - Standard C Functions

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tidyCallbackFilter (regular C-function)
		In order to support TidyLib's callback function for
		building an error list on the fly, we need to set up this
		standard C function to handle the callback.

		|tidyGetAppData| result will already contain a reference to
		|self| that we set via |tidySetAppData| during processing.
		Essentially we're calling
		[self errorFilter:Level:Line:Column:Message]
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
BOOL tidyCallbackFilter ( TidyDoc tdoc, TidyReportLevel lvl, uint line, uint col, ctmbstr mssg )
{
	return [(__bridge JSDTidyDocument*)tidyGetAppData(tdoc) errorFilter:tdoc Level:lvl Line:line Column:col Message:mssg];
}


#pragma mark - iVar Synthesis


@synthesize originalText = _originalText;
@synthesize originalData = _originalData;
@synthesize workingText = _workingText;
@synthesize tidyText = _tidyText;
@synthesize errorText = _errorText;


#pragma mark - INITIALIZATION and DESTRUCTION


// #TODO - Notes
// Remember this is self contained. Outside forces will set options. When someone sets
// my options, I should fire a Notification.
// Notifications:
// 	originaltext changed (control it to prevent endless loops!)
//	option changed (can send which option?)
//	tidy text changed
//	input-encoding changed
// OR consider key-value observing.


// #TODO: should provide an init withOptionsCopiedFrom:JSDTidyDocument.
/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)init
{
	if (self = [super init]) {
		_originalData = nil;
		_originalText = @"";
		_workingText = @"";
		_tidyText = @"";
		_errorText = @"";
		_errorArray = [[NSMutableArray alloc] init];
		_prefDoc = tidyCreate();
		_inputEncoding = tidyDefaultInputEncoding;
		_outputEncoding = tidyDefaultOutputEncoding;
		
		// TODO: we'll replace this travesty with a unified, in-code
		// exception handling process in next version. This will simply
		// make sure we're not logging errors for this re-release.
		tidyOptionsThatCannotAcceptNULLSTR = [@{	@"doctype"     : @NO,
													@"slide-style" : @NO,
													@"language"    : @NO,
													@"css-prefix"  : @NO } retain];
	}
	
	//[[self class] optionDumpDocsToConsole];
	//NSLog(@"%@", [[self class] availableEncodingDictionariesByLocalizedIndex]);
	//NSLog(@"%@", [[self class] availableEncodingDictionariesByNSStringEncoding]);
	
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	dealloc
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)dealloc
{
	[_originalData release];
	[_originalText release];
	[_workingText release];
	[_tidyText release];
	[_errorText release];
	[_errorArray release];
	tidyRelease(_prefDoc);
	[super dealloc];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithString
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithString:(NSString *)value
{
	self = [self init];
	if (self)
	{
		[self setOriginalText:value];
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithFile
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithFile:(NSString *)path
{
	self = [self init];
	if (self)
	{
		[self setOriginalTextWithFile:path];
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithData
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithData:(NSData *)data
{
	self = [self init];
	if (self)
	{
		[self setOriginalTextWithData:data];
	}
	return self;
}


#pragma mark - String Encoding Support


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	allAvailableEncodingLocalizedNames
		Returns an array of NSString of all available encoding names
		(localized) in local alphabetical order.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray *)allAvailableEncodingLocalizedNames
{
	
	// #TODO: can I make this a class static ivar?
	static NSMutableArray *encodingNames = nil; // Only do this once
	
	if (!encodingNames)
	{
		NSMutableArray *tempNames = [[[NSMutableArray alloc] init] autorelease];
		
		const NSStringEncoding *encoding = [NSString availableStringEncodings];
		
		while (*encoding)
		{
			[tempNames addObject:[NSString localizedNameOfStringEncoding:*encoding]];
			encoding++;
		}
		
		encodingNames = (NSMutableArray*)[[tempNames sortedArrayUsingComparator:^(NSString *a, NSString *b) { return [a localizedCaseInsensitiveCompare:b]; }] retain];
	}
	return encodingNames;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	availableEncodingDictionariesByLocalizedName
		Can retrieve `NSStringEncoding` or `LocalizedIndex`.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSDictionary *)availableEncodingDictionariesByLocalizedName
{
	static NSMutableDictionary *dictionary = nil; // Only do this once
	
	if (!dictionary)
	{
		
		if (!dictionary)
		{
			dictionary = [[NSMutableDictionary alloc] init];
			
			const NSStringEncoding *encoding = [NSString availableStringEncodings];
			
			while (*encoding)
			{
				NSDictionary *items = @{@"LocalizedName" : [NSString localizedNameOfStringEncoding:*encoding],
									    @"NSStringEncoding" : [NSNumber numberWithUnsignedLong:*encoding],
									    @"LocalizedIndex" : @([[[self class] allAvailableEncodingLocalizedNames]
															   indexOfObject:[NSString localizedNameOfStringEncoding:*encoding]])};
				
				[dictionary setObject:items forKey:[NSString localizedNameOfStringEncoding:*encoding]];

				encoding++;
			}
		}
	}
	return dictionary;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	availableEncodingDictionariesByNSStringEncoding
		Can retrieve `LocalizedName` and `LocalizedIndex`.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSDictionary *)availableEncodingDictionariesByNSStringEncoding
{
	static NSMutableDictionary *dictionary = nil; // Only do this once
	
	if (!dictionary)
	{
		
		if (!dictionary)
		{
			dictionary = [[NSMutableDictionary alloc] init];
			
			const NSStringEncoding *encoding = [NSString availableStringEncodings];
			
			while (*encoding)
			{
				NSDictionary *items = @{@"LocalizedName" : [NSString localizedNameOfStringEncoding:*encoding],
									    @"NSStringEncoding" : [NSNumber numberWithUnsignedLong:*encoding],
									    @"LocalizedIndex" : @([[[self class] allAvailableEncodingLocalizedNames]
															   indexOfObject:[NSString localizedNameOfStringEncoding:*encoding]])};
				
				[dictionary setObject:items forKey:[NSNumber numberWithUnsignedLong:*encoding]];
				
				encoding++;
			}
		}
	}
	return dictionary;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	availableEncodingDictionariesByLocalizedIndex
		Can retrieve `LocalizedName` and `NSStringEncoding`.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSDictionary *)availableEncodingDictionariesByLocalizedIndex
{
	static NSMutableDictionary *dictionary = nil; // Only do this once
	
	if (!dictionary)
	{
		
		if (!dictionary)
		{
			dictionary = [[NSMutableDictionary alloc] init];
			
			const NSStringEncoding *encoding = [NSString availableStringEncodings];
			
			while (*encoding)
			{
				NSDictionary *items = @{@"LocalizedName" : [NSString localizedNameOfStringEncoding:*encoding],
									    @"NSStringEncoding" : [NSNumber numberWithUnsignedLong:*encoding],
									    @"LocalizedIndex" : @([[[self class] allAvailableEncodingLocalizedNames]
																indexOfObject:[NSString localizedNameOfStringEncoding:*encoding]])};
				
				[dictionary setObject:items forKey:@([[[self class] allAvailableEncodingLocalizedNames]
													  indexOfObject:[NSString localizedNameOfStringEncoding:*encoding]])];
				
				encoding++;
			}
		}
	}
	return dictionary;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	fixSourceCoding
		Repairs the character decoding whenever the `input-coding`
		has changed. It should only work on "clean" documents. If
		the user has started typing, then the document is dirty
		and there should be no effect.
 
		We will compare _originalText and _workingText. Only if
		they are the same will be try to reset from _originalData
		using the new encoding.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)fixSourceCoding
{
	// First test _originalText and _workingText to ensure equality.
	if (_originalData && [self areEqualOriginalWorking])
	{
		[self setOriginalTextWithData:_originalData];
	}
}


#pragma mark -
#pragma mark TEXT - the important, good stuff.


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	processTidy - regard as PRIVATE
		Performs tidy'ing and sets _tidyText and _errorText
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)processTidy
{
	// Use a FRESH TidyDocument each time to cover up some issues with library code
	TidyDoc newTidy = tidyCreate();			// This is the TidyDoc we will really process. Eventually will be |_prefDoc|.
	tidyOptCopyConfig( newTidy, _prefDoc );	// Put our options into the working copy |newTidy|.

	// Setup the |outBuffer| to copy to an NSString instead of writing to stdout
	TidyBuffer *outBuffer = malloc(sizeof(TidyBuffer));
	tidyBufInit( outBuffer );

	// Setup the error buffer to catch errors here instead of stdout
	tidySetAppData( newTidy, self );										// So we can send a message from outside self to self.
	tidySetReportFilter( newTidy, (TidyReportFilter)&tidyCallbackFilter);	// The callback will go to this out-of-class C function.
	[_errorArray removeAllObjects];											// Clear out all of the previous errors.
	TidyBuffer *errBuffer = malloc(sizeof(TidyBuffer));						// Allocate a buffer for our error text.
	tidyBufInit( errBuffer );												// Init the buffer.
	tidySetErrorBuffer( newTidy, errBuffer );								// And let tidy know to use it.

	// Parse the |_workingText| and clean, repair, and diagnose it.
	tidyOptSetValue( newTidy, TidyCharEncoding, [@"utf8" UTF8String] );		// Set all internal char-encoding to UTF8.
	tidyOptSetValue( newTidy, TidyInCharEncoding, [@"utf8" UTF8String] );	// Set all internal char-encoding to UTF8.
	tidyOptSetValue( newTidy, TidyOutCharEncoding, [@"utf8" UTF8String] );	// Set all internal char-encoding to UTF8.
	tidyParseString(newTidy, [_workingText UTF8String]);
	tidyCleanAndRepair( newTidy );
	tidyRunDiagnostics( newTidy );

	// Save the tidy'd text to an NSString
	tidySaveBuffer( newTidy, outBuffer );									// Save it to the buffer we set up above.
	[_tidyText release];
	if (outBuffer->size > 0)
	{
		// Cast the buffer to an NSData that we can use to set the NSString.
		_tidyText = [[NSString alloc] initWithUTF8String:(char *)outBuffer->bp];
	}
	else {
		_tidyText = @"";
	}
	[_tidyText retain];

	// Give the Tidy general info at the bottom.
	// TODO: what do these do??? Where do they output?
	tidyErrorSummary( newTidy );
	tidyGeneralInfo( newTidy );

	// Copy the error buffer into an NSString -- the |_errorArray| is built using
	// callbacks so we don't need to do anything at all to build it right here.
	[_errorText release];
	if (errBuffer->size > 0)
	{
		_errorText = [[NSString alloc] initWithUTF8String:(char *)errBuffer->bp];
	}
	else
	{
		_errorText = @"";
	}
	[_errorText retain];

	tidyBufFree(outBuffer);
	tidyBufFree(errBuffer);

	// |_prefDoc| has "good" preferences, not corrupted by tidy's processing.
	// But we want to keep |newTidy| to expose it to the using application.
	// So, we'll assign |newTidy| as |_prefDoc| after putting |_prefDoc|'s
	/// preferences into |newTidy|.
	tidyOptCopyConfig( newTidy, _prefDoc );	// Save our uncorrupted preferences.
	tidyRelease(_prefDoc);					// Kill the old |_prefDoc|.
	_prefDoc = newTidy;						// Now |_prefDoc| is the just-tidy'd document.
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentTidyTextChanged" object:self];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	originalText
		Read the original text as an NSString.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString *)originalText
{
	return _originalText;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOriginalText
		Set the original & working text from an NSString.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOriginalText:(NSString *)value
{
	[value retain];
	[_originalText release];
	_originalText = value;
	[self setWorkingText:_originalText];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOriginalTextChanged" object:self];

}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOriginalTextWithData
		Set the original & working text from an NSData. Use the
		current user-specified setting for input-encoding to decode.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOriginalTextWithData:(NSData *)data
{
	[_originalText release];

	if (data != _originalData)
	{
		//[data retain];
		[_originalData release];
		//_originalData = data;
		//[[[self originalData] initWithData:data] retain];
		_originalData = [[[NSData alloc] initWithData:data] retain];
	}

	NSString *testText = nil;
	if ((testText = [[NSString alloc] initWithData:data encoding:_inputEncoding] ))
	{
		_originalText = testText;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOriginalTextChanged" object:self];
	}
	else
	{
		_originalText = @"";
		[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOriginalTextChanged" object:self];
	}

	[_originalText retain];
	[self setWorkingText:_originalText];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOriginalTextWithFile
		Set the original & working text from a file.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOriginalTextWithFile:(NSString *)path
{
	[_originalText release];

	NSString *testText = nil;
	if ((testText = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:_inputEncoding]))
	{
		_originalText = testText;
	}
	else
	{
		_originalText = @"";
	}

	[_originalText retain];
	[self setWorkingText:_originalText];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	workingText
		Read the original text as an NSString.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString *)workingText
{
	return _workingText;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setWorkingText
		set the working text from an NSString.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setWorkingText:(NSString *)value
{
	[value retain];
	[_workingText release];
	_workingText = value;
	[self processTidy];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setWorkingTextWithData
		Set the working text from an NSData.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setWorkingTextWithData:(NSData *)data
{
	[_workingText release];

	NSString *testText = nil;
	if ((testText = [[NSString alloc] initWithData:data encoding:_inputEncoding]))
	{
		_workingText = testText;
	}
	else
	{
		_workingText = @"";
	}

	[_workingText retain];
	[self processTidy];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setWorkingTextWithFile
		set the working text from a file.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setWorkingTextWithFile:(NSString *)path
{
	[_workingText release];
	_workingText = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:_inputEncoding];
	[_workingText retain];
	[self processTidy];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tidyText
		Return the tidy'd text.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString *)tidyText
{
	return _tidyText;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tidyTextAsData
		Return the tidy'd text in the output-encoding format.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSData *)tidyTextAsData
{
	return [_tidyText dataUsingEncoding:_outputEncoding];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tidyTextToFile
		Write the tidy'd text to a file in the current format.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)tidyTextToFile:(NSString *)path
{
	[[_tidyText dataUsingEncoding:_outputEncoding] writeToFile:path atomically:YES];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	errorText
		Read the error text.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString *)errorText
{
	return _errorText;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	errorArray
		Read the error array.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSArray *)errorArray
{
	return (NSArray *)_errorArray;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	areEqualOriginalWorking
		Are the original and working text identical?
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (bool)areEqualOriginalWorking
{
	return [_originalText isEqualToString:_workingText];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	areEqualWorkingTidy
		Are the working and tidy text identical?
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (bool)areEqualWorkingTidy
{
	return [_workingText isEqualToString:_tidyText];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	areEqualOriginalTidy
		Are the orginal and tidy text identic
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (bool)areEqualOriginalTidy
{
	return [_originalText isEqualToString:_tidyText];
}


#pragma mark -
#pragma mark OPTIONS - methods for dealing with options


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	isTidyEncodingOption
		Convenience method just to decide if an optionId is a
		Tidy encoding option.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (bool)isTidyEncodingOption:(TidyOptionId)opt
{
	return ( (opt == TidyCharEncoding) || (opt == TidyInCharEncoding) || (opt == TidyOutCharEncoding) );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionGetOptionInstance -- regard as PRIVATE
		Given an option id, return an instance of a tidy option. This
		is defined because inexplicably some of the TidyLib functions
		require a "real" option in order to return data.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (TidyOption)optionGetOptionInstance:(TidyOptionId)idf
{
	TidyDoc dummyDoc = tidyCreate();					// Create a dummy document.
	TidyOption result = tidyGetOption( dummyDoc, idf);	// Get an instance of an option.
	tidyRelease(dummyDoc);								// Release the document.
	return result;										// Return the instance of the option.
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionGetList
		Returns NSArray of NSString for all options built into Tidy.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray *)optionGetList
{
	static NSMutableArray *theArray = nil;							// Just do this once.
	
	if (!theArray) 
	{
		theArray = [[NSMutableArray alloc] init];					// Create an array.
		
		TidyDoc dummyDoc = tidyCreate();							// Create a dummy document (we're a CLASS method).
		
		TidyIterator i = tidyGetOptionList( dummyDoc );				// Set up an iterator.
		
		while ( i )
		{
			TidyOption topt = tidyGetNextOption( dummyDoc, &i );	// Get an option.
			
			[theArray addObject:@(tidyOptGetName( topt ))];			// Add the name to the array
		}
		tidyRelease(dummyDoc);										// Release the dummy document.
	}
	return theArray;												// Return the array of results.
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionCount
		Returns the number of Tidy options that exist.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (int)optionCount
{
	return N_TIDY_OPTIONS;	// defined in config.c of TidyLib
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionDocForId:
		TidyLib's built-in definition for |idf|.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSString *) optionDocForId:(TidyOptionId)idf;
{
	TidyDoc dummyDoc = tidyCreate();				// Create a dummy document (we're a CLASS method).
	
	NSString* tidyResultString;
	const char* tidyResultCString = tidyOptGetDoc(dummyDoc, tidyGetOption(dummyDoc, idf));
	
	if (!tidyResultCString)
	{
		tidyResultString = @"No description provided by TidyLib.";
	}
	else
	{
		tidyResultString = [NSString stringWithUTF8String:tidyResultCString];
	}
	
	tidyRelease(dummyDoc);
	
	return tidyResultString;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionDumpDocsToConsole
		Dump all TidyLib descriptions to error console. This is a
		cheap way to get the descriptions for Localizable.strings.
		This will produce a fairly nice, formatted list of strings
		that you might use directly. Double-check quotes, etc.,
		before building. There are probably a couple of entities
		that are missed.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (void) optionDumpDocsToConsole
{
	NSArray* optionList = [[[self class] optionGetList] retain];
	NSString* paddedOptionName;
	NSString* filteredDescription;
	NSAttributedString* convertingString;
	
	NSLog(@"%@", @"----START----");
	
	for (NSString* optionName in optionList)
	{
		paddedOptionName = [[NSString stringWithFormat:@"\"%@\"", optionName] stringByPaddingToLength:40 withString:@" " startingAtIndex:0];
		
		filteredDescription = [[[self class] optionDocForId:[[self class] optionIdForName:optionName]] stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];

		filteredDescription = [filteredDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@"\\n"];
		
		convertingString = [[[NSAttributedString alloc] initWithHTML:[filteredDescription dataUsingEncoding:NSUnicodeStringEncoding] documentAttributes:nil] autorelease];
		
		filteredDescription = [convertingString string];
		
		NSLog(@"%@= \"%@: %@\";", paddedOptionName, optionName, filteredDescription);
	}
	
	NSLog(@"%@", @"----STOP----");

	[optionList release];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIdForName
		Returns the TidyOptionId for the given option name.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (TidyOptionId)optionIdForName:(NSString *)name
{
	TidyOptionId optID = tidyOptGetIdForName( [name UTF8String] );
	if (optID < N_TIDY_OPTIONS) {
		return optID;
	}
	return TidyUnknownOption;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionNameForId
		Returns the name for the given TidyOptionId.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSString *)optionNameForId:(TidyOptionId)idf
{
	return @(tidyOptGetName( [self optionGetOptionInstance:idf] ));
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionCategoryForId
		Returns the TidyConfigCategory for the given TidyOptionId.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (TidyConfigCategory)optionCategoryForId:(TidyOptionId)idf
{
	return tidyOptGetCategory( [self optionGetOptionInstance:idf] );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionTypeForId
		Returns the TidyOptionType: string, int, or bool.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (TidyOptionType)optionTypeForId:(TidyOptionId)idf
{
	return tidyOptGetType( [self optionGetOptionInstance:idf] );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionDefaultValueForId
		Returns the factory default value for the given TidyOptionId.
		All values are converted to type NSString -- that's all we deal
		with because Cocoa makes it easy to convert, and it
		simplifies everything else -- we can use all one datatype.
		
		We OVERRIDE the `encoding` options to return our own in order
		to support using the Mac OS X encoding functions instead.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSString *)optionDefaultValueForId:(TidyOptionId)idf
{
	// ENCODING OPTIONS -- special case, so handle first.
	if ([self isTidyEncodingOption:idf])
	{
		if (idf == TidyCharEncoding)
		{
			// Return string on the value.
			return [NSString stringWithFormat:@"%u", tidyDefaultInputEncoding];
		}
		
		if (idf == TidyInCharEncoding)
		{
			// Return string on the value.
			return [NSString stringWithFormat:@"%u", tidyDefaultInputEncoding];
		}
		
		if (idf == TidyOutCharEncoding)
		{
			// Return string on the value.
			return [NSString stringWithFormat:@"%u", tidyDefaultOutputEncoding];
		}
	}

	TidyOptionType optType = [JSDTidyDocument optionTypeForId:idf];

	if (optType == TidyString)
	{
		ctmbstr tmp = tidyOptGetDefault( [self optionGetOptionInstance:idf] );
		return ( (tmp != nil) ? @(tmp) : @"" );
	}

	if (optType == TidyBoolean)
	{
		// Return string of the bool.
		return [NSString stringWithFormat:@"%u", tidyOptGetDefaultBool( [self optionGetOptionInstance:idf] )];
	}

	if (optType == TidyInteger) 
	{
		// Return string of the integer.
		return [NSString stringWithFormat:@"%lu", tidyOptGetDefaultInt( [self optionGetOptionInstance:idf] )];
	}

	return @"";
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsReadOnlyForId
		Indicates whether the option is read-only
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (bool)optionIsReadOnlyForId:(TidyOptionId)idf
{
	return tidyOptIsReadOnly( [self optionGetOptionInstance:idf] );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionPickListForId
		Returns an NSArray of NSString for the given |TidyOptionId|
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray *)optionPickListForId:(TidyOptionId)idf
{
	NSMutableArray *theArray = [[[NSMutableArray alloc] init] autorelease];	
	
	// If we're an encoding option, return OUR OWN pick list.
	if ([self isTidyEncodingOption:idf])
	{
		return [[self class] allAvailableEncodingLocalizedNames];
	}
	// Otherwise return Tidy's pick list.
	else 
	{
		TidyIterator i = tidyOptGetPickList( [self optionGetOptionInstance:idf] );
		while ( i )
		{
			[theArray addObject:@(tidyOptGetNextPick([self optionGetOptionInstance:idf], &i))];
		}
	}

	return theArray;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionValueForId
		Returns the value for the item as an NSString
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString *)optionValueForId:(TidyOptionId)idf
{
	// We need to treat user-defined tags specially, 'cos TidyLib doesn't return them as config options!
	if ((idf == TidyInlineTags) || (idf == TidyBlockTags) || (idf == TidyEmptyTags) || (idf == TidyPreTags)) 
	{
		NSMutableArray *theArray = [[[NSMutableArray alloc] init] autorelease];
		
		ctmbstr tmp;
		
		TidyIterator i = tidyOptGetDeclTagList( _prefDoc );
		
		while ( i ) 
		{
			tmp = tidyOptGetNextDeclTag(_prefDoc, idf, &i);
			
			if (tmp)
			{
				[theArray addObject:@(tmp)];
			}
		}
		
		return [theArray componentsJoinedByString:@", "];
	}

	// We need to treat encoding options specially, 'cos we
	// override Tidy's treatment of them. We're keeping these
	// values in our own ivars, because TidyLib won't keep
	// them for us.
	if ( [[self class] isTidyEncodingOption:idf])
	{
		if (idf == TidyCharEncoding) 
		{
			return [@(_inputEncoding) stringValue];
		}
		
		if (idf == TidyInCharEncoding) 
		{
			return [@(_inputEncoding) stringValue];
		}
		
		if (idf == TidyOutCharEncoding)
		{
			return [@(_outputEncoding) stringValue];
		}
	}
	
	TidyOptionType optType = [JSDTidyDocument optionTypeForId:idf];

	if (optType == TidyString)
	{
		ctmbstr tmp = tidyOptGetValue( _prefDoc, idf );
		return ( (tmp != nil) ? @(tmp) : @"" );
	} 

	if (optType == TidyBoolean)
	{
		return [@((BOOL)tidyOptGetBool( _prefDoc, idf )) stringValue];
	}

	if (optType == TidyInteger)
	{
		// special occasion for TidyWrapLen
		if (idf == TidyWrapLen)
		{
			if (tidyOptGetInt( _prefDoc, idf) == LONG_MAX)
			{
				return @"0";
			}
		}
		return [@(tidyOptGetInt( _prefDoc, idf )) stringValue];
	}

	return @"";
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	setOptionValueForId:fromObject
		Sets the value for the item in the |_prefDoc|
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionValueForId:(TidyOptionId)idf fromObject:(id)value
{
	// we need to treat encoding options specially,
	// 'cos we override Tidy's treatment of them.
	// Here we are keeping encoding values in our
	// own iVars because TidyLib doesn't like them.
	if ( [[self class] isTidyEncodingOption:idf])
	{
		if (idf == TidyCharEncoding)
		{
			_inputEncoding = [value integerValue];
			_outputEncoding = [value integerValue];
			[self fixSourceCoding];
		}

		if (idf == TidyInCharEncoding)
		{
			_inputEncoding = [value integerValue];
			[self fixSourceCoding];
		}

		if (idf == TidyOutCharEncoding)
		{
			_outputEncoding = [value integerValue];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOptionChanged" object:self];
		[NSApp sendAction:_action to:_target from:self];

		return;
	}

	// Here we could be passed any object, but we'll test for ones we can use.
	if ([value isKindOfClass:[NSString class]])
	{
		if ([value length] == 0)
		{
			// Some tidy options can't accept NULLSTR but can be reset to default NULLSTR. Some,
			// though require a NULLSTR and reseting to default doesn't work. WTF.
			
			if ([tidyOptionsThatCannotAcceptNULLSTR valueForKey:[JSDTidyDocument optionNameForId:idf]])
			{
				tidyOptResetToDefault( _prefDoc, idf );
			}
			else
			{
				tidyOptParseValue( _prefDoc, [[JSDTidyDocument optionNameForId:idf] UTF8String], NULLSTR );
			}
		}
		else
		{
			tidyOptParseValue( _prefDoc, [[JSDTidyDocument optionNameForId:idf] UTF8String], [value UTF8String] );
		}
	}
	else
	{
		if ([value isKindOfClass:[NSNumber class]])
		{
			if ([JSDTidyDocument optionTypeForId:idf] == TidyBoolean)
			{
				tidyOptSetBool( _prefDoc, idf, [value boolValue]);
			}
			else
			{
				if ([JSDTidyDocument optionTypeForId:idf] == TidyInteger)
				{
					tidyOptSetInt( _prefDoc, idf, [value unsignedIntValue]);
				}
			}
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOptionChanged" object:self];
	[NSApp sendAction:_action to:_target from:self];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 optionResetToDefaultForId
 resets the designated ID to factory default
 #TODO: capture the character encoding types
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)optionResetToDefaultForId:(TidyOptionId)idf
{
	tidyOptResetToDefault( _prefDoc, idf );
	[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOptionChanged" object:self];

}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 optionResetAllToDefault
 resets all options to factory default
 #TODO: capture the character encoding types
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)optionResetAllToDefault
{
	tidyOptResetAllToDefault( _prefDoc );
	[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOptionChanged" object:self];

}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionCopyFromDocument
		Copies all options from theDocument into our _prefDoc.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)optionCopyFromDocument:(JSDTidyDocument *)theDocument
{
	tidyOptCopyConfig( _prefDoc, [theDocument tidyDocument] );
	_inputEncoding = [theDocument inputEncoding];
	_outputEncoding = [theDocument outputEncoding];
[[NSNotificationCenter defaultCenter] postNotificationName:@"JSDTidyDocumentOptionChanged" object:self];
[self fixSourceCoding];
[self processTidy];

}


#pragma mark -
#pragma mark RAW ACCESS EXPOSURE


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	tidyDocument
		return the address of |_prefDoc|
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (TidyDoc)tidyDocument
{
	return _prefDoc;
}


#pragma mark -
#pragma mark DIAGNOSTICS and REPAIR


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyDetectedHtmlVersion
 returns 0, 2, 3, 4, or 5
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (int)tidyDetectedHtmlVersion
{
	return tidyDetectedHtmlVersion( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyDetectedXhtml
 determines whether the document is XHTML
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (bool)tidyDetectedXhtml
{
	return tidyDetectedXhtml( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyDetectedGenericXml
 determines if the document is generic XML.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (bool)tidyDetectedGenericXml
{
	return tidyDetectedGenericXml( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyStatus
 returns 0 if there are no errors, 2 for doc errors, 1 for other.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (int)tidyStatus
{
	return tidyStatus( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyErrorCount
 returns number of document errors.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (uint)tidyErrorCount
{
	return tidyErrorCount( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyWarningCount
 returns number of document warnings.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (uint)tidyWarningCount
{
	return tidyWarningCount( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyAccessWarningCount
 returns number of document accessibility warnings.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (uint)tidyAccessWarningCount
{
	return tidyAccessWarningCount( _prefDoc );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	errorFilter:Level:Line:Column:Message
		This is the REAL TidyError filter, and is called by the
		standard C |tidyCallBackFilter| function implemented at the
		top of this file.

		TidyLib doesn't maintain a structured list of all of its
		errors so here we capture them one-by-one as Tidy tidy's.
		In this way we build our own structured list.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (bool)errorFilter:(TidyDoc)tDoc Level:(TidyReportLevel)lvl Line:(uint)line Column:(uint)col Message:(ctmbstr)mssg
{
	NSMutableDictionary *errorDict = [[NSMutableDictionary alloc] init];	// create a dictionary to hold the error report
	errorDict[@"level"] = @((int)lvl);									// lvl is a c enum
	errorDict[@"line"] = @(line);
	errorDict[@"column"] = @(col);
	errorDict[@"message"] = @(mssg);
	[_errorArray addObject:errorDict];
	[errorDict release];
	return YES; // always return yes otherwise _errorText will be surpressed by TidyLib.
}


#pragma mark -
#pragma mark MISCELLENEOUS - misc. Tidy methods supported


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 tidyReleaseDate
 returns the TidyLib release date
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString *)tidyReleaseDate
{
	return @(tidyReleaseDate());
}


#pragma mark -
#pragma mark SUPPORTED CONFIG LIST SUPPORT


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 loadConfigurationListFromResource:ofType -- CLASS method
 returns an array of NSString from a file-resource. This compares
 each item with the linked-in TidyLib to ensure items are support-
 ed, and ensures there are no duplicates. There is nothing in
 JSDTidyDocument that uses this except for the optional defaults
 system support below, and it aids support of Balthisar
 Tidy's preferences implementation.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray *)loadConfigurationListFromResource:(NSString *)fileName ofType:(NSString *)fileType
{
	NSMutableArray *optionsInEffect = [[[NSMutableArray alloc] init] autorelease];
	NSString *contentPath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
	if (contentPath != nil) {
		NSEnumerator *enumerator = [[[NSString stringWithContentsOfFile: contentPath encoding:NSUTF8StringEncoding error:NULL] componentsSeparatedByString:@"\n"] objectEnumerator];
		NSString *tmpStr;
		while (tmpStr = [enumerator nextObject]) {
			if (([JSDTidyDocument optionIdForName:tmpStr] != 0) && (![optionsInEffect containsObject:tmpStr]))
			{
				[optionsInEffect addObject:tmpStr];
			}
		} // while
	} // if
	return optionsInEffect;
}


#pragma mark -
#pragma mark MAC OS PREFS SUPPORT


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	addDefaultsToDictionary -- CLASS method
		Parses through each default defined in Tidy to ascertain its
		value and add i tto the passed-in dictionary. Useful for
		working with the Cocoa preference system. We DON'T register
		the defaults because there may be other defaults to register.
		The calling class can have other items in the passed-in
		dictionary.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (void)addDefaultsToDictionary:(NSMutableDictionary *)defaultDictionary
{
	NSEnumerator *enumerator = [[JSDTidyDocument optionGetList] objectEnumerator];
	NSString *optionName;
	while (optionName = [enumerator nextObject])
	{
		defaultDictionary[[tidyPrefPrefix stringByAppendingString:optionName]] = [JSDTidyDocument optionDefaultValueForId:[JSDTidyDocument optionIdForName:optionName]];
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 addDefaultsToDictionary:fromResource:ofType -- CLASS method
 parses through EVERY default defined in the specified resource
 file to ascertain their values and add them to the passed-in
 dictionary. Useful for working with the Cocoa preference system.
 We DON'T register the defaults because there may be other defaults
 to register. The calling class can have other items in the
 passed-in dictionary. Same as addDefaultsToDictionary, except
 uses a resource file list of options, instead of ALL TidyLib
 options.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (void)addDefaultsToDictionary:(NSMutableDictionary *)defaultDictionary fromResource:(NSString *)fileName ofType:(NSString *)fileType
{
	NSEnumerator *enumerator = [[JSDTidyDocument loadConfigurationListFromResource:fileName ofType:fileType] objectEnumerator]; // just resource options.
	NSString *optionName;
	while (optionName = [enumerator nextObject])
	{
		defaultDictionary[[tidyPrefPrefix stringByAppendingString:optionName]] = [JSDTidyDocument optionDefaultValueForId:[JSDTidyDocument optionIdForName:optionName]];
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	writeOptionValuesWithDefaults
		Parses through the current configuration values and registers
		the current value with the Cocoa preference system. We DO
		register the preference changes, since the calling class can
		also register its own changes when necessary.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)writeOptionValuesWithDefaults:(NSUserDefaults *)defaults
{
	NSEnumerator *enumerator = [[JSDTidyDocument optionGetList] objectEnumerator];
	NSString *optionName;
	
	while (optionName = [enumerator nextObject])
	{
		TidyOptionId	optId = [JSDTidyDocument optionIdForName:optionName];				// get the optionId
		NSString		*keyName = [tidyPrefPrefix stringByAppendingString:optionName];		// get the name
		
		[defaults setObject:[self optionValueForId:optId] forKey:keyName];					// write the default
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	takeOptionValuesFromDefaults
		Given a defaults instance, attempts to set all of its options
		from what's registered in the Apple defaults system.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)takeOptionValuesFromDefaults:(NSUserDefaults *)defaults
{
	NSEnumerator *enumerator = [[JSDTidyDocument optionGetList] objectEnumerator];
	NSString *optionName;
	
	while (optionName = [enumerator nextObject])
	{
		TidyOptionId	optId = [JSDTidyDocument optionIdForName:optionName];			// get the current optionId.
		TidyOptionType	optType = [JSDTidyDocument optionTypeForId:optId];				// get the type.
		NSString		*keyName = [tidyPrefPrefix stringByAppendingString:optionName];	// get the key name
		NSObject		*myObj = [defaults objectForKey:keyName];						// get the object (value) from the prefs.
		
		// Most options in TidyLib have string parsers and we can happily
		// pass string representations of integers to TidyLib. Except that
		// `doctype-mode` doesn't accept strings. We're working with strings,
		// but we'll convert strings to NSNumber objects so we can use integers
		// natively instead of trying to force strings into TidyLib, even though
		// it's supposed to work.
		if (optType == TidyInteger)
		{
			[self setOptionValueForId:optId fromObject:@([(NSString *)myObj longLongValue])];
		}
		else
		{
			[self setOptionValueForId:optId fromObject:myObj];
		}
	}
}

@end
