//
//  main.m
//  DDSimpleHTTPd
//
//  Created by Dominik Pich on 24.05.13.
//
//

#import <Foundation/Foundation.h>
#import "SimpleHTTPResponder.h"

SimpleHTTPResponder *simpleServer = nil;

int main(int argc, const char * argv[])
{
#if !DEBUG
    if(argc != 4) {
        printf("Usage: DDSimpleHTTPd NAME PORT WebRootPath");
        return 1;
    }
#endif
    
    @autoreleasepool {
        simpleServer = [[SimpleHTTPResponder alloc] init];
#if DEBUG
        simpleServer.port = 8000;
        simpleServer.webRoot = @"/";
        simpleServer.bonjourName = @"test";
        simpleServer.loggingEnabled = YES;
#else
        simpleServer.port = [@(argv[2]) intValue];
        simpleServer.webRoot = @(argv[3]);
        simpleServer.bonjourName = @(argv[1]);
#endif
        simpleServer.autogenerateIndex = YES;
        [simpleServer startListening];
        
        printf("Running server %s...", simpleServer.description.UTF8String);
        printf("\nPress Ctrl+C to stop it ...");
        
        //RUN and WAIT for ctrl+c
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}