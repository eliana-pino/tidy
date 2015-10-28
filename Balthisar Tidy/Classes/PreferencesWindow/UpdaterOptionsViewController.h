/**************************************************************************************************

	UpdaterOptionsViewController
	 
	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;

#import "MASPreferencesViewController.h"


/**
 *  A view controller to manage the preferences' updater options.
 */
@interface UpdaterOptionsViewController : NSViewController <MASPreferencesViewController>


/* Software Updater Pane Preferences and Objects */

@property (weak) IBOutlet NSButton      *buttonAllowUpdateChecks;
@property (weak) IBOutlet NSButton      *buttonAllowSystemProfile;
@property (weak) IBOutlet NSPopUpButton *buttonUpdateInterval;


/* <MASPreferencesViewController> */

@property (nonatomic, readonly) BOOL hasResizableWidth;
@property (nonatomic, readonly) BOOL hasResizableHeight;


@end
