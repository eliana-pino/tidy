/**************************************************************************************************

	TidyDocumentWindowController
 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

@class EncodingHelperController;
@class FirstRunController;
@class JSDTableViewController;
@class JSDTidyModel;
@class OptionPaneController;
@class TidyMessagesViewController;
@class TidyDocumentSourceViewController;


/**
 *  The main document window controller; manages the view and UI for a TidyDocument window.
 */
@interface TidyDocumentWindowController : NSWindowController

/* Split Views */

@property (weak) IBOutlet NSSplitView *splitterOptions;

@property (weak) IBOutlet NSSplitView *splitterMessages;


/* Option Controller */

@property (assign) IBOutlet NSView *optionPane;     // Empty pane in NIB where optionController's view will live.

@property (assign) IBOutlet NSView *optionPaneContainer; 

@property OptionPaneController *optionController;


/* Messages Controller */

@property (assign) IBOutlet NSView *messagesPane;

@property JSDTableViewController *messagesController;


/* Source Controller */

@property (assign) IBOutlet NSView *sourcePane;

@property TidyDocumentSourceViewController *sourceController;

@property TidyDocumentSourceViewController *sourceControllerHorizontal;

@property TidyDocumentSourceViewController *sourceControllerVertical;


/* Helpers */

@property FirstRunController *firstRunHelper;

@property EncodingHelperController *encodingHelper;


/* React after saving a file */

- (void)documentDidWriteFile;


/* Properties that we will bind to for window control */

@property BOOL optionsPanelIsVisible;

@property BOOL messagesPanelIsVisible;

@property BOOL sourcePanelIsVertical;

@property BOOL sourcePaneLineNumbersAreVisible;


/* Actions to support properties from Menus */
- (IBAction)toggleOptionsPanelIsVisible:(id)sender;
- (IBAction)toggleMessagesPanelIsVisible:(id)sender;
- (IBAction)toggleSourcePanelIsVertical:(id)sender;
- (IBAction)toggleSourcePaneShowsLineNumbers:(id)sender;



/* Toolbar Actions */

- (IBAction)handleWebPreview:(id)sender;

- (IBAction)handleShowDiffView:(id)sender;

- (IBAction)toggleSyncronizedDiffs:(id)sender;

- (IBAction)toggleSynchronizedScrolling:(id)sender;


@end
