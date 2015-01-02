/**************************************************************************************************

	ActionRequestHandler

	Handles the Action Extension actions for Balthisar Tidy, in order to tidy selected text
    in a host application.


	The MIT License (MIT)

	Copyright (c) 2001 to 2014 James S. Derry <http://www.balthisar.com>

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

#import "ActionRequestHandler.h"

@implementation ActionRequestHandler

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	beginRequestWithExtensionContext
		Tidy's the provided text and returns it.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    // Get the input item
    NSExtensionItem *item = context.inputItems.firstObject;
    NSAttributedString *content = item.attributedContentText;
    NSLog(@"Content %@", content);

    // Transform the content
    NSMutableAttributedString *newContent = [content mutableCopy];

    if (newContent.length > 0) {
        [newContent.mutableString appendString:@"ABC"];
        item.attributedContentText = newContent;

        // Notify the action is done with success
        [context completeRequestReturningItems:@[item] completionHandler:nil];
    } else {
        // Notify the action failed to complete, use an appropriate error
        [context cancelRequestWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
}

@end
