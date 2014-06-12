/**************************************************************************************************

	TidyDocumentSourceViewController
	 
	The source and tidy text view controller. Manages the two text fields, their interactions,
	and the type of display.
 

	The MIT License (MIT)

	Copyright (c) 2014 James S. Derry <http://www.balthisar.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software
	and associated documentation files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 **************************************************************************************************/

#import "TidyDocumentSourceViewController.h"
#import "PreferencesDefinitions.h"
#import "NSTextView+JSDExtensions.h"


@interface TidyDocumentSourceViewController ()

@end

@implementation TidyDocumentSourceViewController


/*———————————————————————————————————————————————————————————————————*
	initVertical: - designated initializer
 *———————————————————————————————————————————————————————————————————*/
- (instancetype)initVertical:(BOOL)initVertical
{
	NSString *nibName = initVertical ? @"TidyDocumentSourceV" : @"TidyDocumentSourceH";

	if ((self = [super initWithNibName:nibName bundle:nil]))
	{
		_ViewsAreVertical = initVertical;
		_ViewsAreSynced = NO;
		_ViewsAreDiffed = NO;
	}

	return self;
}


/*———————————————————————————————————————————————————————————————————*
	init
 *———————————————————————————————————————————————————————————————————*/
- (instancetype)init
{
	return [self initVertical:NO];
}


/*———————————————————————————————————————————————————————————————————*
	setupViewAppearance
 *———————————————————————————————————————————————————————————————————*/
- (void)setupViewAppearance
{
	self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

	[self.view setFrame:self.view.superview.bounds];

	[self configureViewSettings:self.sourceTextView];
	[self configureViewSettings:self.tidyTextView];
}


/*———————————————————————————————————————————————————————————————————*
	configureViewSettings: (private)
		Configure text view `aView` with uniform settings.
 *———————————————————————————————————————————————————————————————————*/
- (void)configureViewSettings:(NSTextView *)aView
{
	NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];


	[aView setFont:[NSFont fontWithName:@"Menlo" size:[NSFont systemFontSize]]];
	[aView setAutomaticQuoteSubstitutionEnabled:NO]; // IB setting doesn't work for this.
	[aView setAutomaticTextReplacementEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];
	[aView setAutomaticDashSubstitutionEnabled:[[localDefaults valueForKey:JSDKeyAllowMacOSTextSubstitutions] boolValue]];

	/* Provided by Category `NSTextView+JSDExtensions` */

	[aView setShowsLineNumbers:[[localDefaults valueForKey:JSDKeyShowNewDocumentLineNumbers] boolValue]];
	[aView setWordwrapsText:NO];
}

@end


