/**************************************************************************************************
 
	JSDTidyOption.h

	Provides most of the options-related services to JSDTidyModel.


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

#import "JSDTidyOption.h"
#import "buffio.h"
#import "config.h"


#pragma mark - IMPLEMENTATION


@implementation JSDTidyOption


#pragma mark - iVar Synthesis


@synthesize optionValue = _optionValue;


#pragma mark - Initialization and Deallocation


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initSharingModel
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initSharingModel:(JSDTidyModel *)sharedTidyModel
{
	if (self = [super init])
	{
		_sharedTidyModel = sharedTidyModel;
		_name = @"undefined";
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithName:sharingModel
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithName:(NSString *)name sharingModel:(JSDTidyModel *)sharedTidyModel
{
	if (self = [super init])
	{
		_sharedTidyModel = sharedTidyModel;
		_name = name;
		if (TidyUnknownOption == self.tidyOptionId)
		{
			_name = @"undefined";
		}
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithName:optionValue:sharingModel
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithName:(NSString *)name optionValue:(NSString *)value sharingModel:(JSDTidyModel *)sharedTidyModel
{
	if (self = [super init])
	{
		_sharedTidyModel = sharedTidyModel;
		_name = name;
		if (TidyUnknownOption == self.tidyOptionId)
		{
			_name = @"undefined";
		}
		else
		{
			self.optionValue = value;
		}
	}
	return self;
}


#pragma mark - Accessors


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	SET setOptionValue
	@todo Decide whether this setter is necessary; maybe it's better
	to capture these special circumstances in the model instead of
	in this class.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionValue:(NSString *)optionValue
{
	/*
		We need to treat encoding options specially, because we
		override Tidy's treatment of them.
	 */
	if ( self.optionIsEncodingOption)
	{
		if (self.tidyOptionId == TidyCharEncoding)
		{
			[self.sharedTidyModel.tidyOptions setValue:optionValue forKeyPath:@"input-encoding.optionValue"];
			[self.sharedTidyModel.tidyOptions setValue:optionValue forKeyPath:@"output-encoding.optionValue"];
		}
		
		if (self.tidyOptionId == TidyInCharEncoding)
		{
			_optionValue = optionValue;
			/// @todo reserved in case we want special action here
		}
		
		if (self.tidyOptionId == TidyOutCharEncoding)
		{
			_optionValue = optionValue;
			/// @todo reserved in case we want special action here
		}
	}
	else
	{
		_optionValue = optionValue;
	}
	
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	GET optionValue
		If the current value is nil, then ensure we return the
		built-in default value instead.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)optionValue
{
	if (!_optionValue)
	{
		return [self builtInDefaultValue];
	}
	else
	{
		return _optionValue;
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	defaultOptionValue
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)defaultOptionValue
{
	/** 
		@todo Need to develop preferences storage strategy. I would
	    like to move to a single key with nested values instead
		of all of the keys mixed throughout the preferences file.
	 */
	return @""; ///< @todo temporary
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	possibleOptionValues
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSArray*)possibleOptionValues
{
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	
	if ( self.optionIsEncodingOption )
	{
		return [JSDTidyModel allAvailableEncodingLocalizedNames];
	}
	else
	{
		TidyOption tidyOptionInstance = [self createTidyOptionInstance:self.tidyOptionId];
		
		TidyIterator i = tidyOptGetPickList( tidyOptionInstance );

		while ( i )
		{
			[theArray addObject:@(tidyOptGetNextPick(tidyOptionInstance, &i))];
		}
	}
	
	return theArray;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsReadOnly
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)optionIsReadOnly
{
	return tidyOptIsReadOnly( [self createTidyOptionInstance:self.tidyOptionId] );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	localizedHumanReadableName
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)localizedHumanReadableName
{
	return NSLocalizedString( ([NSString stringWithFormat:@"tag-%@", self.name]), nil);
	/// @todo change the localizable.strings so the keys are correct!
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	localizedHumanReadableDescription
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)localizedHumanReadableDescription
{
	// parentheses around brackets required lest preprocessor get confused.
	return NSLocalizedString( ([NSString stringWithFormat:@"description-%@", self.name]), nil);
	/// @todo change the localizable.strings so the keys are correct!
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	localizedHumanReadableCategory
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)localizedHumanReadableCategory
{
	//NSString *temp = tidyOptGetCategory( [self createTidyOptionInstance:self.tidyOptionId] );
	/// @todo as TidyLib uses an enum. Need to find the string source, if any.
	return @""; ///< @todo temporary
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	 tidyOptionId
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (TidyOptionId)tidyOptionId
{
	TidyOptionId optID = tidyOptGetIdForName( [_name UTF8String] );
	
	if (optID < N_TIDY_OPTIONS)
	{
		return optID;
	}
	
	return TidyUnknownOption;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	builtInDefaultValue
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)builtInDefaultValue
{
	// ENCODING OPTIONS -- special case, so handle first.
	if (self.optionIsEncodingOption)
	{
		if (self.tidyOptionId == TidyCharEncoding)
		{
			return [NSString stringWithFormat:@"%u", tidyDefaultInputEncoding];
		}
		
		if (self.tidyOptionId == TidyInCharEncoding)
		{
			return [NSString stringWithFormat:@"%u", tidyDefaultInputEncoding];
		}
		
		if (self.tidyOptionId == TidyOutCharEncoding)
		{
			return [NSString stringWithFormat:@"%u", tidyDefaultOutputEncoding];
		}
	}
	
	TidyOption tidyOptionInstance = [self createTidyOptionInstance:self.tidyOptionId];

	TidyOptionType optType = tidyOptGetType( tidyOptionInstance );
	
	if (optType == TidyString)
	{
		ctmbstr tmp = tidyOptGetDefault( tidyOptionInstance );
		return ( (tmp != nil) ? @(tmp) : @"" );
	}
	
	if (optType == TidyBoolean)
	{
		// Return string of the bool.
		return [NSString stringWithFormat:@"%u", tidyOptGetDefaultBool( tidyOptionInstance )];
	}
	
	if (optType == TidyInteger)
	{
		// Return string of the integer.
		return [NSString stringWithFormat:@"%lu", tidyOptGetDefaultInt( tidyOptionInstance )];
	}
	
	return @"";
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	builtInDescription
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)builtInDescription
{
	TidyDoc dummyDoc = tidyCreate();
	
	NSString *tidyResultString;
	const char *tidyResultCString = tidyOptGetDoc(dummyDoc, tidyGetOption(dummyDoc, self.tidyOptionId));
	
	if (!tidyResultCString)
	{
		tidyResultString = @"No description provided by TidyLib.";
	}
	else
	{
		tidyResultString = @(tidyResultCString);
	}
	
	tidyRelease(dummyDoc);
	
	return tidyResultString;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	builtInCategory
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)builtInCategory
{
	/// @todo as TidyLib uses an enum. Need to find the string source, if any.
	
	return @""; ///< @todo temporary
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsSuppressed
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)optionIsSuppressed
{
	
	return no; ///< @todo temporary
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsEncodingOption
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)optionIsEncodingOption
{
	return ((self.tidyOptionId == TidyCharEncoding) ||
			(self.tidyOptionId == TidyInCharEncoding) ||
			(self.tidyOptionId == TidyOutCharEncoding));
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsOverridden
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)optionIsOverridden
{

	return no; ///< @todo temporary
}


#pragma mark - Private


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	createTidyOptionInstance
		Given an option id, return an instance of a tidy option.
		This is required because many of the TidyLib functions
		require an instance in order to return data.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (TidyOption)createTidyOptionInstance:(TidyOptionId)idf
{
	TidyDoc dummyDoc = tidyCreate();					// Create a dummy document.
	TidyOption result = tidyGetOption( dummyDoc, idf);	// Get an instance of an option.
	tidyRelease(dummyDoc);								// Release the document.
	return result;										// Return the instance of the option.
}




@end
