//
//  SimpleHTTPRequest.h
//  TouchMe
//
//  Created by Alex P on 16/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  Refactored for new objC,ARC and ios/foundation.framework 24.5.13
//  Copyright 2013 Dominik Pich
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@class SimpleHTTPConnection;

@interface SimpleHTTPRequest : NSObject

- (id)initWithDictionary:(NSMutableDictionary *)dict;

- (NSURL *)url;
- (NSString *)method;
- (NSDictionary *)headers;
- (NSString *)getHeader:(NSString *)byName;
- (NSData *)body;
- (SimpleHTTPConnection *)connection;
- (NSDate *)date;
- (NSString *)postVar:(NSString *)byName;
- (NSString *)getVar:(NSString *)byName;

@end
