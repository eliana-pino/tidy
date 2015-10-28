/**************************************************************************************************

	TidyDocument
	 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

@class JSDTidyModel;
@class TidyDocumentWindowController;


/**
 *  The main document controller, TidyDocument manages a single Tidy document and mediates
 *  access between the TidyDocumentWindowController and the JSDTidyModel processor.
 */
@interface TidyDocument : NSDocument


@property (readonly) JSDTidyModel *tidyProcess;             // Instance of JSDTidyModel that will perform all work.

@property (readonly) NSData *documentOpenedData;            // The original, loaded data if opened from file.

@property (assign) BOOL documentIsLoading;                  // Flag to indicate that the document is in loading process.

@property TidyDocumentWindowController *windowController;   // The associated windowcontroller.

@property (assign) BOOL fileWantsProtection;                // Indicates whether we need special type of save.


/* Properties used for AppleScript support */

@property (assign) NSString *sourceText;           // Source Text, mostly for AppleScript KVC support.

@property (readonly, assign) NSString *tidyText;   // Tidy'd Text, mostly for AppleScript KVC support.


@end
