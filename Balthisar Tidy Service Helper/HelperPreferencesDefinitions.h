/**************************************************************************************************

	PreferencesDefinitions.h
 
	Application-wide preferences and definitions.
	- Keys for top-hierarchy preferences managed by this application.
	- Definitions for behaviors based on the build targets' preprocessor macros.


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

#ifndef HelperPreferencesDefinitions_h
#define HelperPreferencesDefinitions_h

#pragma mark - Feature Definitions


#ifdef TARGET_WEB
    #define APP_GROUP_PREFS @"group.com.balthisar.web.free.balthisar-tidy.prefs"
#endif

#ifdef TARGET_APP
    #define APP_GROUP_PREFS @"group.com.balthisar.Balthisar-Tidy.prefs"
#endif

#ifdef TARGET_PRO
    #define APP_GROUP_PREFS @"group.com.balthisar.Balthisar-Tidy.pro.prefs"
#endif

#endif
