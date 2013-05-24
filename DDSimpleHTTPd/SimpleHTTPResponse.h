//
//  SimpleHTTPResponse.h
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

@interface SimpleHTTPResponse : NSObject

- (void)addHeader:(NSString *)key withValue:(NSString *)value;
@property(nonatomic, readonly) NSDictionary *headers;

@property(nonatomic, copy) NSString *contentType;
@property(nonatomic, assign) int responseCode;

- (void)setContent:(NSData *)toData;
- (void)setContentString:(NSString *)toString;
@property(nonatomic, readonly) NSData *content;

@end
