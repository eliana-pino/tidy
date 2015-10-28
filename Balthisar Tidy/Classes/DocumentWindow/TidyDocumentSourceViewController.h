/**************************************************************************************************

	TidyDocumentSourceViewController
	 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

@class JSDTextView;


/**
 *  The source and tidy text view controller. Manages the two text fields, their interactions,
    and the type of display.
 */
@interface TidyDocumentSourceViewController : NSViewController <NSTextViewDelegate>

@property (assign) IBOutlet JSDTextView *sourceTextView;

@property (assign) IBOutlet NSTextView *tidyTextView;

@property (assign) IBOutlet NSSplitView *splitterViews;

@property (assign) IBOutlet NSTextField *sourceLabel;

@property (assign) IBOutlet NSTextField *tidyLabel;


@property (readonly, assign) BOOL isVertical;

@property (assign) BOOL viewsAreSynced;

@property (assign) BOOL viewsAreDiffed;


- (instancetype)initVertical:(BOOL)initVertical;

- (void)setupViewAppearance;

- (void)highlightSourceTextUsingArrayController:(NSArrayController*)arrayController;


/* 
   We will use this to tickle when used externally, since setting the string
   directly doesn't trigger notifications.
 */
- (void)textDidChange:(NSNotification *)aNotification;


@end
