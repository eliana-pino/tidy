/**************************************************************************************************

	TidyDocumentService

	This class provides the functions for allowing Balthisar Tidy to provide a service.
	It contains functions for services that Balthisar Tidy proper will offer.


	The MIT License (MIT)

	Copyright (c) 2003 to 2015 Jim Derry <http://www.balthisar.com>

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

#import "TidyDocumentService.h"
#import "CommonHeaders.h"

#import "JSDTidyModel.h"
#import "JSDTidyOption.h"
#import "TidyDocument.h"

@implementation TidyDocumentService


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	 newDocumentWithSelection
	 - Creates a new Balthisar Tidy document using the selection.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)newDocumentWithSelection:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error
{
#ifdef FEATURE_SUPPORTS_SERVICE
    /* Test for strings on the pasteboard. */
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSDictionary *options = [NSDictionary dictionary];
    
    if (![pboard canReadObjectForClasses:classes options:options])
	{
        *error = NSLocalizedString(@"tidyCantRead", nil);
        return;
    }
    
    /* Create a new document and set the text. */
    TidyDocument *localDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:nil];
    localDocument.sourceText = [pboard stringForType:NSPasteboardTypeString];
#endif
}


@end
