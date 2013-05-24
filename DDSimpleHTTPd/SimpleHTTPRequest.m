//
//  SimpleHTTPRequest.m
//  TouchMe
//
//  Created by Alex P on 16/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SimpleHTTPRequest.h"
#import "SimpleHTTPConnection.h"

@implementation SimpleHTTPRequest {
	NSDictionary *data;
	NSDictionary *postVars;
	NSDictionary *getVars;
}

- (id)initWithDictionary:(NSMutableDictionary *)dict
{
	if(self = [super init]) {
		data = dict;
		
		// if there was a body to the request, parse it like a query string
		if([self body] != nil) {
			postVars = [self processArgs:[[NSString alloc] initWithBytes:[[self body] bytes] length:[[self body] length] encoding:NSUTF8StringEncoding]];
		} else {
			postVars = [NSDictionary dictionary];
		}
		
		// split "blah.html?key=value&key=value" into ["blah.html", "key=value&key=value"]
		NSArray *queryString = [[[self url] absoluteString] componentsSeparatedByString:@"?"];
		
		if([queryString count] == 2) {
			[dict setObject:[NSURL URLWithString:[queryString objectAtIndex:0]] forKey:@"url"];
			getVars = [self processArgs:[queryString objectAtIndex:1]];
		} else {
			getVars = [NSDictionary dictionary];
		}
		
		data = dict;
	}
	
	return self;
}

- (NSURL *)url
{
	return [data objectForKey:@"url"];
}

- (NSString *)method
{
	return [data objectForKey:@"method"];
}

- (NSDictionary *)headers
{
	return [data objectForKey:@"headers"];
}

- (NSString *)getHeader:(NSString *)byName;
{
	NSDictionary *headers = [self headers];
	
	if(headers != nil) {
		return [headers objectForKey:byName];
	}
	
	return nil;
}

- (NSData *)body
{
	return [data objectForKey:@"body"];
}

- (SimpleHTTPConnection *)connection
{
	return [data objectForKey:@"connection"];
}

- (NSDate *)date
{
	return [data objectForKey:@"date"];
}

- (NSString *)postVar:(NSString *)byName
{
	return [postVars objectForKey:byName];
}

- (NSString *)getVar:(NSString *)byName
{
	return [getVars objectForKey:byName];
}

#pragma mark -

- (NSDictionary *)processArgs:(NSString *)args
{
	NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
	NSArray *parts = [args componentsSeparatedByString:@"&"];
	NSEnumerator *enumerator = [parts objectEnumerator];
	NSString *keyValuePair;
	
	while(keyValuePair = [enumerator nextObject]) {
		NSArray *keyValueArray = [keyValuePair componentsSeparatedByString:@"="];
		
		if([keyValueArray count] == 2) {
			[output setObject:[keyValueArray objectAtIndex:1] forKey:[keyValueArray objectAtIndex:0]];
		}
	}
	
	return output;
}

@end
