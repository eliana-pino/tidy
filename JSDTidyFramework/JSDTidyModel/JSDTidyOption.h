/**************************************************************************************************
 
	JSDTidyOption

	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

#import "config.h"   // from HTMLTidy

@class JSDTidyModel;


/**
 *  **JSDTidyOption** encapsulates a lot of GUI-oriented functionality around `tidylib`
 *  options.
 *
 *  Instances of **JSDTidyOption** belong to a sharedTidyModel, but are largely self aware and
 *  handle most aspects of their operation on their own. They also provide good exposure
 *  to implementing user interfaces.
 *
 *  The principle purpose is to hold and store options, and return information about options.
 *  There is some interactivity among options (e.g., where we override character encodings),
 *  but this is always mediated back through to the sharedTidyModel. Setting an instance of
 *  an option does not cause tidying per se; this is all managed by the JSDTidyModel, which
 *  receives notifications that an item has changed.
 */
@interface JSDTidyOption : NSObject


#pragma mark - Initializers
/** @name Initializers */


/**
 *  Initializes an instance of **JSDTidyOption**, assigning it to an owning instance of
 *  **JSDTidyModel**.
 *
 *  @param sharedTidyModel The **JSDTidyModel** that this option instance belongs to.
 */
- (instancetype)initSharingModel:(JSDTidyModel *)sharedTidyModel;

/**
 *  Initializes an instance of **JSDTidyOption**, assigning it to an owning instance of
 *  **JSDTidyModel**, and assigning the option name.
 *
 *  @param name The name of the Tidy option that this instance represents, e.g., `wrap`.
 *  @param sharedTidyModel The **JSDTidyModel** that this option instance belongs to.
 */
- (instancetype)initWithName:(NSString *)name
                sharingModel:(JSDTidyModel *)sharedTidyModel;

/**
 *  Initializes an instance of **JSDTidyOption**, assigning it to an owning instance of
 *  **JSDTidyModel**, and assigning the option name and initial value.
 *
 *  @param name The name of the Tidy option that this instance represents, e.g., `wrap`.
 *  @param value The Tidy option value to set.
 *  @param sharedTidyModel The **JSDTidyModel** that this option instance belongs to.
 */
- (instancetype)initWithName:(NSString *)name
                 optionValue:(NSString *)value
                sharingModel:(JSDTidyModel *)sharedTidyModel;


#pragma mark - Main Properties
/** @name Main Properties */


/**
 *  Built-in option name.
 */
@property (nonatomic, strong, readonly)         NSString *name;

/**
 *  Current value of this option.
 */
@property (nonatomic, strong)                   NSString *optionValue;

/**
 *  Default value of this option (from user options).
 */
@property (nonatomic, assign, readonly)         NSString *defaultOptionValue;

/**
 *  Array of string values for possible option values.
 */
@property (nonatomic, assign, readonly)         NSArray *possibleOptionValues;

/**
 *  Indicates whether or not option is read-only.
 */
@property (nonatomic, assign, readonly)         BOOL optionIsReadOnly;

/**
 *  Localized, humanized name of the option.
 */
@property (nonatomic, strong, readonly)         NSString *localizedHumanReadableName;

/**
 *  Localized description of the option.
 */
@property (nonatomic, strong, readonly)         NSAttributedString *localizedHumanReadableDescription;

/**
 *  Localized name of the option category.
 */
@property (nonatomic, strong, readonly)         NSString *localizedHumanReadableCategory;


#pragma mark - Properties Useful for Implementing User Interfaces
/** @name Properties Useful for Implementing User Interfaces */


/**
 *  Current value of this option used by UI's.
 */
@property                    NSString *optionUIValue;

/**
 *  Suggested UI type for setting options.
 */
@property (readonly)         NSString *optionUIType;

/**
 *  Option suitable for use in a config file.
 */
@property (readonly)         NSString *optionConfigString;

/**
 *  The NSUserDefaults instance to get defaults from.
 */
@property                    NSUserDefaults *userDefaults;


#pragma mark - Properties Maintained for Original TidyLib compatability (may be used internally)
/** @name Properties Maintained for Original TidyLib compatability (may be used internally) */


/**
 *  Tidy's internal TidyOptionId for this option.
 */
@property (readonly)         TidyOptionId optionId;

/**
 *  Actual type that TidyLib expects.
 */
@property (readonly)         TidyOptionType optionType;

/**
 *  Tidy's built-in default value for this option.
 */
@property (readonly)         NSString *builtInDefaultValue;

/**
 *  Tidy's built-in description for this option.
 */
@property (readonly)         NSString *builtInDescription;

/**
 *  Tidy's built-in category for this option.
 */
@property (readonly)         TidyConfigCategory builtInCategory;


#pragma mark - Properties Used Mostly Internally or for Implementing User Interfaces
/** @name Properties Used Mostly Internally or for Implementing User Interfaces */


/**
 *  Model to which this option belongs.
 */
@property (readonly, assign) JSDTidyModel *sharedTidyModel;

/**
 *  Indicates whether or not this option can accept NULLSTR.
 */
@property (readonly, assign) BOOL optionCanAcceptNULLSTR;

/**
 *  Indicates whether or not this option is an encoding option.
 */
@property (readonly, assign) BOOL optionIsEncodingOption;

/**
 *  Fake option is only a header row for UI use.
 */
@property (assign)           BOOL optionIsHeader;

/**
 *  Indicates whether or not this option is unused by JSDTidyModel.
 */
@property (assign)           BOOL optionIsSuppressed;


#pragma mark - Other Public Methods
/** @name Other Public Methods */


/**
 *  Applies this option to a TidyDoc instance.
 */
- (BOOL)applyOptionToTidyDoc:(TidyDoc)destinationTidyDoc;

/**
 *  Possibly useful for UI's, increments to next possible option value.
 */
- (void)optionUIValueIncrement;

/**
 *  Possibly useful for UI's, decrements to next possible option value.
 */
- (void)optionUIValueDecrement;

/**
 *  Comparitor for localized sorting and grouping of tidyOptions.
 */
-(NSComparisonResult)tidyGroupedNameCompare:(JSDTidyOption *)tidyOption;

/**
 *  Comparitor for localized sorting and grouping of tidyOptions.
 */
-(NSComparisonResult)tidyGroupedHumanNameCompare:(JSDTidyOption *)tidyOption;


@end

