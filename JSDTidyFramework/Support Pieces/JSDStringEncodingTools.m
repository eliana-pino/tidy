/**************************************************************************************************

	JSDStringEncodingTools

	Provides auxilliary methods for dealing with different string encodings.
	

	The MIT License (MIT)

	Copyright (c) 2001 to 2015 James S. Derry <http://www.balthisar.com>

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

#import "JSDStringEncodingTools.h"


#pragma mark - IMPLEMENTATION JSDStringEncodingTools

@implementation JSDStringEncodingTools


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	allAvailableEncodingLocalizedNames
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSArray *)encodingNames
{
	static NSArray *encodingNames = nil; // Only do this once
	
	if (!encodingNames)
	{
		NSMutableArray *tempNames = [[NSMutableArray alloc] init];
		
		const NSStringEncoding *encoding = [NSString availableStringEncodings];
		
		while (*encoding)
		{
			[tempNames addObject:[NSString localizedNameOfStringEncoding:*encoding]];
			encoding++;
		}
		
		encodingNames = [tempNames sortedArrayUsingComparator:^(NSString *a, NSString *b) { return [a localizedCaseInsensitiveCompare:b]; }];
	}
	
	return encodingNames;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	encodingsByEncoding
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSDictionary *)encodingsByEncoding
{
	static NSMutableDictionary *dictionary = nil; // Only do this once
	
	if (!dictionary)
	{
		dictionary = [[NSMutableDictionary alloc] init];
		
		const NSStringEncoding *encoding = [NSString availableStringEncodings];
		
		while (*encoding)
		{
			NSString *currentName = [NSString localizedNameOfStringEncoding:*encoding];
			NSNumber *currentIndex = @([[[self class] encodingNames] indexOfObject:currentName]);
			
			NSDictionary *items = @{@"LocalizedName"    : currentName,
									@"NSStringEncoding" : @(*encoding),
									@"LocalizedIndex"   : currentIndex};
			
			dictionary[@(*encoding)] = items;
			
			encoding++;
		}
	}
	
	return dictionary;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	encodingsByIndex
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSDictionary *)encodingsByIndex
{
	static NSMutableDictionary *dictionary = nil; // Only do this once
	
	if (!dictionary)
	{
		dictionary = [[NSMutableDictionary alloc] init];
		
		const NSStringEncoding *encoding = [NSString availableStringEncodings];
		
		while (*encoding)
		{
			NSString *currentName = [NSString localizedNameOfStringEncoding:*encoding];
			NSNumber *currentIndex = @([[[self class] encodingNames] indexOfObject:currentName]);

			NSDictionary *items = @{@"LocalizedName"    : currentName,
									@"NSStringEncoding" : @(*encoding),
									@"LocalizedIndex"   : currentIndex};
			
			dictionary[currentIndex] = items;
			
			encoding++;
		}
	}
	
	return dictionary;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	encodingsByName
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
+ (NSDictionary *)encodingsByName
{
	static NSMutableDictionary *dictionary = nil; // Only do this once
	
	if (!dictionary)
	{
		dictionary = [[NSMutableDictionary alloc] init];
		
		const NSStringEncoding *encoding = [NSString availableStringEncodings];
		
		while (*encoding)
		{
			NSString *currentName = [NSString localizedNameOfStringEncoding:*encoding];
			NSNumber *currentIndex = @([[[self class] encodingNames] indexOfObject:currentName]);
			
			NSDictionary *items = @{@"LocalizedName"    : currentName,
									@"NSStringEncoding" : @(*encoding),
									@"LocalizedIndex"   : currentIndex};
			
			dictionary[currentName] = items;

			encoding++;
		}
	}
	
	return dictionary;
}


@end
