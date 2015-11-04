//
//  MGSSimpleBreakpointDelegate.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 29/01/15.
//
//

#import "MGSSampleBreakpointDelegate.h"


@implementation MGSSampleBreakpointDelegate


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	init
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (instancetype)init
{
    self = [super init];
    breakpoints = [[NSMutableSet alloc] init];
    return self;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	breakpointColourForLine:ofFragaria:
		The ruler requests that this delegate provide an NSColor
		for this line. If this delegate is not implemented, then a
		built-in default color will be used.
 
		This is just a demo! A real app would have a more
		sophisticated way of deciding a breakpoint's color.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSColor *)breakpointColourForLine:(NSUInteger)line ofFragaria:(MGSFragariaView *)sender
{
	if (line % 2 == 0)
        /* Non-standard-color breakpoint */
        return [NSColor orangeColor];
    
    if (line % 3 == 0)
        /* Transparent breakpoint */
        return [[NSColor greenColor] colorWithAlphaComponent:0.25];
    
    /* Standard color breakpoint */
    return nil;
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	toggleBreakpointForFragaria:onLine:
		The ruler is indicating that the user click or activated a
		spot on the rule consistent with breakpoint location, and
		is reporting that even via this delegate method.
		
		This is just a demo! A real app would have a more
		sophisticated way of managing breakpoint events.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)toggleBreakpointForFragaria:(MGSFragariaView *)sender onLine:(NSUInteger)line
{
    NSNumber *lineNumber;
    
    lineNumber = [NSNumber numberWithUnsignedLong:line];
    if ([breakpoints containsObject:lineNumber])
        [breakpoints removeObject:lineNumber];
    else
        [breakpoints addObject:lineNumber];
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	breakpointsForFragaria:
		The ruler is indicating that it needs to know the set of
		breakpoints (if any) in order to display them. This delegate
		method should return an NSSet of NSNumber objects containing
		the line numbers of breakpoints.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSSet *)breakpointsForFragaria:(MGSFragariaView *)sender
{
    return [breakpoints copy];
}


@end
