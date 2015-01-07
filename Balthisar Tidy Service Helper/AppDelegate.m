//
//  AppDelegate.m
//  Balthisar Tidy Service Helper
//
//  Created by Jim Derry on 1/5/15.
//  Copyright (c) 2015 Jim Derry. All rights reserved.
//

#import "AppDelegate.h"
#import "TidyService.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	TidyService *tidyService = [[TidyService alloc] init];

	/*
	 Use NSRegisterServicesProvider instead of NSApp:setServicesProvider
	 So that we can have careful control over the port name. @TODO: Study
	 the behavior of having multiple versions of the app, otherwise we might
	 have to conditionally-compile the Info.plist, too, to disambiguate them.
	 */
	NSRegisterServicesProvider(tidyService, @"com.balthisar.service.port");
}


@end
