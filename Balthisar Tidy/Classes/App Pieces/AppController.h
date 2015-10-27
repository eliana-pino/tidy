/**************************************************************************************************

	AppController

	Copyright © 2003-2015 by Jim Derry. All rights reserved.

 **************************************************************************************************/

@import Cocoa;


/**
 *  This main application controller handles the preferences and most of the Sparkle vs.
 *  non-sparkle builds.
 */
@interface AppController : NSObject <NSApplicationDelegate>


- (IBAction)showPreferences:(id)sender;   // User wants to see Preferences window.

- (IBAction)showAboutWindow:(id)sender;   // User wants to see the About window.


@end

