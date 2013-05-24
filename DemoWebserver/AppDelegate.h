//
//  AppDelegate.h
//  DemoWebserver
//
//  Created by Dominik Pich on 24.05.13.
//
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *toggle;

@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *port;
@property (weak) IBOutlet NSTextField *webroot;
@property (weak) IBOutlet NSButton *publishViaBonjour;

- (IBAction)toggleListening:(id)sender;

@end
