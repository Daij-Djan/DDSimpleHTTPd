
// AppDelegate.h DemoWebserver Created by Dominik Pich on 24.05.13.

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet    NSWindow * window;
@property (weak)   IBOutlet    NSButton * toggle,
                                        * publishViaBonjour;
@property (weak)   IBOutlet NSTextField * name,
                                        * port,
                                        * webroot;
- (IBAction) toggleListening:(id)x;

@end
