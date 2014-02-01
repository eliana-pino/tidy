0 => Name { index               => 0
			NSCharacterEndoding => 1234532
		  }

		  
		  
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

int main (int argc, const char * argv[])
{
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

   NSLog (@"hello world");

NSArray *myArray = [NSArray arrayWithObjects:@"0", @"22113", nil];

NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                myArray,  @"UTF8",
                                 @"Hello, World!",  @"UTF16",
                                            @"42",  @"Western (Mac OS Roman)",
                                       nil
                                       ];   
   
   
NSLog(@"%@", dictionary);  

NSNumber *myNumber = [dictionary valueForKeyPath:@"@count"];
   
NSLog(@"%@", myNumber);  


NSDictionary *encoding1 = [NSDictionary dictionaryWithObjectsAndKeys:
   @"Western (Mac OS Roman)",  @"name",
                       @"87",  @"order",
                    @"23342",  @"NSCharacterEncoding",
   nil];

NSDictionary *encoding2 = [NSDictionary dictionaryWithObjectsAndKeys:
            @"Unicode UTF16",  @"name",
                       @"12",  @"order",
                    @"12345",  @"NSCharacterEncoding",
   nil];

NSDictionary *encoding3 = [NSDictionary dictionaryWithObjectsAndKeys:
           @"Unicode (UTF8)",  @"name",
                        @"1",  @"order",
                    @"09876",  @"NSCharacterEncoding",
   nil];

NSArray *encodingList = [NSArray arrayWithObjects: encoding1, encoding2, encoding3, nil];

NSLog(@"%@", encodingList);  

NSArray *names = [encodingList valueForKeyPath:@"@unionOfObjects.name"];

NSLog(@"%@", names);  
   
   
NSArray *names2 = [encodingList valueForKeyPath:@"name"];

NSLog(@"%@", names2);  


NSPredicate *mypredicate = [NSPredicate predicateWithFormat:@"name == %@", @"Unicode UTF16"];












   [pool drain];
   
   return 0;
}
