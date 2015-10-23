/**************************************************************************************************

	JSDTidyModelDelegate.h

	JSDTidyModel is a nice, Mac OS X wrapper for TidyLib. It uses instances of JSDTidyOption
	to contain TidyOptions. The model works with every built-in	TidyOption, although applications
	can suppress multiple individual TidyOptions if desired.
	
 **************************************************************************************************/

@import Foundation;

@class JSDTidyModel;
@class JSDTidyOption;

/*
	TidyLib will post the following NSNotifications.
*/

#define tidyNotifyOptionChanged                  @"JSDTidyDocumentOptionChanged"
#define tidyNotifySourceTextChanged              @"JSDTidyDocumentSourceTextChanged"
#define tidyNotifySourceTextRestored             @"JSDTidyDocumentSourceTextRestored"
#define tidyNotifyTidyTextChanged                @"JSDTidyDocumentTidyTextChanged"
#define tidyNotifyTidyErrorsChanged              @"JSDTidyDocumentTidyErrorsChanged"
#define tidyNotifyPossibleInputEncodingProblem   @"JSDTidyNotifyPossibleInputEncodingProblem"


#pragma mark - protocol JSDTidyModelDelegate

/*
	Protocol to define the Tidy delegate expectations.
*/

@protocol JSDTidyModelDelegate <NSObject>


@optional

- (void)tidyModelOptionChanged:(JSDTidyModel *)tidyModel 
                        option:(JSDTidyOption *)tidyOption;

- (void)tidyModelSourceTextChanged:(JSDTidyModel *)tidyModel
                              text:(NSString *)text;

- (void)tidyModelSourceTextRestored:(JSDTidyModel *)tidyModel
							  text:(NSString *)text;

- (void)tidyModelTidyTextChanged:(JSDTidyModel *)tidyModel
                            text:(NSString *)text;

- (void)tidyModelTidyMessagesChanged:(JSDTidyModel *)tidyModel
                            messages:(NSArray *)messages;

- (void)tidyModelDetectedInputEncodingIssue:(JSDTidyModel *)tidyModel
                            currentEncoding:(NSStringEncoding)currentEncoding
                          suggestedEncoding:(NSStringEncoding)suggestedEncoding;

@end

