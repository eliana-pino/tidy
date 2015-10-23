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

@import Cocoa;


#pragma mark - class JSDStringEncodingTools


@interface JSDStringEncodingTools : NSObject

/**
 *  Provides a list of all available encoding names in the localized language sorted in a localized manner.
 *  The `LocalizedIndex` field of the encodings dictionaries refer to the array index of this array.
 */
+ (NSArray *)encodingNames;

/**
 *  Provides a dictionary of objects containing details about string encodings, using an NSStringEncoding
 *  (wrapped in an NSNumber) as the key. Each object is itself a dictionary with the following keys:
 *  LocalizedName, LocalizedIndex, and NSStringEncoding.
 */
+ (NSDictionary *)encodingsByEncoding;

/**
 *  Provides a dictionary of objects containing details about string encodings, using an integer
 *  (wrapped in an NSNumber) as the key. Each object is itself a dictionary with the following keys:
 *  LocalizedName, LocalizedIndex, and NSStringEncoding.
 */
+ (NSDictionary *)encodingsByIndex;

/**
 *  Provides a dictionary of objects containing details about string encodings, using the localized name
 *  (as an NSString) as the key. Each object is itself a dictionary with the following keys: 
 *  LocalizedName, LocalizedIndex, and NSStringEncoding.
 */
+ (NSDictionary *)encodingsByName;


@end
