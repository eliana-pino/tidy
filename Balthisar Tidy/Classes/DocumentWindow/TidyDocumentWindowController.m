/**************************************************************************************************

	TidyDocumentWindowController
	 
	The main document window controller; manages the view and UI for a TidyDocument window.


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

#import "TidyDocumentWindowController.h"
#import "PreferencesDefinitions.h"
#import "PreferenceController.h"
#import "JSDTidyModel.h"
#import "TidyDocument.h"
#import "OptionPaneController.h"
#import "NSTextView+JSDExtensions.h"
#import "FirstRunController.h"
#import "EncodingHelperController.h"


@implementation TidyDocumentWindowController


#pragma mark - Initialization and Deallocation


/*———————————————————————————————————————————————————————————————————*
	init
 *———————————————————————————————————————————————————————————————————*/
- (instancetype)init
{
	self = [super initWithWindowNibName:@"TidyDocumentWindow"];

	if (self)
	{
		// Nothing to see here.
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

	[self.messagesArrayController removeObserver:self forKeyPath:@"selection"];
}


#pragma mark - Setup


/*———————————————————————————————————————————————————————————————————*
	windowDidLoad
		This method handles initialization after the window 
		controller's window has been loaded from its nib file.
 *———————————————————————————————————————————————————————————————————*/
- (void)windowDidLoad
{
    [super windowDidLoad];


	/* Create an OptionController and put it in place of optionPane. */

	if (!self.optionController)
	{
		self.optionController = [[OptionPaneController alloc] init];
	}

	[self.optionPane addSubview:self.optionController.view];

	self.optionController.optionsInEffect = [[PreferenceController sharedPreferences] optionsInEffect];

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
		Make the local processor take the default values. This causes
		the empty document to go through processTidy a second time.
	 */
	[self.tidyProcess takeOptionValuesFromDefaults:defaults];


	/*
		Since this is startup, seed the tidyText view with this
		initial value for a blank document. If we're opening a
		document the event system will replace it a bit later.
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


#pragma mark - Document Property Accessors


/*———————————————————————————————————————————————————————————————————*
	tidyProcess
		Will use the document controller's tidyProcess.
 *———————————————————————————————————————————————————————————————————*/
- (JSDTidyModel*)tidyProcess
{
	TidyDocument *localDocument = self.document;
	return localDocument.tidyProcess;
}


/*———————————————————————————————————————————————————————————————————*
	documentOpenedData
		Will use the document controller's documentOpenedData.
 *———————————————————————————————————————————————————————————————————*/
- (NSData*)documentOpenedData
{
	TidyDocument *localDocument = self.document;
	return localDocument.documentOpenedData;
}


#pragma mark - Event Handling


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
		We're here as the result of a notification. The value for
		input-encoding might have been wrong for the file
		that tidy is trying to process.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidyInputEncodingProblem:(NSNotification*)note
{
	if (![[[NSUserDefaults standardUserDefaults] valueForKey:JSDKeyIgnoreInputEncodingWhenOpening] boolValue])
	{
		self.encodingHelper = [[EncodingHelperController alloc] initWithNote:note fromDocument:self.document forView:self.sourceView];

		[self.encodingHelper startHelper];
	}
}


/*———————————————————————————————————————————————————————————————————*
	documentDidWriteFile
		We're here because the TidyDocument indicated that it
		wrote a file. We have to update the view to reflect the
		new, saved state.
 *———————————————————————————————————————————————————————————————————*/
- (void)documentDidWriteFile
{
	self.sourceView.string = self.tidyProcess.tidyText;

	/* force the event cycle so errors can be updated. */
	self.tidyProcess.sourceText = self.sourceView.string;
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
		[self.document updateChangeCount:NSChangeCleared];
	}
	else
	{
		[self.document updateChangeCount:NSChangeDone];
	}

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

    return NO;
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
