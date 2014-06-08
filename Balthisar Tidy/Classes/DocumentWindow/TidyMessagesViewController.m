//
//  TidyMessagesViewController.m
//  Balthisar Tidy
//
//  Created by Jim Derry on 6/8/14.
//  Copyright (c) 2014 Jim Derry. All rights reserved.
//

#import "TidyMessagesViewController.h"


@implementation TidyMessagesViewController


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (instancetype)init
{
	return [super initWithNibName:@"TidyDocumentMessagesView" bundle:nil];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	awakeFromNib
		Ensure view occupies entire parent container.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)awakeFromNib
{
	self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

	if (self.view.superview)
	{
		[self.view setFrame:self.view.superview.bounds];
	}
}


@end
