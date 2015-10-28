/**************************************************************************************************

	SavingOptionsViewController
	 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

#import "MASPreferencesViewController.h"


/**
 *  A view controller to manage the preferences' file saving behavior options.
 */
@interface SavingOptionsViewController : NSViewController <MASPreferencesViewController>

@property (nonatomic, readonly) BOOL hasResizableWidth;
@property (nonatomic, readonly) BOOL hasResizableHeight;

@end
