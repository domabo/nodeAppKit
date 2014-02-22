#import "NAKAppDelegate.h"

int main(int argc, char * argv[]) {
     NSApplication * application = [NSApplication sharedApplication];
    [application activateIgnoringOtherApps:YES];
    
    NAKAppDelegate * appDelegate = [[NAKAppDelegate alloc] init];
    
    [application setDelegate:appDelegate];
    

    [application run];
    
    
    return EXIT_SUCCESS;
}