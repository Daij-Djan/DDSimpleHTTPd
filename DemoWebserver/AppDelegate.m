
// AppDelegate.m DemoWebserver Created by Dominik Pich on 24.05.13.

#import "AppDelegate.h"
#import "SimpleHTTPResponder.h"

@implementation AppDelegate { SimpleHTTPResponder *_simpleServer; }

- (void)applicationDidFinishLaunching:(NSNotification*)n {

                 _name.stringValue = @"Demo";
                 _port.stringValue = @"8000";
              _webroot.stringValue = NSFileManager.defaultManager.currentDirectoryPath;
    _publishViaBonjour.state       = NSOnState;
}

- (void) toggleListening:(id)x    {

    if(_simpleServer) {
        [_simpleServer stopListening];
        _simpleServer = nil;
        
        [self.toggle setTitle:@"Start"];
        [self enableWindow:YES];
    }
    else {
        NSUInteger  p = self.port.integerValue;
        NSString * wr = self.webroot.stringValue,
                 *  n = self.name.stringValue;
        BOOL        b = self.publishViaBonjour.state == NSOnState;
        
        if(wr.length && p && (n.length||!b)) {

            _simpleServer                   = SimpleHTTPResponder.new;
            _simpleServer.port              = p;
            _simpleServer.webRoot           = wr;
            _simpleServer.bonjourName       = b ? n : nil;
#if DEBUG
            _simpleServer.loggingEnabled    = YES;
#endif
            _simpleServer.autogenerateIndex = YES;
            [_simpleServer startListening];
            
            _toggle.title   = @"Stop";
            _toggle.enabled = YES;
            [self enableWindow:NO];
        }}
}

- (void)    enableWindow:(BOOL)f  {

    for (NSControl *v in [self.window.contentView subviews])
      [v isKindOfClass:NSControl.class] ? [v setEnabled:f] : nil;
}

@end

int main(int argc, char*argv[]) { return NSApplicationMain(argc,(const char**)argv); }
