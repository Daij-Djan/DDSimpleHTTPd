//
//  SimpleHTTPResponse.m
//  TouchMe
//
//  Created by Alex P on 16/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SimpleHTTPResponse.h"

@implementation SimpleHTTPResponse {
	NSMutableDictionary *_data;
}

- (id)init
{
	if(self = [super init]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
		
		_data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				@"text/html", @"Content-type",
				[dateFormatter stringFromDate:[NSDate date]], @"Date",
				[dateFormatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSinceNow:10]], @"Expires",
				@"SimpleHTTPd", @"Server",
				nil
			], @"headers",
			[NSNumber numberWithInt:200], @"code",
			[NSData data], @"content",
			nil
		];
	}
	
	return self;
}

- (void)addHeader:(NSString *)key withValue:(NSString *)value
{
	[[_data objectForKey:@"headers"] setValue:value forKey:key];
}

- (NSDictionary *)headers
{
	return [_data objectForKey:@"headers"];
}

- (void)setContentType:(NSString *)mimeType
{
	[[_data objectForKey:@"headers"] setValue:[mimeType copy] forKey:@"Content-type"];
}

- (NSString *)contentType
{
	return [[_data objectForKey:@"headers"] objectForKey:@"Content-type"];
}

- (void)setResponseCode:(int)code
{
	[_data setObject:[NSNumber numberWithInt:code] forKey:@"code"];
}

- (int)responseCode
{
	return [[_data objectForKey:@"code"] intValue];
}

- (void)setContent:(NSData *)toData
{
	[_data setObject:toData forKey:@"content"];
}

- (void)setContentString:(NSString *)toString
{
	[_data setObject:[toString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] forKey:@"content"];
}

- (NSData *)content
{
	return [_data objectForKey:@"content"];
}

@end
