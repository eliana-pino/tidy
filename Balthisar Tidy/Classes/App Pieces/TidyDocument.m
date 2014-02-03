/**************************************************************************************************

	TidyDocument.m

	part of Balthisar Tidy

	The main document controller. Here we'll control the following:

		o


	The MIT License (MIT)

	Copyright (c) 2001 to 2013 James S. Derry <http://www.balthisar.com>

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
 
		The Tidy processor is loosely couple with the document controller. Most
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
#import "PreferenceController.h"
#import "JSDTidyDocument.h"
#import "NSTextView+JSDExtensions.h"


#pragma mark - Non-Public iVars, Properties, and Method declarations


@interface TidyDocument ()
{
	JSDTidyDocument *tidyProcess;			// Our tidy processor.
	
	NSInteger saveBehavior;					// The save behavior from the preferences.
	BOOL saveWarning;						// The warning behavior for when saveBehavior == 1;
	BOOL yesSavedAs;						// Disable warnings and protections once a save-as has been done.
	
	NSData *documentOpenedData;				// Hold the file that we opened with until the nib is awake.
	
	BOOL documentIsLoading;					// Flag to indicate that new data was loaded from disk (see notes above)
}

@property (assign) IBOutlet NSSplitView *splitLeftRight;	// The left-right (main) split view in the Doc window.
@property (assign) IBOutlet NSSplitView *splitTopDown;		// Top top-to-bottom split view in the Doc window.

@end


#pragma mark - Implementation


@implementation TidyDocument


#pragma mark - File I/O Handling


/*———————————————————————————————————————————————————————————————————*
	readFromFile:
		Called as part of the responder chain. We already have a
		name and type as a result of
			(1) the file picker, or
			(2) opening a document from Finder. 
		Here, we'll merely load the file contents into an NSData,
		and process it when the nib awakes (since we're	likely to be
		called here before the nib and its controls exist).
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)readFromFile:(NSString *)filename ofType:(NSString *)docType
{
	// Save the data for use until after the Nib is awake.
	documentOpenedData = [[NSData dataWithContentsOfFile:filename] retain];
		
	return YES;
}


/*———————————————————————————————————————————————————————————————————*
	revertToSavedFromFile:ofType
		Allow the default reversion to take place, and then put the
		correct value in the editor if it took place. The inherited
		method does |readFromFile|, so put the documentOpenedData
		into our |tidyProcess|.
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)revertToSavedFromFile:(NSString *)fileName ofType:(NSString *)type
{
	BOOL didRevert;
	
	if ((didRevert = [super revertToSavedFromFile:fileName ofType:type]))
	{
		documentIsLoading = YES;
		[tidyProcess setSourceTextWithData:documentOpenedData];
	}
	
	return didRevert;
}


/*———————————————————————————————————————————————————————————————————*
	dataOfType:error
		Called as a result of saving files. All we're going to do is
		pass back the NSData taken from the TidyDoc, using the
		encoding specified by `output-encoding`.
 *———————————————————————————————————————————————————————————————————*/
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	return [tidyProcess tidyTextAsData];
}


/*———————————————————————————————————————————————————————————————————*
	writeToUrl:ofType:Error
		Called as a result of saving files, and does the actual
		writing. We're going to override it so that we can update
		the |sourceView| automatically any time the file is saved.
		The logic is once the file is saved the |sourceview| ought
		to reflect the actual file contents, which is the tidy'd
		view.
 *———————————————————————————————————————————————————————————————————*/
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL success = [super writeToURL:absoluteURL ofType:typeName error:outError];
	
	if (success)
	{
		/*
			Setting |sourceView| will kick off the |textDidChange|
			event chain, which will set [tidyProcess sourceText]
			for us later.
		*/
		[_sourceView setString:[tidyProcess sourceText]];

		yesSavedAs = YES;
	}
	
	return success;
}


/*———————————————————————————————————————————————————————————————————*
	saveDocument
		we're going to override the default save to make sure we
		can comply with the user's preferences. We're going to be
		over-protective because we don't want to get blamed for
		screwing up the user's data if Tidy doesn't process 
		something correctly.
 *———————————————————————————————————————————————————————————————————*/
- (IBAction)saveDocument:(id)sender
{
	/*
		Normal save, but with a warning and chance to back out. Here's
		the logic for how this works:
			(1) the user requested a warning before overwriting 
			    original files.
			(2) the |sourceView| isn't empty.
			(3) the file hasn't been saved already. This last is
				important, because if the file has already been
				edited and saved, there's no longer an "original" 
				file to protect.
	*/

	// Warning will only apply if there's a current file and it's NOT been saved yet, and it's not new.
	if ( (saveBehavior == 1) && 				// Behavior is protective AND
		(saveWarning) &&						// We want to have a warning AND
		(yesSavedAs == NO) && 					// We've NOT yet done a save as... AND
		([[[self fileURL] path] length] != 0 ))	// The file name isn't zero length.
	{
		NSInteger i = NSRunAlertPanel(NSLocalizedString(@"WarnSaveOverwrite", nil), NSLocalizedString(@"WarnSaveOverwriteExplain", nil),
									  NSLocalizedString(@"continue save", nil), NSLocalizedString(@"do not save", nil) , nil);
		
		if (i == NSAlertAlternateReturn)
		{
			return; // Don't continue the save operation if user chose don't save.
		}
	}

	// Save is completely disabled -- tell user to Save As…
	if (saveBehavior == 2)
	{
		NSRunAlertPanel(NSLocalizedString(@"WarnSaveDisabled", nil), NSLocalizedString(@"WarnSaveDisabledExplain", nil),
						NSLocalizedString(@"cancel", nil), nil, nil);
		
		return; // Don't continue the save operation
	}

	return [super saveDocument:sender];
}


#pragma mark - Initialization, Destruction, and Setup


/*———————————————————————————————————————————————————————————————————*
	init
		Our creator -- create the |tidyProcess| and the |processString|.
		Also be registered to receive preference notifications for the
		file-saving preferences.
 *———————————————————————————————————————————————————————————————————*/
- (id)init
{
	self = [super init];
	if (self)
	{
		tidyProcess = [[JSDTidyDocument alloc] init];	// Use our own |tidyProcess|.
		
		documentOpenedData = nil;
	}
	
	return self;
}


/*———————————————————————————————————————————————————————————————————*
	dealloc
 *———————————————————————————————————————————————————————————————————*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:JSDSavePrefChange object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifyOptionChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifySourceTextChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifyTidyTextChanged object:nil];
	
	[documentOpenedData release];
	[tidyProcess release];
	[_optionController release];
	
	[super dealloc];
}


/*———————————————————————————————————————————————————————————————————*
	configureViewSettings
		Given aView, make it non-wrapping. Also set fonts.
 *———————————————————————————————————————————————————————————————————*/
- (void)configureViewSettings:(NSTextView *)aView
{
	[aView setFont:[NSFont fontWithName:@"Courier" size:12]];	// Set the font for the views.
	[aView setRichText:NO];										// Don't allow rich text.
	[aView setUsesFontPanel:NO];								// Don't allow the font panel.
	[aView setContinuousSpellCheckingEnabled:NO];				// Turn off spell checking.
	[aView setSelectable:YES];									// Text can be selectable.
	[aView setEditable:NO];										// Text shouldn't be editable.
	[aView setImportsGraphics:NO];								// Don't let user import graphics.
	[aView setWordwrapsText:NO];								// Provided by category `NSTextView+JSDExtensions`
	[aView setShowsLineNumbers:YES];							// Provided by category `NSTextView+JSDExtensions`
}


/*———————————————————————————————————————————————————————————————————*
	awakeFromNib
		When we wake from the nib file, setup the option controller.
 *———————————————————————————————————————————————————————————————————*/
- (void) awakeFromNib
{
	// Create a OptionPaneController and put it in place of optionPane.
	if (!_optionController)
	{
		_optionController = [[OptionPaneController alloc] init];
	}
	
	[_optionController putViewIntoView:_optionPane];
}


/*———————————————————————————————————————————————————————————————————*
	windowControllerDidLoadNib:
		The nib is loaded. If there's a string in processString, it
		will appear in the |sourceView|.
 *———————————————————————————————————————————————————————————————————*/
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	[super windowControllerDidLoadNib:aController];

	
	[self configureViewSettings:_sourceView];
	[self configureViewSettings:_tidyView];
	[_sourceView setEditable:YES];

	
	// Honor the defaults system defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];			// Get the default default system
	[[_optionController tidyDocument] takeOptionValuesFromDefaults:defaults];	// Make the optionController take the values

	
	// Saving behavior settings
	saveBehavior = [defaults integerForKey:JSDKeySavingPrefStyle];
	saveWarning = [defaults boolForKey:JSDKeyWarnBeforeOverwrite];
	yesSavedAs = NO;

	
	// Set the document options.
	[tidyProcess optionCopyFromDocument:[_optionController tidyDocument]];

	
	/*
		Delay setting up notifications until now, because otherwise
		all of the earlier options setup is simply going to result
		in a huge cascade of notifications and updates.
	*/
	
	// NSNotifications from the Preference Controller indicate saving preferences changed.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleSavePrefChange:)
												 name:JSDSavePrefChange
											   object:_optionController];
	
	// NSNotifications from the |optionController| indicate that one or more options changed.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyOptionChange:)
												 name:tidyNotifyOptionChanged
											   object:[_optionController tidyDocument]];
	
	// NSNotifications from the tidyProcess indicate that sourceText changed.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidySourceTextChange:)
												 name:tidyNotifySourceTextChanged
											   object:tidyProcess];
	
	// NSNotifications from the tidyProcess indicate that tidyText changed.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidyTidyTextChange:)
												 name:tidyNotifyTidyTextChanged
											   object:tidyProcess];
	
	
	// Set the tidyProcess data. The event system will set the view later.
	documentIsLoading = YES;
	[tidyProcess setSourceTextWithData:documentOpenedData];
}


/*———————————————————————————————————————————————————————————————————*
	windowNibName
		Return the name of the Nib associated with this class.
 *———————————————————————————————————————————————————————————————————*/
- (NSString *)windowNibName
{
	return @"TidyDocument";
}


#pragma mark - Tidy-related Event Handling


/*———————————————————————————————————————————————————————————————————*
	handleSavePrefChange
		This method receives "JSDSavePrefChange" notifications so
		we can keep abreast of the user's desired "Save" behaviours.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleSavePrefChange:(NSNotification *)note
{
	saveBehavior = [[NSUserDefaults standardUserDefaults] integerForKey:JSDKeySavingPrefStyle];
	saveWarning = [[NSUserDefaults standardUserDefaults] boolForKey:JSDKeyWarnBeforeOverwrite];
}


/*———————————————————————————————————————————————————————————————————*
	handleTidyOptionChange
		One or more options changed in |optionController|. Copy
		those options to our |tidyProcess|. The event chain will
		eventually update everything else because this should
		cause the tidyText to change.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidyOptionChange:(NSNotification *)note
{
	[tidyProcess optionCopyFromDocument:[_optionController tidyDocument]];
}


/*———————————————————————————————————————————————————————————————————*
	handleTidySourceTextChange
		The tidyProcess changed the sourceText for some reason,
		probably because the user changed input-encoding. Note
		that this event is only received if Tidy itself changes
		the sourceText, not as the result of outside setting.
		The event chain will eventually update everything else.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidySourceTextChange:(NSNotification *)note
{
	[_sourceView setString:[tidyProcess sourceText]];
}


/*———————————————————————————————————————————————————————————————————*
	handleTidyTidyTextChange
		|tidyText| changed, so update |tidyView| and |errorView|.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidyTidyTextChange:(NSNotification *)note
{
	[_tidyView setString:[tidyProcess tidyText]];			// Put the tidy'd text into the |tidyView|.
	[_errorView reloadData];								// Reload the error data.
	[_errorView deselectAll:self];							// Deselect the selected row.

	// TODO: is this better off in textDidChange?
	// Handle document dirty detection
	if ( (![tidyProcess isDirty]) || ([[tidyProcess sourceText] length] == 0 ) )
	{
		[self updateChangeCount:NSChangeCleared];
	}
	else
	{
		[self updateChangeCount:NSChangeDone];
	}
}


/*———————————————————————————————————————————————————————————————————*
	textDidChange:
		We arrived here by virtue of being the delegate of
		|sourceView|. Simply update the tidyProcess sourceText,
		and the event chain will eventually update everything
		else.
 *———————————————————————————————————————————————————————————————————*/
- (void)textDidChange:(NSNotification *)aNotification
{
	if (!documentIsLoading)
	{
		[tidyProcess setSourceText:[_sourceView string]];
	}
	else
	{
		documentIsLoading = NO;
	}
}


#pragma mark - Support for the Error Table


/*———————————————————————————————————————————————————————————————————*
	numberOfRowsInTableView
		We're here because we're the datasource of the table view.
		We need to specify how many items are in the table view.
 *———————————————————————————————————————————————————————————————————*/
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[tidyProcess errorArray] count];
}


/*———————————————————————————————————————————————————————————————————*
	tableView:objectValueForTableColumn:row
		We're here because we're the datasource of the table view.
		We need to specify what to show in the row/column. The
		error array consists of dictionaries with entries for
		`level`, `line`, `column`, and `message`.
 *———————————————————————————————————————————————————————————————————*/
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSDictionary *error = [tidyProcess errorArray][rowIndex];	// Get the current error

	// List of error types -- not localized; users can localize based on this string.
	NSArray *errorTypes = @[@"Info:", @"Warning:", @"Config:", @"Access:", @"Error:", @"Document:", @"Panic:"];

	// Handle returning the severity of the error, localized.
	if ([[aTableColumn identifier] isEqualToString:@"severity"])
	{
		return NSLocalizedString(errorTypes[[error[@"level"] intValue]], nil);
	}

	// Handle the location, localized, or "N/A" if not applicable
	if ([[aTableColumn identifier] isEqualToString:@"where"])
	{
		if (([error[@"line"] intValue] == 0) || ([error[@"column"] intValue] == 0))
		{
			return NSLocalizedString(@"N/A", nil);
		}
		return [NSString stringWithFormat:@"%@ %@, %@ %@", NSLocalizedString(@"line", nil), error[@"line"], NSLocalizedString(@"column", nil), error[@"column"]];
	}

	if ([[aTableColumn identifier] isEqualToString:@"description"])
	{
		return error[@"message"];
	}
	
	return @"";
}


/*———————————————————————————————————————————————————————————————————*
	errorClicked:
		We arrived here by virtue of this controller class and this
		method being the action of the table. Whenever the selection
		changes we're going to highlight and show the related
		column/row in the sourceView.
 *———————————————————————————————————————————————————————————————————*/
- (IBAction)errorClicked:(id)sender
{
	NSInteger errorViewRow = [_errorView selectedRow];
	if (errorViewRow >= 0)
	{
		NSInteger row = [[tidyProcess errorArray][errorViewRow][@"line"] intValue];
		NSInteger col = [[tidyProcess errorArray][errorViewRow][@"column"] intValue];
		[_sourceView highlightLine:row Column:col];
	}
	else 
	{
		[_sourceView setShowsHighlight:NO];
	}
}


/*———————————————————————————————————————————————————————————————————*
	tableViewSelectionDidChange:
		We arrived here by virtue of this controller class being the
		delegate of the table. Whenever the selection changes
		we're going to highlight and show the related column/row
		in the |sourceView|.
 *———————————————————————————————————————————————————————————————————*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	// Get the description of the selected row.
	if ([aNotification object] == _errorView)
	{
		[self errorClicked:self];
	}
}


#pragma mark - Split View Handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:constrainMinCoordinate:ofSubviewAt:
		We're here because we're the delegate of the split views.
		This allows us to set the minimum constrain of the left/top
		item in a splitview. Must coordinate max to ensure others
		have space, too.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	// The main splitter
	if (splitView == _splitLeftRight)
	{
		return 250.0f;
	}
	
	// The text views' first splitter
	if (dividerIndex == 0)
	{
		return 68.0f;
	}
	
	// The text views' second splitter is first plus 68.0f;
    return [[splitView subviews][0] frame].size.height + 68.0f;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:constrainMaxCoordinate:ofSubviewAt:
		We're here because we're the delegate of the split views.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	// The main splitter
	if (splitView == _splitLeftRight)
	{
		return [splitView frame].size.width - 150.0f;
	}
	
	// The text views' first splitter
	if (dividerIndex == 0)
	{
		return [[splitView subviews][0] frame].size.height +
				[[splitView subviews][1] frame].size.height - 68.0f;
	}
	
	
	// The text views' second splitter
	return [splitView frame].size.height - 68.0f;	
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	splitView:shouldAdjustSizeOfSubview:
		We're here because we're the delegate of the split views.
		Prevent the left pane from resizing during window resize.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	if (splitView == _splitLeftRight)
	{
		if (subview == [_splitLeftRight subviews][0])
		{
			return NO;
		}
	}
	return YES;
}


#pragma mark - tab key handling


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	textView:doCommandBySelector:
		We're here because we're the delegate of |sourceView|.
		Allow the tab key to back in and out of this view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(insertTab:))
	{
        [[aTextView window] selectNextKeyView:nil];
        return YES;
    }
	
    if (aSelector == @selector(insertBacktab:))
	{
        [[aTextView window] selectPreviousKeyView:nil];
        return YES;
    }
	
    return NO;
}


@end
