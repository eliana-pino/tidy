/**************************************************************************************************

	TidyDocument.m

	The main document controller, TidyDocument manages the user interaction between the document
	window and the JSDTidyModel processor.


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

#pragma mark - Notes

/**************************************************************************************************
 
	Event Handling and Interacting with the Tidy Processor
 
		The Tidy processor is loosely coupled with the document controller. Most
		interaction with it is handled via NSNotifications.
 
		If user types text we receive a |textDidChange| delegate notification, and we will set
		new text in [tidyProcess sourceText]. The event chain will eventually handle everything
		else.
 
		If |tidyText| changes we will receive NSNotification, and put the new |tidyText|
		into the |tidyView|, and also update |errorView|.
  
		If |optionController| sends an NSNotification, then we will copy the new
		options to |tidyProcess|. The event chain will eventually handle everything else.
 
		If we set |sourceText| via file or data (only happens when opening or reverting)
		we will NOT update |sourceView|. We will wait for |tidyProcess| NSNotification that
		the |sourceText| changed, then set the |sourceView|. HOWEVER this presents a small
		issue to overcome:
 
			- If we set |sourceView| we will get |textDidChange| notification, causing
			  us to update [tidyProcess sourceText] again, resulting in processing the
			  document twice, which we don't want to do.
 
			- To prevent this we will set |documentIsLoading| to YES any time we we set
			  |sourceText| from file or data. In the |textDidChange| handler we will NOT
			  set [tidyProcess sourceText], and we will flip |documentIsLoading| back to NO.
 
 **************************************************************************************************/

#import "TidyDocument.h"
#import "PreferencesDefinitions.h"
#import "PreferenceController.h"
#import "JSDTidyModel.h"
#import "JSDTidyOption.h"
#import "OptionPaneController.h"
#import "NSTextView+JSDExtensions.h"
#import "FirstRunController.h"


#pragma mark - CATEGORY - Non-Public


@interface TidyDocument ()


#pragma mark - Properties


/* View Outlets */

@property (assign) IBOutlet NSTextView  *sourceView;

@property (assign) IBOutlet NSTextView  *tidyView;

@property (weak)   IBOutlet NSTableView *errorView;


/* Encoding Helper Popover Outlets */

@property (weak) IBOutlet NSPopover   *popoverEncoding;

@property (weak) IBOutlet NSButton    *buttonEncodingDoNotWarnAgain;

@property (weak) IBOutlet NSButton    *buttonEncodingAllowChange;

@property (weak) IBOutlet NSButton    *buttonEncodingIgnoreSuggestion;

@property (weak) IBOutlet NSTextField *textFieldEncodingExplanation;


/* Window Splitters */

@property (weak) IBOutlet NSSplitView *splitLeftRight;

@property (weak) IBOutlet NSSplitView *splitTopDown;


/* Option Controller */

@property (weak)   IBOutlet NSView      *optionPane;         // Our empty optionPane in the nib.

@property          OptionPaneController *optionController;   // The real option pane we load into optionPane.


/* First Run Controller */

@property FirstRunController *firstRun;


/* Our Tidy Processor */

@property JSDTidyModel *tidyProcess;


/* Document Control */

@property          NSData *documentOpenedData;   // Hold file we open until nib is awake.

@property (assign) BOOL   documentIsLoading;     // Flag to supress certain event updates.

@property (assign) BOOL   fileWantsProtection;   // Indicates if we need special type of save.


/* ArrayController linked to tidyProcess' error array. */

@property (strong) IBOutlet NSArrayController *messagesArrayController;


#pragma mark - Methods

/* Encoding Popover Actions */

- (IBAction)popoverEncodingHandler:(id)sender;


@end


#pragma mark - IMPLEMENTATION


@implementation TidyDocument


#pragma mark - Initialization and Deallocation


/*———————————————————————————————————————————————————————————————————*
	init
 *———————————————————————————————————————————————————————————————————*/
- (instancetype)init
{
	if ((self = [super init]))
	{
		self.tidyProcess = [[JSDTidyModel alloc] init];

		self.documentOpenedData = nil;
	}

	return self;
}


/*———————————————————————————————————————————————————————————————————*
	dealloc
 *———————————————————————————————————————————————————————————————————*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifyOptionChanged object:self.optionController.tidyDocument];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifySourceTextChanged object:self.tidyProcess];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifyTidyTextChanged object:self.tidyProcess];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifyTidyErrorsChanged object:self.tidyProcess];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifyPossibleInputEncodingProblem object:self.tidyProcess];
}


#pragma mark - Setup


/*———————————————————————————————————————————————————————————————————*
	configureViewSettings:
		Configure text view `aView` with uniform settings.
 *———————————————————————————————————————————————————————————————————*/
- (void)configureViewSettings:(NSTextView *)aView
{
	NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];


	[aView setFont:[NSFont fontWithName:@"Menlo" size:[NSFont systemFontSize]]];
	[aView setAutomaticQuoteSubstitutionEnabled:NO]; // IB setting doesn't work for this.
	[aView setAutomaticTextReplacementEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
	[aView setAutomaticDashSubstitutionEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];

	/* Provided by Category `NSTextView+JSDExtensions` */

	[aView setShowsLineNumbers:[[localDefaults valueForKey:JSDKeyShowNewDocumentLineNumbers] boolValue]];
	[aView setWordwrapsText:NO];
}


/*———————————————————————————————————————————————————————————————————*
	windowControllerDidLoadNib:
		The nib is loaded.
 *———————————————————————————————————————————————————————————————————*/
- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];


	/* Create an OptionController and put it in place of optionPane. */

	if (!self.optionController)
	{
		self.optionController = [[OptionPaneController alloc] init];
	}

	self.optionController.optionsInEffect = [[PreferenceController sharedPreferences] optionsInEffect];

	[self.optionPane addSubview:self.optionController.view];


	/* Configure the text view settings */

	[self configureViewSettings:self.sourceView];
	[self configureViewSettings:self.tidyView];


	/* Honor the defaults system defaults. */

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];


	/*
		Make the optionController take the default values. This actually
		causes the empty document to go through processTidy one time.
	 */
	[self.optionController.tidyDocument takeOptionValuesFromDefaults:defaults];


	/*
		 Set the document options. This causes the empty document to go
		 through processTidy a second time.
	 */
	[self.tidyProcess optionsCopyValuesFromModel:self.optionController.tidyDocument];


	/* Saving behavior settings */

	self.fileWantsProtection = !(self.documentOpenedData == nil);


	/*
		Since this is startup, seed the tidyText view with this
		initial value for a blank document. If we're opening a
		document the event system will replace it forthwith.
	 */
	self.tidyView.string = self.tidyProcess.tidyText;


	/* 
		Setup for the Messages Table
		The value for key JSDKeyMessagesTableInitialSortKey should only
		ever be used this one time, unless the user deletes preferences.
	 */
	if (![[NSUserDefaults standardUserDefaults] objectForKey:JSDKeyMessagesTableSortDescriptors])
	{
		NSString *sortKeyFromPrefs = [[NSUserDefaults standardUserDefaults] valueForKey:JSDKeyMessagesTableInitialSortKey];

		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortKeyFromPrefs ascending:YES];

		[self.messagesArrayController setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	}


	/*
		Delay setting up notifications until now, because otherwise
		all of the earlier options setup is simply going to result
		in a huge cascade of notifications and updates.
	 */

	/* NSNotifications from the `optionController` indicate that one or more options changed. */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyOptionChange:)
												 name:tidyNotifyOptionChanged
											   object:[[self optionController] tidyDocument]];

	/* NSNotifications from the `tidyProcess` indicate that sourceText changed. */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidySourceTextChange:)
												 name:tidyNotifySourceTextChanged
											   object:[self tidyProcess]];

	/* NSNotifications from the `tidyProcess` indicate that tidyText changed. */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyTidyTextChange:)
												 name:tidyNotifyTidyTextChanged
											   object:[self tidyProcess]];

	/* NSNotifications from the `tidyProcess` indicate that the input-encoding might be wrong. */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyInputEncodingProblem:)
												 name:tidyNotifyPossibleInputEncodingProblem
											   object:[self tidyProcess]];

	/* 
		Will use KVC on the array controller instead of a delegate method to capture changes
		because the delegate doesn't catch when the table unselects all rows (meaning that
		highlighted text in the sourceText stays behind). This prevents that.
	 */
	[self.messagesArrayController addObserver:self
								   forKeyPath:@"selection"
									  options:(NSKeyValueObservingOptionNew)
									  context:NULL];


	/* Run through the new user helper if appropriate */

	if (![[[NSUserDefaults standardUserDefaults] valueForKey:JSDKeyFirstRunComplete] boolValue])
	{
		[self kickOffFirstRunSequence:nil];
	}

	/*
		self.documentIsLoading is used later to prevent some multiple
		notifications that aren't needed, and represents that we've
		loaded data from a file. We will also set the tidyProcess'
		source text (nil assigment is okay).
	 */
	self.documentIsLoading = !(self.documentOpenedData == nil);

	[self.tidyProcess setSourceTextWithData:[self documentOpenedData]];
}


/*———————————————————————————————————————————————————————————————————*
	windowNibName
		Return the name of the Nib associated with this class.
 *———————————————————————————————————————————————————————————————————*/
- (NSString *)windowNibName
{
	return @"TidyDocument";
}


#pragma mark - File I/O Handling


/*———————————————————————————————————————————————————————————————————*
	readFromURL:ofType:error:
		Called as part of the responder chain. We already have a
		name and type as a result of
			(1) the file picker, or
			(2) opening a document from Finder. 
		Here, we'll merely load the file contents into an NSData,
		and process it when the nib awakes (since we're	likely to be
		called here before the nib and its controls exist).
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)readFromURL:(NSString *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	/* Save the data for use until after the Nib is awake. */
	self.documentOpenedData = [NSData dataWithContentsOfFile:absoluteURL];

	return YES;
}


/*———————————————————————————————————————————————————————————————————*
	revertToContentsOfURL:ofType:error:
		Allow the default reversion to take place, and then put the
		correct value in the editor if it took place. The inherited
		method does |readFromFile|, so put the documentOpenedData
		into our |tidyProcess|.
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL didRevert;

	if ((didRevert = [super revertToContentsOfURL:absoluteURL ofType:typeName error:outError]))
	{
		self.documentIsLoading = YES;
		
		[self.tidyProcess setSourceTextWithData:[self documentOpenedData]];
	}

	return didRevert;
}


/*———————————————————————————————————————————————————————————————————*
	dataOfType:error:
		Called as a result of saving files. All we're going to do is
		pass back the NSData taken from the TidyDoc, using the
		encoding specified by `output-encoding`.
 *———————————————————————————————————————————————————————————————————*/
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	return self.tidyProcess.tidyTextAsData;
}


/*———————————————————————————————————————————————————————————————————*
	writeToUrl:ofType:error:
		Called as a result of saving files, and does the actual
		writing. We're going to override it so that we can update
		the |sourceView| automatically any time the file is saved.
		Setting |sourceView| will kick off the |textDidChange| event
		chain, which will set [tidyProcess sourceText] for us later.
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL success = [super writeToURL:absoluteURL ofType:typeName error:outError];
	
	if (success)
	{
		self.sourceView.string = self.tidyProcess.tidyText;
		
		/* force the event cycle so errors can be updated. */
		self.tidyProcess.sourceText = self.sourceView.string;
		
		self.fileWantsProtection = NO;
	}
	
	return success;
}


/*———————————————————————————————————————————————————————————————————*
	saveDocument:
		We're going to override the default save to make sure we
		can comply with the user's preferences. We're going to be
		over-protective because we don't want to get blamed for
		screwing up the user's data if Tidy doesn't process 
		something correctly.
 *———————————————————————————————————————————————————————————————————*/
- (IBAction)saveDocument:(id)sender
{
	NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];
	
	/*
		Warning will only apply if there's a current file
		and it's NOT been saved yet, and it's not new.
	 */
	if ( ([[localDefaults valueForKey:JSDKeySavingPrefStyle] longValue] == kJSDSaveButWarn) &&
		 (self.fileWantsProtection) &&
		 (self.fileURL.path.length > 0) )
	{
		NSInteger i = NSRunAlertPanel(NSLocalizedString(@"WarnSaveOverwrite", nil),
									  NSLocalizedString(@"WarnSaveOverwriteExplain", nil),
									  NSLocalizedString(@"continue save", nil),
									  NSLocalizedString(@"do not save", nil),
									  nil);
		
		if (i == NSAlertAlternateReturn)
		{
			return; // User chose don't save.
		}
	}

	/* Save is completely disabled -- tell user to Save As… */

	if ( ([[localDefaults valueForKey:JSDKeySavingPrefStyle] longValue] == kJSDSaveAsOnly) &&
		(self.fileWantsProtection) )
	{
		NSRunAlertPanel(NSLocalizedString(@"WarnSaveDisabled", nil),
						NSLocalizedString(@"WarnSaveDisabledExplain", nil),
						NSLocalizedString(@"cancel", nil),
						nil,
						nil);
		
		return; // Don't continue the save operation
	}

	return [super saveDocument:sender];
}


#pragma mark - Printing Support


/*———————————————————————————————————————————————————————————————————*
	printDocumentWithSettings:error:
 *———————————————————————————————————————————————————————————————————*/
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings
										   error:(NSError **)outError
{
	//NSTextView *virginView = [[NSTextView alloc] init];

	NSTextView *virginView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 468, 648)];

	virginView.string = _sourceView.string;

	[self.printInfo setHorizontalPagination: NSFitPagination];
	[self.printInfo setVerticalPagination: NSAutoPagination];
	[self.printInfo setVerticallyCentered:NO];
	[self.printInfo setLeftMargin:36];
	[self.printInfo setRightMargin:36];
	[self.printInfo setTopMargin:36];
	[self.printInfo setBottomMargin:36];

	return [NSPrintOperation printOperationWithView:_tidyView printInfo:self.printInfo];
}


#pragma mark - AppleScript Support


/*———————————————————————————————————————————————————————————————————*
	sourceText
 *———————————————————————————————————————————————————————————————————*/
- (NSString *)sourceText
{
	return self.sourceView.string;
}

- (void)setSourceText:(NSString *)sourceText
{
	self.sourceView.string = sourceText;
	
	[self textDidChange:nil];
}

/*———————————————————————————————————————————————————————————————————*
	tidyText
 *———————————————————————————————————————————————————————————————————*/
- (NSString *)tidyText
{
	return self.tidyView.string;
}


#pragma mark - Tidy-related Event Handling


/*———————————————————————————————————————————————————————————————————*
	handleTidyOptionChange:
		One or more options changed in |optionController|. Copy
		those options to our |tidyProcess|. The event chain will
		eventually update everything else because this should
		cause the tidyText to change.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidyOptionChange:(NSNotification *)note
{
	[self.tidyProcess optionsCopyValuesFromModel:self.optionController.tidyDocument];
}


/*———————————————————————————————————————————————————————————————————*
	handleTidySourceTextChange:
		The tidyProcess changed the sourceText for some reason,
		probably because the user changed input-encoding. Note
		that this event is only received if Tidy itself changes
		the sourceText, not as the result of outside setting.
		The event chain will eventually update everything else.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidySourceTextChange:(NSNotification *)note
{
	self.sourceView.string = self.tidyProcess.sourceText;
}


/*———————————————————————————————————————————————————————————————————*
	handleTidyTidyTextChange:
		`tidyText` changed, so update `tidyView`.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidyTidyTextChange:(NSNotification *)note
{
	self.tidyView.string = self.tidyProcess.tidyText;
}


/*———————————————————————————————————————————————————————————————————*
	handleTidyInputEncodingProblem:
		The input-encoding might have been wrong for the file
		that tidy is trying to process.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidyInputEncodingProblem:(NSNotification*)note
{
	NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];

	if (![[localDefaults valueForKey:JSDKeyIgnoreInputEncodingWhenOpening] boolValue])
	{
		NSStringEncoding suggestedEncoding    = [[[note userInfo] objectForKey:@"suggestedEncoding"] longValue];
		
		NSString         *encodingSuggested   = [NSString localizedNameOfStringEncoding:suggestedEncoding];

		NSStringEncoding currentInputEncoding = self.tidyProcess.inputEncoding;
		
		NSString         *encodingCurrent     = [NSString localizedNameOfStringEncoding:currentInputEncoding];

		NSString *docName    = self.fileURL.lastPathComponent;

		NSString *newMessage = [NSString stringWithFormat:self.textFieldEncodingExplanation.stringValue, docName, encodingCurrent, encodingSuggested];

		self.textFieldEncodingExplanation.stringValue = newMessage;

		self.buttonEncodingAllowChange.tag = suggestedEncoding;	// We'll fetch this later in popoverHandler.

		self.sourceView.editable = NO;

		[self.popoverEncoding showRelativeToRect:self.sourceView.bounds
										  ofView:self.sourceView
								   preferredEdge:NSMaxYEdge];
	}
}


/*———————————————————————————————————————————————————————————————————*
	textDidChange:
		We arrived here by virtue of being the delegate of
		`sourceView`. Simply update the tidyProcess sourceText,
		and the event chain will eventually update everything
		else.
 *———————————————————————————————————————————————————————————————————*/
- (void)textDidChange:(NSNotification *)aNotification
{
	/*
		If we're still in the loading stages, then simply flip the
		flag and don't set any text. All we're doing is preventing
		the tidyProcess from an extra, useless round of processing.
		We will be called again in the document loading process.
	 */
	if (!self.documentIsLoading)
	{
		self.tidyProcess.sourceText = self.sourceView.string;
	}
	else
	{
		self.documentIsLoading = NO;
	}
	
	
	/* Handle document dirty detection. */
	
	if ( (!self.tidyProcess.isDirty) || (self.tidyProcess.sourceText.length == 0) )
	{
		[self updateChangeCount:NSChangeCleared];
	}
	else
	{
		[self updateChangeCount:NSChangeDone];
	}

}


#pragma mark - Document Opening Encoding Error Support


/*———————————————————————————————————————————————————————————————————*
	popoverEncodingHandler:
		Handles all possibles actions from the input-encoding
		helper popover. The only two senders should be
		buttonAllowChange and buttonIgnoreSuggestion.
 *———————————————————————————————————————————————————————————————————*/
- (IBAction)popoverEncodingHandler:(id)sender
{
	if (sender == self.buttonEncodingAllowChange)
	{
		JSDTidyOption *localOption = self.optionController.tidyDocument.tidyOptions[@"input-encoding"];

		localOption.optionValue = [@(self.buttonEncodingAllowChange.tag) stringValue];
	}

	self.sourceView.editable = YES;
	
	[self.popoverEncoding performClose:self];
}


#pragma mark - First-Run Support


/*———————————————————————————————————————————————————————————————————*
	kickOffFirstRunSequence:
		Kicks off the first run sequence. Exposed so we can handle
		requests as the first responder.
 *———————————————————————————————————————————————————————————————————*/
- (IBAction)kickOffFirstRunSequence:(id)sender;
{
	NSArray *firstRunSteps = @[
							   @{ @"message": NSLocalizedString(@"popOverExplainWelcome", nil),
								  @"showRelativeToRect": NSStringFromRect(self.sourceView.bounds),
								  @"ofView": self.sourceView,
								  @"preferredEdge": @(NSMinXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainTidyOptions", nil),
								  @"showRelativeToRect": NSStringFromRect(self.optionPane.bounds),
								  @"ofView": self.optionPane,
								  @"preferredEdge": @(NSMinXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainSourceView", nil),
								  @"showRelativeToRect": NSStringFromRect(self.sourceView.bounds),
								  @"ofView": self.sourceView,
								  @"preferredEdge": @(NSMinXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainTidyView", nil),
								  @"showRelativeToRect": NSStringFromRect(self.tidyView.bounds),
								  @"ofView": self.tidyView,
								  @"preferredEdge": @(NSMinXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainErrorView", nil),
								  @"showRelativeToRect": NSStringFromRect(self.errorView.bounds),
								  @"ofView": self.errorView,
								  @"preferredEdge": @(NSMinXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainPreferences", nil),
								  @"showRelativeToRect": NSStringFromRect(self.optionPane.bounds),
								  @"ofView": self.optionPane,
								  @"preferredEdge": @(NSMinXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainSplitters", nil),
								  @"showRelativeToRect": NSStringFromRect(self.optionPane.bounds),
								  @"ofView": self.optionPane,
								  @"preferredEdge": @(NSMaxXEdge) },

							   @{ @"message": NSLocalizedString(@"popOverExplainStart", nil),
								  @"showRelativeToRect": NSStringFromRect(self.tidyView.bounds),
								  @"ofView": self.tidyView,
								  @"preferredEdge": @(NSMinYEdge) },
							   ];

	self.firstRun = [[FirstRunController alloc] initWithSteps:firstRunSteps];
		
	self.firstRun.preferencesKeyName = JSDKeyFirstRunComplete;

	[self.firstRun beginFirstRunSequence];
}


/*———————————————————————————————————————————————————————————————————*
	validateUserInterfaceItem:
		Validates whether a user interface item should or should not
		be enabled. We're using it to ensure that the first run
		helper menu item isn't enabled if the first run helper is
		already displayed.
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    SEL theAction = [anItem action];

    if (theAction == @selector(kickOffFirstRunSequence:))
	{
		return !(BOOL)[self.firstRun valueForKeyPath:@"popoverFirstRun.shown"];
    }

    return [super validateUserInterfaceItem:anItem];
}


#pragma mark - KVC Notification Handling


/*———————————————————————————————————————————————————————————————————*
	observeValueForKeyPath:ofObject:change:context:
		Handle KVC Notifications:
		- error view selection changed.
 *———————————————————————————————————————————————————————————————————*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	/* Handle changes to the selection of the messages table. */

	if ((object == self.messagesArrayController) && ([keyPath isEqualToString:@"selection"]))
	{
		self.sourceView.showsHighlight = NO;

		NSArray *localObjects = self.messagesArrayController.arrangedObjects;

		NSInteger errorViewRow = self.messagesArrayController.selectionIndex;

		if ((errorViewRow >= 0) && (errorViewRow < [localObjects count]))
		{
			NSInteger row = [localObjects[errorViewRow][@"line"] intValue];

			NSInteger col = [localObjects[errorViewRow][@"column"] intValue];

			if (row > 0)
			{
				[self.sourceView highlightLine:row Column:col];
				
				return;
			}
		}
	}
}


#pragma mark - Split View handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:constrainMinCoordinate:ofSubviewAt:
		We're here because we're the delegate of the split views.
		This allows us to set the minimum constraint of the left/top
		item in a splitview. Must coordinate max to ensure others
		have space, too.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition
														 ofSubviewAt:(NSInteger)dividerIndex
{
	/* The main splitter. */
	
	if (splitView == self.splitLeftRight)
	{
		return 300.0f;
	}
	
	/* The text views' first splitter. */
	
	if (dividerIndex == 0)
	{
		return 68.0f;
	}
	
	/* The text views' second splitter is first plus 68.0f;. */
	
    return [splitView.subviews[0] frame].size.height + 68.0f;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:constrainMaxCoordinate:ofSubviewAt:
		We're here because we're the delegate of the split views.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMinimumPosition
														 ofSubviewAt:(NSInteger)dividerIndex
{
	/* The main splitter. */
	
	if (splitView == self.splitLeftRight)
	{
		return splitView.frame.size.width - 150.0f;
	}
	
	/* The text views' first splitter. */
	
	if (dividerIndex == 0)
	{
		return [splitView.subviews[0] frame].size.height + [splitView.subviews[1] frame].size.height - 68.0f;
	}
	
	/* The text views' second splitter. */
	
	return [splitView frame].size.height - 68.0f;	
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:shouldAdjustSizeOfSubview:
		We're here because we're the delegate of the split views.
		Prevent the left pane from resizing during window resize.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	if (splitView == self.splitLeftRight)
	{
		if (subview == [self.splitLeftRight subviews][0])
		{
			return NO;
		}
	}
	
	return YES;
}


#pragma mark - Tab key handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	textView:doCommandBySelector:
		We're here because we're the delegate of `sourceView`.
		Allow the tab key to back in and out of this view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
	if (aSelector == @selector(insertTab:))
	{
		[aTextView.window selectNextKeyView:nil];
		return YES;
	}
	
	if (aSelector == @selector(insertBacktab:))
	{
		[aTextView.window selectPreviousKeyView:nil];
		return YES;
	}
	
	return NO;
}


@end
