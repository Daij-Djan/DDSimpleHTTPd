//
//  HTTPResponder.h
//  TouchMe
//
//  Created by Alex P on 15/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  Refactored for new objC,ARC and ios/foundation.framework 24.5.13
//  Copyright 2013 Dominik Pich
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@class SimpleHTTPRequest;
@class SimpleHTTPResponse;

@protocol SimpleHTTPResponderDelegate <NSObject>

//if the delegate provides an answer we return that
//else the stock implementation tries to do it
//but it only knows a limited amount of mime types and can only do GETs
@optional
- (SimpleHTTPResponse *)processPOST:(SimpleHTTPRequest *)request;
- (SimpleHTTPResponse *)processGET:(SimpleHTTPRequest *)request;

@end

//all not thread safe and only meant to be used on main thread
@interface SimpleHTTPResponder : NSObject

//all filetypes(with extensions) and their mimetype we can handle out-of-the-box
+ (NSDictionary*)knownMimetypes;

//
//the properties wont take effect while the server is up (delegate is the exception)
//

@property(nonatomic, assign) NSUInteger port;
//needs to be set if delegate doesnt handle everything
@property(nonatomic, copy) NSString *webRoot;
@property(nonatomic, copy) NSString *indexFile;
//if you dont specify an index file
@property(nonatomic, assign) BOOL autogenerateIndex;
@property(nonatomic, assign) id<SimpleHTTPResponderDelegate> delegate;
@property(nonatomic, copy) NSString *bonjourName;

- (void)startListening;
@property(nonatomic, readonly) BOOL isListening;
- (void)stopListening;

@property(nonatomic, assign, getter = isLoggingEnabled) BOOL loggingEnabled;

@end

@interface SimpleHTTPResponder (RequestProcessing)

- (SimpleHTTPResponse *)processPOST:(SimpleHTTPRequest *)request;
- (SimpleHTTPResponse *)processGET:(SimpleHTTPRequest *)request;
- (SimpleHTTPResponse *)processRequest:(SimpleHTTPRequest *)request;
- (void)stopProcessing;

@end
