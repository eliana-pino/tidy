/**************************************************************************************************

	FirstRunController

	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;


/**
 *  Implements a first run helper using an array of programmed steps:
 *  - message as NSString
 *  - showRelativeToRect as NSRect
 *  - ofView as NSView
 *  - preferredEdge as NSRectEdge
 */
@interface FirstRunController : NSObject


@property NSArray *steps;                      // Steps array, as described above.

@property NSString *preferencesKeyName;        // Preferences key to record whether or not helper finished.

@property (readonly, assign) BOOL isVisible;   // Indicates whether or not the helper is currently shown.


- (instancetype)initWithSteps:(NSArray*)steps;   // Inital with a steps array directly.

- (void)beginFirstRunSequence;                   // Start the sequence.


@end
