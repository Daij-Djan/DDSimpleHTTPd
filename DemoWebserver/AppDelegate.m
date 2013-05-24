//
//  AppDelegate.m
//  DemoWebserver
//
//  Created by Dominik Pich on 24.05.13.
//
//

#import "AppDelegate.h"
#import "SimpleHTTPResponder.h"

@implementation AppDelegate {
    SimpleHTTPResponder *_simpleServer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.name.stringValue = @"Demo";
    self.port.stringValue = @"8000";
    self.webroot.stringValue = [[NSFileManager defaultManager] currentDirectoryPath];
    self.publishViaBonjour.state = NSOnState;
}

- (IBAction)toggleListening:(id)sender {
    if(_simpleServer) {
        [_simpleServer stopListening];
        _simpleServer = nil;
        
        [self.toggle setTitle:@"Start"];
        [self enableWindow:YES];
    }
    else {
        NSUInteger p = self.port.integerValue;
        NSString *wr = self.webroot.stringValue;

        NSString *n = self.name.stringValue;
        BOOL b = self.publishViaBonjour.state == NSOnState;
        
        if(wr.length && p > 0 && (n.length||!b)) {
            _simpleServer = [[SimpleHTTPResponder alloc] init];
            _simpleServer.port = p;
            _simpleServer.webRoot = wr;
            _simpleServer.bonjourName = b ? n : nil;
#if DEBUG
            _simpleServer.loggingEnabled = YES;
#endif
            _simpleServer.autogenerateIndex = YES;
            [_simpleServer startListening];
            
            [self.toggle setTitle:@"Stop"];
            [self enableWindow:NO];
            [self.toggle setEnabled:YES];
        }}
}

- (void)enableWindow:(BOOL)f {
    for (NSControl *v in [self.window.contentView subviews]) {
        if([v isKindOfClass:[NSControl class]])
            [v setEnabled:f];
    }
}
@end
