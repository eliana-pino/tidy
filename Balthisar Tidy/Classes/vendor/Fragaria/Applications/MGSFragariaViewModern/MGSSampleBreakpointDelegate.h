//
//  MGSSimpleBreakpointDelegate.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 29/01/15.
//
//

#import <Foundation/Foundation.h>
#import <Fragaria/Fragaria.h>


/**
 *  This class serves as an example on how to use an external delegate class
 *  with MGSFragariaView. By default the AppDelegate would ordinarilly act
 *  as the delegate, but we've delegate to an instance of this class for the
 *  purpose of demonstration.
 **/
@interface MGSSampleBreakpointDelegate : NSObject <MGSBreakpointDelegate> {
    NSMutableSet *breakpoints;
}

@end
