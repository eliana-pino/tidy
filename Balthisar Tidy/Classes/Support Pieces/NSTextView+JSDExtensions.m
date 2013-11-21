/**************************************************************************************************

	NSTextView+JSDExtensions.h

	Some nice extensions to NSTextView

	These extensions will add some features to any NSTextView

		o Highlight a row and character in the text view.
		o Turn word-wrapping on and off.
		o Own and instantiate its own NoodleLineNumberView.


	The MIT License (MIT)

	Copyright (c) 2001 to 2013 James S. Derry <http://www.balthisar.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software
	and associated documentation files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell	copies of the Software, and to permit persons to whom the
	Software is	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 **************************************************************************************************/

#import <objc/runtime.h>
#import "NSTextView+JSDExtensions.h"


#pragma mark -
#pragma mark Constants for associative references


// Can't define new iVars, but associate references help out.
// These constants will serve as keys. Values aren't important; only the pointer value is.

static char const * const JSDtagLine = "JSDtagLine";
static char const * const JSDtagColumn = "JSDtagColumn";
static char const * const JSDtagIsHighlit = "JSDtagIsHighlit";


#pragma mark -
#pragma mark Implementation



@implementation NSTextView (JSDExtensions)


#pragma mark -
#pragma mark Added property accessors and mutators


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	highlitLine
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSInteger)highlitLine
{
	NSNumber *item = objc_getAssociatedObject(self, JSDtagLine);

	if (item != nil)
	{
		return [item integerValue];

	} else {
		return  0;
	}
}

- (void)setHighlitLine:(NSInteger)line
{
	objc_setAssociatedObject(self, JSDtagLine, [NSNumber numberWithInteger:line], OBJC_ASSOCIATION_COPY_NONATOMIC);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	highlitColumn
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSInteger)highlitColumn
{
	NSNumber *item = objc_getAssociatedObject(self, JSDtagColumn);

	if (item != nil)
	{
		return [item integerValue];

	} else {
		return  0;
	}
}

- (void)setHighlitColumn:(NSInteger)column
{
	objc_setAssociatedObject(self, JSDtagColumn, [NSNumber numberWithInteger:column], OBJC_ASSOCIATION_COPY_NONATOMIC);
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	highlit
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)ShowsHighlight
{
	NSNumber *item = objc_getAssociatedObject(self, JSDtagIsHighlit);

	if (item != nil)
	{
		return [item boolValue];

	} else {
		return NO;
	}
}

- (void)setShowsHighlight:(BOOL)state
{
	// Remember the new setting
	objc_setAssociatedObject(self, JSDtagIsHighlit, [NSNumber numberWithBool:state], OBJC_ASSOCIATION_COPY_NONATOMIC);

	if (!state)
	{
		// Remove current highlighting from entire contents
		[[self layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[self textStorage] length])];
	} else {
		// Setup the variables we need for the loop
		NSRange aRange;								// a range for counting lines
		NSRange lineCharRange;						// a range for counting lines
		NSUInteger i = 0;							// glyph counter
		NSUInteger j = 1;							// line counter
		NSUInteger k;								// column counter
		NSRect r;									// rectange holder
		NSLayoutManager *lm = [self layoutManager];	// get layout manager.
		NSInteger litLine = [self highlitLine];		// get the line to light.
		NSInteger litColumn = [self highlitColumn];	// Get the column to light.

		// Remove any existing coloring.
		[lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[self textStorage] length])];

		// Only highlight if there's a row to highlight.
		if (litLine >= 1)
		{
			// The line number counting loop
			while ( i < [lm numberOfGlyphs] )
			{
				r = [lm lineFragmentRectForGlyphAtIndex:i effectiveRange:&aRange];	// Get the range for the current line.

				// If the current line is what we're looking for, then highlight it
				if (j == litLine)
				{
					k = [lm characterIndexForGlyphAtIndex:i] + litColumn - 1;						// the column position

					lineCharRange = [lm characterRangeForGlyphRange:aRange actualGlyphRange:NULL];	// the whole row range

					// color them
					[lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor secondarySelectedControlColor], NSBackgroundColorAttributeName, nil] forCharacterRange:lineCharRange];
					[lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor selectedTextBackgroundColor], NSBackgroundColorAttributeName, nil] forCharacterRange:NSMakeRange(k, 1)];
				}

				i += [[[self string] substringWithRange:aRange] length];							// advance glyph counter to EOL
				j ++;
			}
		}
	}
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	scrollLineToVisible:
		Scrolls the display to a specific line.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)scrollLineToVisible:(NSInteger)line
{

}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	highLiteLine:
		Sets |highlitLine|, |highlitColumn|, and |highlit| in
		one go, as well as scrolls that line into view.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)highLiteLine:(NSInteger)line Column:(NSInteger)column
{

}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
 highlightLightedLine:
 sets _litLine to be highlighted.
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
/*
- (void)highlightLightedLine
{
    // setup the variables we need for the loop
    NSRange aRange;								// a range for counting lines
    NSRange lineCharRange;						// a range for counting lines
    int i = 0;									// glyph counter
    int j = 1;									// line counter
    NSUInteger k;								// column counter
    NSRect r;									// rectange holder
    NSLayoutManager *lm = [self layoutManager];	// get layout manager.

    // Remove any existing coloring.
    [lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[self textStorage] length])];

    // only highlight if there's a row to highlight.
    if (_litLine >= 1) {
        // the line number counting loop
        while ( i < [lm numberOfGlyphs] ) {
            r = [lm lineFragmentRectForGlyphAtIndex:i effectiveRange:&aRange];	// get the range for the current line.
            // if the current line is what we're looking for, then highlight it!
            if (j == _litLine) {
                k = [lm characterIndexForGlyphAtIndex:i] + _litColumn - 1;			// the column position
                lineCharRange = [lm characterRangeForGlyphRange:aRange actualGlyphRange:NULL];	// the whole role range
                // color them
                [lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor cyanColor], NSBackgroundColorAttributeName, nil] forCharacterRange:lineCharRange];
                [lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor magentaColor], NSBackgroundColorAttributeName, nil] forCharacterRange:NSMakeRange(k, 1)];
            } // if
            i += [[[self string] substringWithRange:aRange] length];		// advance glyph counter to EOL
            j ++;								// increment the line number
        } // while
    } // if
} // highlightLightedLine
*/


@end
