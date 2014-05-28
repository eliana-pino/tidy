//
//  JSDTidyOptionTests.m
//  Balthisar Tidy
//
//  Created by Jim Derry on 5/28/14.
//  Copyright (c) 2014 Jim Derry. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JSDTidyOption.h"
#import "JSDTidyModel.h"

@interface JSDTidyOptionTests : XCTestCase

@end


@implementation JSDTidyOptionTests


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testInitializers
{
	BOOL result;
	JSDTidyModel *localModel = [[JSDTidyModel alloc] init];


	/* initSharingModel: */

	JSDTidyOption *localOption = [[JSDTidyOption alloc] initSharingModel:localModel];

	result = [localOption.sharedTidyModel isEqual:localModel];
	XCTAssertEqual(result, YES, @"Should have matched.");

	result = [localOption.name isEqualToString:@"undefined"];
	XCTAssertEqual(result, YES, @"Should have matched.");

	result = [localOption.optionValue isEqualToString:@"0"];
	XCTAssertEqual(result, YES, @"Should have matched.");


	/* initWithName:sharingModel: */

	localOption = [[JSDTidyOption alloc] initWithName:@"indent-spaces" sharingModel:localModel];

	result = [[localOption valueForKey:@"optionValue"] isEqualToString:@"2"];
	XCTAssertEqual(result, YES, @"Should have matched.");


	/* initWithName:optionValue:sharingModel: */

	localOption = [[JSDTidyOption alloc] initWithName:@"wrap" optionValue:@"80" sharingModel:localModel];

	result = [localOption.optionValue isEqualToString:@"80"];
	XCTAssertEqual(result, YES, @"Should have matched.");
}

- (void)testMainProperties
{
	BOOL result;

	NSString *localizedString;

	JSDTidyModel *localModel = [[JSDTidyModel alloc] init];

	JSDTidyOption *localOption = [[JSDTidyOption alloc] initWithName:@"indent-spaces" sharingModel:localModel];


	/* name */
	XCTAssertEqual(localOption.name, @"indent-spaces", @"Should have matched.");


	/* optionValue */
	localOption.optionValue = @"7";
	XCTAssertEqual(localOption.optionValue, @"7", @"Should have matched.");


	/* defaultOptionValue */
	// Skipped; don't want to mess with the preferences system.


	/* localizedHumanReadableName */
	localizedString = NSLocalizedStringFromTable(@"tag-indent-spaces", @"JSDTidyModel" ,nil);
	XCTAssertEqual(localOption.localizedHumanReadableName, localizedString, @"Should have matched.");


	/* localizedHumanReadableDescription */
	result = [localOption.localizedHumanReadableDescription length] > 0; // Not the best test, unfortunately.
	XCTAssertEqual(result, YES, @"Should have matched.");


	/* localizedHumanReadableCategory */
	localizedString = NSLocalizedStringFromTable(@"category-2", @"JSDTidyModel" ,nil);
	XCTAssertEqual(localOption.localizedHumanReadableCategory, localizedString, @"Should have matched.");


	/* possibleOptionValues */
	localOption = [[JSDTidyOption alloc] initWithName:@"ascii-chars" sharingModel:nil];
	result = [localOption.possibleOptionValues[0] isEqualToString:@"no"];
	XCTAssertEqual(result, YES, @"Should have matched.");


	/* optionIsReadOnly */
	localOption = [[JSDTidyOption alloc] initWithName:@"doctype-mode" sharingModel:nil];
	result = localOption.optionIsReadOnly;
	XCTAssertEqual(result, YES, @"Should have matched.");
}

@end


/*

 #pragma mark - Main properties

 @property (readonly)         NSString *name;                            // Built-in option name.

 @property                    NSString *optionValue;                     // Current value of this option.

 @property (readonly)         NSString *defaultOptionValue;              // Default value of this option (from user options).

 @property (readonly)         NSArray *possibleOptionValues;             // Array of string values for possible option values.

 @property (readonly)         BOOL optionIsReadOnly;                     // Indicates whether or not option is read-only.

 @property (readonly)         NSString *localizedHumanReadableName;      // Localized, humanized name of the option.

 @property (readonly)         NSAttributedString *localizedHumanReadableDescription; // Localized description of the option.

 @property (readonly)         NSString *localizedHumanReadableCategory;  // Localized name of the option category.


 #pragma mark - Properties useful for implementing user interfaces

 @property                    NSString *optionUIValue;                   // Current value of this option used by UI's.

 @property (readonly)         Class optionUIType;                        // Suggested UI type for setting options.


 #pragma mark - Properties maintained for original TidyLib compatability (may be used internally)

 @property (readonly)         TidyOptionId optionId;                     // Tidy's internal TidyOptionId for this option.

 @property (readonly)         TidyOptionType optionType;                 // Actual type that TidyLib expects.

 @property (readonly)         NSString *builtInDefaultValue;             // Tidy's built-in default value for this option.

 @property (readonly)         NSString *builtInDescription;              // Tidy's built-in description for this option.

 @property (readonly)         TidyConfigCategory builtInCategory;        // Tidy's built-in category for this option.


 #pragma mark - Properties used mostly internally or for implementing user interfaces

 @property (readonly, assign) JSDTidyModel *sharedTidyModel;             // Model to which this option belongs.

 @property (readonly, assign) BOOL optionCanAcceptNULLSTR;               // Indicates whether or not this option can accept NULLSTR.

 @property (readonly, assign) BOOL optionIsEncodingOption;               // Indicates whether or not this option is an encoding option.

 @property (assign)           BOOL optionIsHeader;                       // Fake option is only a header row for UI use.

 @property (assign)           BOOL optionIsSuppressed;                   // Indicates whether or not this option is unused by JSDTidyModel.


 #pragma mark - Other Public Methods

 - (BOOL)applyOptionToTidyDoc:(TidyDoc)destinationTidyDoc;               // Applies this option to a TidyDoc instance.

 - (void)optionUIValueIncrement;                                         // Possibly useful for UI's, increments to next possible option value.

 - (void)optionUIValueDecrement;                                         // Possibly useful for UI's, decrements to next possible option value.

 -(NSComparisonResult)tidyGroupedNameCompare:(JSDTidyOption *)tidyOption;	    // Comparitor for localized sorting and grouping of tidyOptions.

 -(NSComparisonResult)tidyGroupedHumanNameCompare:(JSDTidyOption *)tidyOption;   // Comparitor for localized sorting and grouping of tidyOptions.
 
*/