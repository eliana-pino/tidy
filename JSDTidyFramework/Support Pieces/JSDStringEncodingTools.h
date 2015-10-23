/**************************************************************************************************

	JSDStringEncodingTools

	Provides auxilliary methods for dealing with different string encodings.

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
