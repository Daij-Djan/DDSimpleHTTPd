//
//  SimpleHTTPServer.m
//
//  Created by Jürgen on 19.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import "SimpleHTTPServer.h"
#import "SimpleHTTPConnection.h"
#import "SimpleHTTPResponder.h"
#import "SimpleHTTPRequest.h"
#import "SimpleHTTPResponse.h"
#import <sys/socket.h>   // for AF_INET, PF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
#import <netinet/in.h>   // for IPPROTO_TCP, sockaddr_in

@implementation SimpleHTTPServer {
    NSUInteger _port;
    NSFileHandle *_fileHandle;
    NSMutableArray *_connections;
    NSMutableArray *_requests;
    SimpleHTTPResponder *_responder;
    SimpleHTTPRequest *_currentRequest;
}

- (id)initWithTCPPort:(NSUInteger)po
            responder:(SimpleHTTPResponder *)dl
{
	if(self = [super init]) {
		_port = po;
		_responder = dl;
		_connections = [[NSMutableArray alloc] init];
		_requests = [[NSMutableArray alloc] init];
		_currentRequest = nil;
		
		int fd = -1;
		CFSocketRef socket;
		socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
		
		if(socket) {
			fd = CFSocketGetNative(socket);
			int yes = 1;
			setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
			
			struct sockaddr_in addr4;
			memset(&addr4, 0, sizeof(addr4));
			addr4.sin_len = sizeof(addr4);
			addr4.sin_family = AF_INET;
			addr4.sin_port = htons(_port);
			addr4.sin_addr.s_addr = htonl(INADDR_ANY);
			NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
			if (kCFSocketSuccess != CFSocketSetAddress(socket, (__bridge CFDataRef)address4)) {
                if(self.isLoggingEnabled)
                    NSLog(@"Could not bind to address");
			}
		} else {
            if(self.isLoggingEnabled)
                NSLog(@"No server socket");
		}
		
		_fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(newConnection:) name:NSFileHandleConnectionAcceptedNotification object:nil];
		
		[_fileHandle acceptConnectionInBackgroundAndNotify];
	}
	
	return self;
}

- (void)stop {
    [_fileHandle closeFile];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Managing connections

- (void)newConnection:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSFileHandle *remoteFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
	NSNumber *errorNo = [userInfo objectForKey:@"NSFileHandleError"];
	
	if(errorNo) {
        if(self.isLoggingEnabled)
            NSLog(@"NSFileHandle Error: %@", errorNo);
		return;
	}
	
	[_fileHandle acceptConnectionInBackgroundAndNotify];
	
	if(remoteFileHandle) {
		SimpleHTTPConnection *connection = [[SimpleHTTPConnection alloc] initWithFileHandle:remoteFileHandle delegate:self];
		
		if(connection) {
			NSIndexSet *insertedIndexes = [NSIndexSet indexSetWithIndex:_connections.count];
			[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"connections"];
			[_connections addObject:connection];
			[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"connections"];
		}
	}
}

- (void)closeConnection:(SimpleHTTPConnection *)connection;
{
	NSUInteger connectionIndex = [_connections indexOfObjectIdenticalTo:connection];
	
	if(connectionIndex == NSNotFound) {
		return;
	}

	// We remove all pending requests pertaining to connection
	NSMutableIndexSet *obsoleteRequests = [NSMutableIndexSet indexSet];
	BOOL stopProcessing = NO;
	int k;
	
	for(k = 0; k < [_requests count]; k++) {
		SimpleHTTPRequest *request = [_requests objectAtIndex:k];
		
		if([request connection] == connection) {
			if(request == [self currentRequest]) {
				stopProcessing = YES;
			}
			
			[obsoleteRequests addIndex:k];
		}
	}
	
	NSIndexSet *connectionIndexSet = [NSIndexSet indexSetWithIndex:connectionIndex];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:obsoleteRequests forKey:@"requests"];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:connectionIndexSet forKey:@"connections"];
	[_requests removeObjectsAtIndexes:obsoleteRequests];
	[_connections removeObjectsAtIndexes:connectionIndexSet];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:connectionIndexSet forKey:@"connections"];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:obsoleteRequests forKey:@"requests"];
	
	if(stopProcessing) {
		[_responder stopProcessing];
		_currentRequest = nil;
	}
	
	[self processNextRequestIfNecessary];
}


#pragma mark Managing requests

- (void)newRequestWithURL:(NSURL *)url method:(NSString *)method body:(NSData *)body headers:(NSDictionary *)headers connection:(SimpleHTTPConnection *)connection
{
    if(self.isLoggingEnabled) {
        NSLog(@"request for: %@ method: %@ body: %@", url, method, body);
        NSLog(@"requestWithURL:connection:");
    }
    if( url == nil ) return;
    
    SimpleHTTPRequest *request = [[SimpleHTTPRequest alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys: url, @"url", method, @"method", body, @"body", headers, @"headers", connection, @"connection", [NSDate date], @"date", nil]];
    
    NSIndexSet *insertedIndexes = [NSIndexSet indexSetWithIndex:_requests.count];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"requests"];
    [_requests addObject:request];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"requests"];
    
    [self processNextRequestIfNecessary];
}

- (void)processNextRequestIfNecessary
{
    if( _currentRequest == nil && _requests.count ) {
        _currentRequest = [_requests objectAtIndex:0];
		
		SimpleHTTPResponse *response;
		
		if([[_currentRequest method] isEqualToString:@"POST"]) {
			response = [_responder processPOST:_currentRequest];
		} else {
			response = [_responder processGET:_currentRequest];
		}
		
		[self processResponse:response];
    }
}

#pragma mark Sending replies

// The Content-Length header field will be automatically added
- (void)processResponse:(SimpleHTTPResponse *)response
{
    if(self.isLoggingEnabled)
        NSLog(@"sending output");
	
	CFHTTPMessageRef msg;
    msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response responseCode], NULL, kCFHTTPVersion1_1); // Use standard status description 
	
    NSEnumerator *keys = [[response headers] keyEnumerator];
    NSString *key;
    while( key = [keys nextObject] ) {
        id value = [[response headers] objectForKey:key];
        if( ![value isKindOfClass:[NSString class]] ) value = [value description];
        if( ![key isKindOfClass:[NSString class]] ) key = [key description];
        CFHTTPMessageSetHeaderFieldValue(msg, (__bridge CFStringRef)key, (__bridge CFStringRef)value);
    }
	
    if([response content]) {
        NSString *length = [NSString stringWithFormat:@"%ld", (unsigned long)[[response content] length]];
        CFHTTPMessageSetHeaderFieldValue(msg, (CFStringRef)@"Content-Length", (__bridge CFStringRef)length);
        CFHTTPMessageSetBody(msg, (__bridge CFDataRef)[response content]);
    }
    
    CFDataRef msgData = CFHTTPMessageCopySerializedMessage(msg);
    @try {
        NSFileHandle *remoteFileHandle = [[[self currentRequest] connection] fileHandle];
        [remoteFileHandle writeData:(__bridge NSData *)msgData];
	}
    @catch (NSException *exception) {
        if(self.isLoggingEnabled)
            NSLog(@"Error while sending response (%@): %@", [[self currentRequest] url], [exception  reason]);
    }
    
    CFRelease(msgData);
    CFRelease(msg);
    
    // A reply indicates that the current request has been completed
    // (either successfully of by responding with an error message)
    // Hence we need to remove the current request:
    NSUInteger index = [_requests indexOfObjectIdenticalTo:[self currentRequest]];
    if( index != NSNotFound ) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"requests"];
        [_requests removeObjectsAtIndexes:indexSet];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"requests"];
    }
    _currentRequest = nil;
    [self processNextRequestIfNecessary];
}

@end
