/**************************************************************************************************

	EncodingHelperController

	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

#import "TidyDocument.h"


/**
 *  Implements the encoding helper for Balthisar Tidy documents.
 */
@interface EncodingHelperController : NSViewController


- (instancetype)initWithNote:(NSNotification*)note fromDocument:(TidyDocument*)document forView:(NSView*)view;

- (void)startHelper;

@end
