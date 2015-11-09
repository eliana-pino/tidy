/**************************************************************************************************

	TidyDocumentSourceViewController
	 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

#import "TidyDocumentSourceViewController.h"
#import "CommonHeaders.h"

#import <Fragaria/Fragaria.h>

#import "JSDTidyModel.h"
#import "TidyDocument.h"


@implementation TidyDocumentSourceViewController


#pragma mark - Initialization and Deallocation


/*———————————————————————————————————————————————————————————————————*
  - initVertical:
 *———————————————————————————————————————————————————————————————————*/
- (instancetype)initVertical:(BOOL)initVertical
{
	NSString *nibName = initVertical ? @"TidyDocumentSourceV" : @"TidyDocumentSourceH";

	if ((self = [super initWithNibName:nibName bundle:nil]))
	{
		_isVertical = initVertical;
		_viewsAreSynced = NO;
		_viewsAreDiffed = NO;
	}

	return self;
}


/*———————————————————————————————————————————————————————————————————*
  - init
 *———————————————————————————————————————————————————————————————————*/
- (instancetype)init
{
	return [self initVertical:NO];
}


/*———————————————————————————————————————————————————————————————————*
  - dealloc
 *———————————————————————————————————————————————————————————————————*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:tidyNotifySourceTextRestored object:[self.representedObject tidyProcess]];

	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:JSDKeyAllowMacOSTextSubstitutions];
}

/*———————————————————————————————————————————————————————————————————*
  - awakeFromNib
 *———————————————————————————————————————————————————————————————————*/
- (void)awakeFromNib
{
	
	/********************************************************
	 * Fragaria Groups
	 * Modern Fragaria includes a sophisticated property
	 * coordination feature with optional caching to user
	 * defaults. In Balthisar Tidy we will manage global
	 * (application-wide) defaults that are set in user
	 * preferences, and per-document defaults that do not
	 * cache their settings to user prefers. We *will*
	 * cache default state of these per-document prefs in
	 * user defaults, however.
	 ********************************************************/
	
	NSString *instancePrefs = [[NSProcessInfo processInfo] globallyUniqueString];
	MGSUserDefaultsController *sourceGroup = [MGSUserDefaultsController sharedControllerForGroupID:instancePrefs];
	MGSUserDefaultsController *globalGroup = [MGSUserDefaultsController sharedController];

	sourceGroup.managedProperties = [self managedPropertiesDocument];
	globalGroup.managedProperties = [self managedPropertiesGlobal];
	
	sourceGroup.persistent = NO;
	globalGroup.persistent = YES;
	
	[sourceGroup addFragariaToManagedSet:self.sourceTextView];
	[sourceGroup addFragariaToManagedSet:self.tidyTextView];
	
	
	/********************************************************
	 * Notifications, etc.
	 ********************************************************/
	
	/* NSNotifications from the document's sourceText, in case tidyProcess
	 * changes the sourceText.
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTidySourceTextRestored:)
												 name:tidyNotifySourceTextRestored
											   object:[[self representedObject] tidyProcess]];

	/* KVO on user prefs to look for Text Substitution Preference Changes */
	[[NSUserDefaults standardUserDefaults] addObserver:self
											forKeyPath:JSDKeyAllowMacOSTextSubstitutions
											   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial)
											   context:NULL];
	
	/* KVO on the errorArray so we can display inline errors. */
	[((TidyDocument*)self.representedObject).tidyProcess addObserver:self
														  forKeyPath:@"errorArray"
															 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial)
															 context:NULL];
	
	/* Interface Builder doesn't allow us to define custom bindings, so we have to bind the tidyTextView manually. */
	[self.tidyTextView bind:@"string" toObject:self.representedObject withKeyPath:@"tidyProcess.tidyText" options:nil];
}


#pragma mark - Delegate Methods


/*———————————————————————————————————————————————————————————————————*
  - textDidChange:
	We arrived here by virtue of being the delegate of
	`sourcetextView`. Simply update the tidyProcess sourceText,
	and the event chain will eventually update everything
	else.
 *———————————————————————————————————————————————————————————————————*/
- (void)textDidChange:(NSNotification *)aNotification
{
	TidyDocument *localDocument = self.representedObject;

	/* Update the tidyProcess */

	localDocument.tidyProcess.sourceText = self.sourceTextView.string;

	/* Handle document dirty detection. */

	if ( (!localDocument.tidyProcess.isDirty) || (localDocument.tidyProcess.sourceText.length == 0) )
	{
		[localDocument updateChangeCount:NSChangeCleared];
	}
	else
	{
		[localDocument updateChangeCount:NSChangeDone];
	}
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
  - textView:doCommandBySelector:
	We're here because we're the delegate of `sourceTextView`.
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


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 - concludeDragOperation:
   We're here because we're the concludeDragOperationDelegte
   of `sourceTextView`.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pasteBoard = [sender draggingPasteboard];
	
	/**************************************************
	 The pasteboard contains a list of file names
	 **************************************************/
	if ( [[pasteBoard types] containsObject:NSFilenamesPboardType] )
	{
		NSArray *fileNames = [pasteBoard propertyListForType:@"NSFilenamesPboardType"];
		
		for (NSString *path in fileNames)
		{
			NSString *contents;
			
			/*************************************
			 Mac OS X 10.10+: Will try to guess
			 the encoding of the dragged in file
			 *************************************/
			if ([NSString respondsToSelector:@selector(stringEncodingForData:encodingOptions:convertedString:usedLossyConversion:)])
			{
				NSData *rawData;
				if ((rawData = [NSData dataWithContentsOfFile:path]))
				{
					[NSString stringEncodingForData:rawData encodingOptions:nil convertedString:&contents usedLossyConversion:nil];
				}
			}
			/*************************************
			 Older Mac OS X can only accept UTF.
			 *************************************/
			else
			{
				NSError *error;
				contents = [NSString stringWithContentsOfFile:path usedEncoding:nil error:&error];
				if (error)
				{
					contents = nil;
				}
			}
			
			if (contents)
			{
				[self.sourceTextView.textView insertText:contents];
			}
			
		}
	}
}


#pragma mark - KVC and Notification Handling


/*———————————————————————————————————————————————————————————————————*
 - observeValueForKeyPath:ofObject:change:context:
   Handle KVO Notifications:
   - certain preferences changed.
   - the errorArray changed.
 *———————————————————————————————————————————————————————————————————*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	/* Handle changes to the preferences for allowing or disallowing Mac OS X Text Substitutions */
	if ((object == [NSUserDefaults standardUserDefaults]) && ([keyPath isEqualToString:JSDKeyAllowMacOSTextSubstitutions]))
	{
		[self.sourceTextView.textView setAutomaticQuoteSubstitutionEnabled:[[[NSUserDefaults standardUserDefaults] valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
		[self.sourceTextView.textView setAutomaticTextReplacementEnabled:[[[NSUserDefaults standardUserDefaults] valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
		[self.sourceTextView.textView setAutomaticDashSubstitutionEnabled:[[[NSUserDefaults standardUserDefaults] valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
	}
	
	/* Handle changes from the errorArray. */
	if ((object == ((TidyDocument*)self.representedObject).tidyProcess) && ([keyPath isEqualToString:@"errorArray"]))
	{
		NSArray *localErrors = ((TidyDocument*)self.representedObject).tidyProcess.errorArray;
		NSMutableArray *highlightErrors = [[NSMutableArray alloc] init];
		
		for (NSDictionary *localError in localErrors)
		{
			SMLSyntaxError *newError = [SMLSyntaxError new];
			newError.errorDescription = localError[@"message"];
			newError.line = [localError[@"line"] intValue];
			newError.character = [localError[@"column"] intValue];
			newError.length = 1;
			newError.hidden = NO;
			newError.warningImage = localError[@"levelImage"];
			[highlightErrors addObject:newError];
		}
		
		self.sourceTextView.syntaxErrors = highlightErrors;
	}
}


/*———————————————————————————————————————————————————————————————————*
  - handleTidySourceTextRestored:
	Handle changes to the tidyProcess's sourceText property.
	The tidyProcess changed the sourceText for some reason,
	probably because the user changed input-encoding. Note
	that this event is only received if Tidy itself changes
	the sourceText, not as the result of outside setting.
	The event chain will eventually update everything else.
 *———————————————————————————————————————————————————————————————————*/
- (void)handleTidySourceTextRestored:(NSNotification *)note
{
	self.sourceTextView.string = ((TidyDocument*)self.representedObject).tidyProcess.sourceText;

	/* At this point, we're done loading the document */
	((TidyDocument*)self.representedObject).documentIsLoading = NO;
}


#pragma mark - Appearance Setup

/*———————————————————————————————————————————————————————————————————*
  - managedPropertiesGlobal
    Returns a list of Fragaria properties to apply application-wide.
 
    Application-wide we want to ensure a consistent set of editor
    and syntax highlighting colors.
 *———————————————————————————————————————————————————————————————————*/
- (NSSet *)managedPropertiesGlobal
{
	static NSMutableSet *managedPropertiesGlobal;
	
	if (!managedPropertiesGlobal)
	{
		managedPropertiesGlobal = [[NSMutableSet alloc] initWithArray:[[MGSFragariaView propertyGroupTheme] allObjects]];
		[managedPropertiesGlobal addObjectsFromArray:[[MGSFragariaView propertyGroupTextFont] allObjects]];
		[managedPropertiesGlobal addObjectsFromArray:[[MGSFragariaView propertyGroupAutocomplete] allObjects]];
		[managedPropertiesGlobal addObjectsFromArray:[[MGSFragariaView propertyGroupIndenting] allObjects]];
	}
	
	return managedPropertiesGlobal;
}


/*———————————————————————————————————————————————————————————————————*
 - managedPropertiesDocument
   Returns a list of Fragaria properties to apply to a document.
 
   Within a single document we want to ensure that the two editors
   maintain a consistent appearance for line numbers, etc.
 *———————————————————————————————————————————————————————————————————*/
- (NSSet *)managedPropertiesDocument
{
	static NSMutableSet *managedPropertiesDocument;
	
	if (!managedPropertiesDocument)
	{
		managedPropertiesDocument = [[NSMutableSet alloc] initWithArray:[[MGSFragariaView propertyGroupEditing] allObjects]];
		[managedPropertiesDocument addObjectsFromArray:[[MGSFragariaView propertyGroupGutter] allObjects]];
	}
	
	return managedPropertiesDocument;
}

/*———————————————————————————————————————————————————————————————————*
 - managedPropertiesIndividual
   Returns a list of Fragaria properties that are left unmanaged.
 *———————————————————————————————————————————————————————————————————*/
- (NSSet *)managedPropertiesIndividual
{
	static NSMutableSet *managedPropertiesIndividual;
	
	if (!managedPropertiesIndividual)
	{
		managedPropertiesIndividual = [[NSMutableSet alloc] initWithArray:[[MGSFragariaView defaultsDictionary] allKeys]];
		[managedPropertiesIndividual minusSet:[self managedPropertiesGlobal]];
		[managedPropertiesIndividual minusSet:[self managedPropertiesDocument]];
	}
	
	return managedPropertiesIndividual;
}



/*———————————————————————————————————————————————————————————————————*
  - setupViewAppearance
 *———————————————————————————————————————————————————————————————————*/
- (void)setupViewAppearance
{
	/* Force the view to fill its containing view. */
	self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.view setFrame:self.view.superview.bounds];
	
	/* This closure acts as a subroutine to avoid being repetitive. */
	
	void (^configureCommonViewSettings)(MGSFragariaView *) = ^(MGSFragariaView *aView) {
		
		NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];
		
		// @TODO: rewrite Fragaria to avoid this bullshit. Can't set options without using defaults?
		[localDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:[NSFont systemFontSize]]] forKey:MGSFragariaDefaultsTextFont];
		[localDefaults setObject:@(40) forKey:MGSFragariaDefaultsMinimumGutterWidth];
		
		aView.lineWrap = NO;
		aView.syntaxDefinitionName = @"html";
		
		[aView.textView setAutomaticQuoteSubstitutionEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
		[aView.textView setAutomaticTextReplacementEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
		[aView.textView setAutomaticDashSubstitutionEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
		[aView.textView setImportsGraphics:NO];
		[aView.textView setAllowsImageEditing:NO];
		[aView.textView setUsesFontPanel:NO];
		[aView.textView setUsesRuler:NO];
		[aView.textView setUsesInspectorBar:NO];
		[aView.textView setUsesFindBar:NO];
		[aView.textView setUsesFindPanel:NO];
		[self.tidyTextView.textView setSelectable:YES];
		[self.tidyTextView.textView setRichText:NO];
	};
	
	configureCommonViewSettings(self.sourceTextView);
	configureCommonViewSettings(self.tidyTextView);
	
	
	/* tidyTextView special settings. */
	
	[self.tidyTextView.textView setEditable:NO];
	[self.tidyTextView.textView setAllowsUndo:NO];
	
	/* sourceTextView special settings. */
	self.sourceTextView.showsSyntaxErrors = YES;
	self.sourceTextView.showsIndividualErrors = YES;
	
//	self.tidyTextView.backgroundColor = [NSColor redColor];
	
	
	// @todo: stupid Fragaria's preferences make this impossible to apply only to one instance currently.
	//	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:MGSFragariaPrefsShowPageGuide];
	//	[[NSUserDefaults standardUserDefaults] setObject:@(80) forKey:MGSFragariaPrefsShowPageGuideAtColumn];
	
	
	/* sourceTextView shouldn't accept every drop type */
	[self.sourceTextView.textView registerForDraggedTypes:@[NSFilenamesPboardType]];
}


/*———————————————————————————————————————————————————————————————————*
  - goToSourceErrorUsingArrayController:
    Will go to the line containing an error when the messages
    table selection index changes.
 *———————————————————————————————————————————————————————————————————*/
- (void)goToSourceErrorUsingArrayController:(NSArrayController*)arrayController
{
	NSArray *localObjects = arrayController.arrangedObjects;
	
	NSUInteger errorViewRow = arrayController.selectionIndex;

	if (errorViewRow < [localObjects count])
	{
		NSInteger row = [localObjects[errorViewRow][@"line"] intValue];
		
		if (row > 0)
		{
			[self.sourceTextView goToLine:row centered:NO highlight:NO];
		}
	}
}


#pragma mark - Private Methods


/*———————————————————————————————————————————————————————————————————*
  @property pageGuidePosition
 *———————————————————————————————————————————————————————————————————*/
- (NSUInteger)pageGuidePosition
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:MGSFragariaDefaultsPageGuideColumn];
}

- (void)setPageGuidePosition:(NSUInteger)pageGuidePosition
{
	// @TODO: stupid Fragaria's preferences need to be reworked.
	[[NSUserDefaults standardUserDefaults] setObject:@(pageGuidePosition>0) forKey:MGSFragariaDefaultsShowsPageGuide];
	[[NSUserDefaults standardUserDefaults] setObject:@(pageGuidePosition) forKey:MGSFragariaDefaultsPageGuideColumn];
}


@end
