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
		_name            = @"undefined";
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithName:sharingModel
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithName:(NSString *)name
	  sharingModel:(JSDTidyModel *)sharedTidyModel
{
	if (self = [super init])
	{
		_sharedTidyModel = sharedTidyModel;
		_name            = name;
		
		if ((TidyUnknownOption == self.optionId) || ( N_TIDY_OPTIONS == self.optionId))
		{
			_name = @"undefined";
		}
	}
	return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	initWithName:optionValue:sharingModel
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (id)initWithName:(NSString *)name
	   optionValue:(NSString *)value
	  sharingModel:(JSDTidyModel *)sharedTidyModel
{
	if (self = [super init])
	{
		_sharedTidyModel = sharedTidyModel;
		_name            = name;
		
		if (TidyUnknownOption == self.optionId)
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
	> setOptionValue
		Sets the optionValue, and intercepts special circumstances.
		Note that you must always ensure the encoding option values
		always contain the NSStringEncoding value, and not the
		localized name.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)setOptionValue:(NSString *)optionValue
{
	// We need to treat encoding options specially, because we
	// override Tidy's treatment of them.
	if (!self.optionIsReadOnly)
	{
		if ( self.optionIsEncodingOption)
		{
			if (self.optionId == TidyCharEncoding)
			{
				[self.sharedTidyModel setValue:optionValue forKeyPath:@"tidyOptions.input-encoding.optionValue"];
				
				[self.sharedTidyModel setValue:optionValue forKeyPath:@"tidyOptions.output-encoding.optionValue"];
			}
			
			if (self.optionId == TidyInCharEncoding)
			{
				_optionValue = optionValue;
				// Reserved in case we want special action here
			}
			
			if (self.optionId == TidyOutCharEncoding)
			{
				_optionValue = optionValue;
				// Reserved in case we want special action here
			}
		}
		else
		{
			_optionValue = optionValue;
		}
	}
	/// @todo FLAG NOTIFICATION AND CALLBACK TO sharedTidyModel HERE.
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	< optionValue
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
		Returns the default option value from the Cocoa preferences
		system. We're doing a little bit of cheating by counting
		on the use of the constant defined in the JSDTidyModel
		class.
 
		If no Cocoa preference is available, then the built-in
		value will be returned instead.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)defaultOptionValue
{
	NSString *cocoaDefault = [[[NSUserDefaults standardUserDefaults] objectForKey:jsdTidyTidyOptionsKey] stringForKey:self.name];
	
	if (cocoaDefault)
	{
		return cocoaDefault;
	}
	else
	{
		return self.builtInDefaultValue;
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	possibleOptionValues
		Returns an array of strings consisting of the possible
		option values for this TidyOption.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSArray*)possibleOptionValues
{
	/*
		Check for items that should NOT return their built-in
	    list of possible option values.
	 */
	if ([[NSSet setWithObjects:@"doctype", nil] member:self.name])
	{
		return [[NSArray alloc] initWithObjects:nil];
	}
	
	
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	
	if (self.optionIsEncodingOption)
	{
		return [JSDTidyModel allAvailableEncodingLocalizedNames];
	}
	else
	{
		TidyOption tidyOptionInstance = [self createTidyOptionInstance:self.optionId];
		
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
	return tidyOptIsReadOnly([self createTidyOptionInstance:self.optionId]);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	localizedHumanReadableName
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)localizedHumanReadableName
{
	return NSLocalizedString(([NSString stringWithFormat:@"tag-%@", self.name]), nil);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	localizedHumanReadableDescription
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)localizedHumanReadableDescription
{
	// parentheses around brackets required lest preprocessor get confused.
	return NSLocalizedString(([NSString stringWithFormat:@"description-%@", self.name]), nil);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	localizedHumanReadableCategory
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)localizedHumanReadableCategory
{
	TidyConfigCategory temp = tidyOptGetCategory( [self createTidyOptionInstance:self.optionId] );
	return NSLocalizedString(([NSString stringWithFormat:@"category-%u", temp]), nil);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	 optionId
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (TidyOptionId)optionId
{
	TidyOptionId optID = tidyOptGetIdForName( [[self name] UTF8String] );
	
	if (optID < N_TIDY_OPTIONS)
	{
		return optID;
	}
	
	return TidyUnknownOption;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	 optionType
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (TidyOptionType)optionType
{
	return tidyOptGetType( [self createTidyOptionInstance:self.optionId] );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	builtInDefaultValue
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)builtInDefaultValue
{
	// ENCODING OPTIONS -- special case, so handle first.
	if (self.optionIsEncodingOption)
	{
		if (self.optionId == TidyCharEncoding)
		{
			return [NSString stringWithFormat:@"%u", tidyDefaultInputEncoding];
		}
		
		if (self.optionId == TidyInCharEncoding)
		{
			return [NSString stringWithFormat:@"%u", tidyDefaultInputEncoding];
		}
		
		if (self.optionId == TidyOutCharEncoding)
		{
			return [NSString stringWithFormat:@"%u", tidyDefaultOutputEncoding];
		}
	}
	
	
	TidyOption tidyOptionInstance = [self createTidyOptionInstance:self.optionId];

	TidyOptionType optType        = tidyOptGetType( tidyOptionInstance );
	
	
	if (optType == TidyString)
	{
		ctmbstr tmp = tidyOptGetDefault( tidyOptionInstance );
		return ( (tmp != nil) ? @(tmp) : @"" );
	}
	
	if (optType == TidyBoolean)
	{
		return [NSString stringWithFormat:@"%u", tidyOptGetDefaultBool( tidyOptionInstance )];
	}
	
	if (optType == TidyInteger)
	{
		return [NSString stringWithFormat:@"%lu", tidyOptGetDefaultInt( tidyOptionInstance )];
	}
	
	return @"";
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	builtInDescription
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSString*)builtInDescription
{
	NSString *tidyResultString;

	TidyDoc dummyDoc              = tidyCreate();
	
	const char *tidyResultCString = tidyOptGetDoc(dummyDoc, tidyGetOption(dummyDoc, self.optionId));
	
	
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
- (TidyConfigCategory)builtInCategory
{
	return tidyOptGetCategory( [self createTidyOptionInstance:self.optionId] );
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsSuppressed
		The implementing application may want to suppress certain
		built-in TidyLib options. Setting this to true will hide
		instances of this option from most operations.
 
		This method is implemented automatically by compiler.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionIsEncodingOption
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)optionIsEncodingOption
{
	return ((self.optionId == TidyCharEncoding) ||
			(self.optionId == TidyInCharEncoding) ||
			(self.optionId == TidyOutCharEncoding));
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	optionCanAcceptNULLSTR
		Some TidyLib options can have a NULLSTR value, but they can't
		accept a NULLSTR assignment. This convenience property flags
		the condition.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)optionCanAcceptNULLSTR
{
	return ([[NSSet setWithObjects:@"doctype", @"slide-style", @"language", @"css-prefix", nil] member:self.name]) == nil;
}


#pragma mark - Public Methods


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	applyOptionToTidyDoc
		Given a TidyDoc instance, apply our setting to the TidyDoc.
	
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)applyOptionToTidyDoc:(TidyDoc)destinationTidyDoc
{
	if (self.optionIsEncodingOption)
	{
		// Force TidyLib to use UTF8 internally. Mac OS X will handle
		// file encoding and file input-output.
		return tidyOptSetValue(destinationTidyDoc, self.optionId, [@"utf8" UTF8String]);
	}
	
	if ((!self.optionIsSuppressed) && (!self.optionIsReadOnly))
	{
		if ( self.optionType == TidyString)
		{
			if ([self.optionValue length] == 0)
			{
				 // Some tidy options can't accept NULLSTR but can be reset to default
				 // NULLSTR. Some, though require a NULLSTR and resetting to default
				 // doesn't work. WTF?
				if (!self.optionCanAcceptNULLSTR)
				{
					return tidyOptResetToDefault( destinationTidyDoc, self.optionId );
				}
				else
				{
					return tidyOptSetValue(destinationTidyDoc, self.optionId, NULLSTR);
				}
			}
			else
			{
				return tidyOptSetValue( destinationTidyDoc, self.optionId, [self.optionValue UTF8String] );
			}
		}
		
		if ( [self optionType] == TidyInteger)
		{
			return tidyOptSetInt( destinationTidyDoc, self.optionId, [self.optionValue integerValue] );
		}
		
		if ( [self optionType] == TidyBoolean)
		{
			return tidyOptSetBool( destinationTidyDoc, self.optionId, [self.optionValue boolValue] );
		}
	}
	return YES;
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
	TidyDoc dummyDoc  = tidyCreate();
	
	TidyOption result = tidyGetOption( dummyDoc, idf);
	
	tidyRelease(dummyDoc);
	
	return result;
}


@end
