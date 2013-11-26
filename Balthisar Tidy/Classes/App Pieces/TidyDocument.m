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
	distribute, sublicense, and/or sell	copies of the Software, and to permit persons to whom the
	Software is	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 **************************************************************************************************/

/**************************************************************************************************
	NOTES ABOUT "DIRTY FILE" DETECTION
		We're doing a few convoluted things to allow undo in the
		sourceView while not messing up the document dirty flags.
		Essentially, whenever the [sourceView] <> [tidyView], we're going
		to call it dirty. Whenever we write a file, it's obviously fit to be the source file,
		and we can then put it in the sourceView.
 **************************************************************************************************/

/**************************************************************************************************
	NOTES ABOUT TYPE/CREATOR CODES
		Mac OS X has killed type/creator codes. Oh well. But they're still supported
		and I continue to believe they're better than Windows-ish file extensions. We're going
		to try to make everybody happy by doing the following:
			o	For files that Tidy creates by the user typing into the sourceView, we'll save them
				with the Tidy type/creator codes. We'll use WWS2 for Balthisar Tidy creator, and
				TEXT for filetype. (I shouldn't use WWS2 'cos that's Balthisar Cascade type!!!).
			o	For *existing* files that Tidy modifies, we'll check to see if type/creator already
				exists, and if so, we'll re-write with the existing type/creator, otherwise we'll
				not use any type/creator and let the OS do its own thing in Finder.
 **************************************************************************************************/

#import "TidyDocument.h"
#import "PreferenceController.h"
#import "JSDTidyDocument.h"
#import "NSTextView+JSDExtensions.h"

@implementation TidyDocument


#pragma mark -
#pragma mark FILE I/O HANDLING


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 readFromFile:
 Called as part of the responder chain. We already have a
 name and type as a result of (1) the file picker, or
 (2) opening a document from Finder. Here, we'll merely load
 the file contents into an NSData, and process it when the
 nib awakes (since we're	likely to be called here before the
 nib and its controls exist).
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (BOOL)readFromFile:(NSString *)filename ofType:(NSString *)docType
{
	[tidyProcess setOriginalTextWithData:[NSData dataWithContentsOfFile:filename]]; // give our tidyProcess the data.
	tidyOriginalFile = NO;															// the current file was OPENED, not a Tidy original.
	return YES;																		// yes, it was loaded successfully.
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 dataRepresentationOfType
 Called as a result of saving files. All we're going to do is
 pass back the NSData taken from the TidyDoc
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	return [tidyProcess tidyTextAsData];				// return the raw data in user-encoding to be written.
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 writeToFile
 Called as a result of saving files, and does the actual writing.
 We're going to override it so that we can update the sourceView
 automatically any time the file is saved. The logic is, once the
 file is saved, the sourceview ought to reflect the actual file
 contents, which is the tidy'd view.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type
{
	bool success = [super writeToFile:fileName ofType:type];	// inherited method does the actual saving
	if (success) {
		[tidyProcess setOriginalText:[tidyProcess tidyText]];	// make the tidyText the new originalText.
		[sourceView setString:[tidyProcess workingText]];		// update the sourceView with the newly-saved contents.
		yesSavedAs = YES;										// this flag disables the warnings, since they're meaningless now.
	}
	return success;
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 fileAttributesToWriteToFile:ofType:saveOperation
 Called as a result of saving files. We're going to support the
 use of HFS+ type/creator codes, since Cocoa doesn't do this
 automatically. We only do this on files that haven't been
 opened by Tidy. That way, Tidy-created documents show the Tidy
 icons, and documents that were merely opened retain thier
 original file associations. We COULD make this a preference
 item such that Tidy will always add type/creator codes.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)fullDocumentPath
									   ofType:(NSString *)documentTypeName
								saveOperation:(NSSaveOperationType)saveOperationType
{
	// get the inherited dictionary.
	NSMutableDictionary *myDict = (NSMutableDictionary *)[super fileAttributesToWriteToFile:fullDocumentPath ofType:documentTypeName saveOperation:saveOperationType];
	// ONLY add type/creator if this is an original file -- NOT if we opened the file.
	if (tidyOriginalFile) {
		myDict[NSFileHFSCreatorCode] = @('WWS2');	// set creator code.
		myDict[NSFileHFSTypeCode] = @('TEXT');		// set file type.
	} else { // use original type/creator codes, if any.
		OSType macType = [ [ [ NSFileManager defaultManager ] fileAttributesAtPath: fullDocumentPath traverseLink: YES ] fileHFSTypeCode];
		OSType macCreator = [ [ [ NSFileManager defaultManager ] fileAttributesAtPath: fullDocumentPath traverseLink: YES ] fileHFSCreatorCode];
		if ((macType != 0) && (macCreator != 0)) {
			myDict[NSFileHFSCreatorCode] = @(macCreator);
			myDict[NSFileHFSTypeCode] = @(macType);
		}
	}
	return myDict;
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 revertToSavedFromFile:ofType
 allow the default reversion to take place, and then put the
 correct value in the editor if it took place. The inherited
 method does readFromFile, so our tidyProcess will already
 have the reverted data.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (BOOL)revertToSavedFromFile:(NSString *)fileName ofType:(NSString *)type
{
	bool didRevert = [super revertToSavedFromFile:fileName ofType:type];
	if (didRevert)
	{
		[sourceView setString:[tidyProcess workingText]];	// update the display, since the reversion already loaded the data.
		[self retidy];										// retidy the document.
	}
	return didRevert;										// flag whether we reverted or not.
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 saveDocument
 we're going to override the default save to make sure we can
 comply with the user's preferences. We're being over-protective
 because we want to not get blamed for screwing up the users'
 data if Tidy doesn't process something correctly.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (IBAction)saveDocument:(id)sender
{
	// normal save, but with a warning and chance to back out. Here's the logic for how this works:
	// (1) the user requested a warning before overwriting original files.
	// (2) the sourceView isn't empty.
	// (3) the file hasn't been saved already. This last is important, because if the file has
	//		already been edited and saved, there's no longer an "original" file to protect.

	// warning will only apply if there's a current file and it's NOT been saved yet, and it's not new.
	if ( (saveBehavior == 1) && 		// behavior is protective AND
		(saveWarning) &&				// we want to have a warning AND
		(yesSavedAs == NO) && 			// we've NOT yet done a save as... AND
		([[[self fileURL] path] length] != 0 ))
	{	// the filename isn't zero length
		NSInteger i = NSRunAlertPanel(NSLocalizedString(@"WarnSaveOverwrite", nil), NSLocalizedString(@"WarnSaveOverwriteExplain", nil),
									  NSLocalizedString(@"continue save", nil),NSLocalizedString(@"do not save", nil) , nil);
		if (i == NSAlertAlternateReturn)
			return; // don't let user continue the save operation if he chose don't save.
	}

	// save is completely disabled -- tell user to Save AsÉ
	if (saveBehavior == 2) {
		NSRunAlertPanel(NSLocalizedString(@"WarnSaveDisabled", nil), NSLocalizedString(@"WarnSaveDisabledExplain", nil),
						NSLocalizedString(@"cancel", nil), nil, nil);
		return; // don't let user continue the save operation.
	} // if

	return [super saveDocument:sender];
}


#pragma mark -
#pragma mark INITIALIZATION, DESTRUCTION, AND SETUP


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 init
 Our creator -- create the tidy processor and the processString.
 Also be registered to receive preference notifications for the
 file-saving preferences.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (id)init
{
	if ([super init]) {
		tidyOriginalFile = YES;							// if yes, we'll write file/creator codes.
		tidyProcess = [[JSDTidyDocument alloc] init];	// use our own tidy process, NOT the controller's instance.
		// register for notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSavePrefChange:) name:@"JSDSavePrefChange" object:nil];
	} // if
	return self;
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 dealloc
 our destructor -- get rid of the tidy processor and processString
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];	// remove ourselves from the notification center!
	[tidyProcess release];			// release the tidyProcess.
	[optionController release];		// remove the optionController pane.
	[super dealloc];				// do the inherited dealloc.
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 configureViewSettings
 given aView, make it non-wrapping. Also set fonts.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)configureViewSettings:(NSTextView *)aView
{
	[aView setFont:[NSFont fontWithName:@"Courier" size:12]];	// set the font for the views.
	[aView setRichText:NO];										// don't allow rich text.
	[aView setUsesFontPanel:NO];								// don't allow the font panel.
	[aView setContinuousSpellCheckingEnabled:NO];				// turn off spell checking.
	[aView setSelectable:YES];									// text can be selectable.
	[aView setEditable:NO];										// text shouldn't be editable.
	[aView setImportsGraphics:NO];								// don't let user import graphics.
	[aView setWordwrapsText:NO];
	[aView setShowsLineNumbers:YES];

}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 awakeFromNib
 When we wake from the nib file, setup the option controller
 This will receive notifications when an option changes.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void) awakeFromNib
{
	// create a OptionPaneController and put it in place of optionPane
	if (!optionController)
	{
		optionController = [[OptionPaneController alloc] init];
	}
	[optionController putViewIntoView:optionPane];
	[optionController setTarget:self];
	[optionController setAction:@selector(optionChanged:)];
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 windowControllerDidLoadNib:
 The nib is loaded. If there's a string in processString, it will
 appear in the sourceView.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	[super windowControllerDidLoadNib:aController];								// inherited method needs to be called.

	[self configureViewSettings:sourceView];
	[self configureViewSettings:tidyView];
	[sourceView setEditable:YES];

	// honor the defaults system defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];			// get the default default system
	[[optionController tidyDocument] takeOptionValuesFromDefaults:defaults];	// make the optionController take the values

	// saving behavior settings
	saveBehavior = [defaults integerForKey:JSDKeySavingPrefStyle];
	saveWarning = [defaults boolForKey:JSDKeyWarnBeforeOverwrite];
	yesSavedAs = NO;

	// make the sourceView string the same as our loaded text.
	[sourceView setString:[tidyProcess workingText]];

	// force the processing to occur.
	[self optionChanged:self];
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 windowNibName
 return the name of the Nib associated with this class.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (NSString *)windowNibName
{
	return @"TidyDocument";
}


#pragma mark -
#pragma mark PREFERENCES, TIDY OPTIONS, AND TIDYING


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 handleSavePrefChange
 this method receives "JSDSavePrefChange" notifications, so that
 we can keep abreast of the user's desired "Save" behaviours.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)handleSavePrefChange:(NSNotification *)note
{
	saveBehavior = [[NSUserDefaults standardUserDefaults] integerForKey:JSDKeySavingPrefStyle];
	saveWarning = [[NSUserDefaults standardUserDefaults] boolForKey:JSDKeyWarnBeforeOverwrite];
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 retidy
 do the actual re-tidy'ing
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)retidy
{
	[tidyProcess setWorkingText:[sourceView string]];		// put the sourceView text into the tidyProcess.
	[tidyView setString:[tidyProcess tidyText]];			// put the tidy'd text into the view.
	[errorView reloadData];									// reload the error data
	[errorView deselectAll:self];							// get rid of the selected row.

	// handle document dirty detection -- we're NOT dirty if the source and tidy string are
	// the same, or there is no source view, of if the source is the same as the original.
	if ( ( [tidyProcess areEqualOriginalTidy]) ||			// the original text and tidy text are equal OR
		( [[tidyProcess originalText] length] == 0 ) ||	// the originalText was never there OR
		( [tidyProcess areEqualOriginalWorking ] ))			// the workingText is the same as the original.
		[self updateChangeCount:NSChangeCleared];
	else
		[self updateChangeCount:NSChangeDone];
} // retidy


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 textDidChange:
 we arrived here by virtue of this document class being the
 delegate of sourceView. Whenever the text changes, let's
 reprocess all of the text. Hopefully the user won't be
 inclined to type everything, 'cos this is bound to be slow.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)textDidChange:(NSNotification *)aNotification
{
	[self retidy];
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 optionChanged:
 One of the options changed! We're here by virtue of being the
 action of the optionController instance. Let's retidy here.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (IBAction)optionChanged:(id)sender
{
	[tidyProcess optionCopyFromDocument:[optionController tidyDocument]];
	[self retidy];
}


#pragma mark -
#pragma mark SUPPORT FOR THE ERROR TABLE


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 numberOfRowsInTableView
 we're here because we're the datasource of the tableview.
 We need to specify how many items are in the table view.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[tidyProcess errorArray] count];
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 tableView:objectValueForTableColumn:row
 we're here because we're the datasource of the tableview.
 We need to specify what to show in the row/column.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSDictionary *error = [tidyProcess errorArray][rowIndex];	// get the current error

	// list of error types -- no localized; users can localize based on this string.
	NSArray *errorTypes = @[@"Info:", @"Warning:", @"Config:", @"Access:", @"Error:", @"Document:", @"Panic:"];

	// handle returning the severity of the error, localized.
	if ([[aTableColumn identifier] isEqualToString:@"severity"])
		return NSLocalizedString(errorTypes[[error[@"level"] intValue]], nil);

	// handle the location, localized, or "N/A" if not applicable
	if ([[aTableColumn identifier] isEqualToString:@"where"]) {
		if (([error[@"line"] intValue] == 0) || ([error[@"column"] intValue] == 0)) {
			return NSLocalizedString(@"N/A", nil);
		} // if (N/A)
		return [NSString stringWithFormat:@"%@ %@, %@ %@", NSLocalizedString(@"line", nil), error[@"line"], NSLocalizedString(@"column", nil), error[@"column"]];
	} // if where

	if ([[aTableColumn identifier] isEqualToString:@"description"])
		return error[@"message"];
	return @"";
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 errorClicked:
 we arrived here by virtue of this controller class and this
 method being the action of the table. Whenever the selection
 changes we're going to highlight and show the related
 column/row in the sourceView.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (IBAction)errorClicked:(id)sender
{
	NSInteger errorViewRow = [errorView selectedRow];
	if (errorViewRow >= 0)
	{
		NSInteger row = [[tidyProcess errorArray][errorViewRow][@"line"] intValue];
		NSInteger col = [[tidyProcess errorArray][errorViewRow][@"column"] intValue];
		[sourceView highlightLine:row Column:col];
	} else {
		[sourceView setShowsHighlight:NO];
	}
}


/*ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*
 tableViewSelectionDidChange:
 we arrived here by virtue of this controller class being the
 delegate of the table. Whenever the selection changes
 we're going to highlight and show the related column/row
 in the sourceView.
 *ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	// get the description of the selected row.
	if ([aNotification object] == errorView)
	{
		[self errorClicked:self];
	}
}


@end
