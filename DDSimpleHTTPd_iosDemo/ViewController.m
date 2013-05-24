//
//  ViewController.m
//  DDSimpleHTTPd_iosDemo
//
//  Created by Dominik Pich on 24.05.13.
//
//

#import "ViewController.h"
#import "SimpleHTTPResponder.h"

@implementation ViewController

- (void)viewDidLoad
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *path = url.path;
    
    SimpleHTTPResponder *simpleServer = [[SimpleHTTPResponder alloc] init];
    simpleServer.port = 8000;
    simpleServer.webRoot = path;
    simpleServer.bonjourName = @"test";
    simpleServer.loggingEnabled = YES;
    simpleServer.autogenerateIndex = YES;
    [simpleServer startListening];
}

@end
