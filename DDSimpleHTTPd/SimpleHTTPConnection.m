//
//  SimpleHTTPConnection.m
//  SimpleCocoaHTTPServer
//
//  Created by Jürgen Schweizer on 13.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import "SimpleHTTPConnection.h"
#import "SimpleHTTPServer.h"
#import <netinet/in.h>      // for sockaddr_in
#import <arpa/inet.h>       // for inet_ntoa

@implementation SimpleHTTPConnection {
    NSFileHandle *fileHandle;
    id delegate;
    NSString *address;  // client IP address
	
    CFHTTPMessageRef message;
    BOOL isMessageComplete;
	
	NSMutableData *messageBuffer;
}

@synthesize fileHandle;
@synthesize address;

- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl
{
	if(self = [super init]) {
		fileHandle = fh;
		delegate = dl;
		isMessageComplete = YES;
		message = NULL;
		
		messageBuffer = [[NSMutableData alloc] init];
		
		// Get IP address of remote client
		CFSocketRef socket;
		socket = CFSocketCreateWithNative(kCFAllocatorDefault, [fileHandle fileDescriptor], kCFSocketNoCallBack, NULL, NULL);
		CFDataRef addrData = CFSocketCopyPeerAddress(socket);
		CFRelease(socket);
		
		if(addrData) {
			struct sockaddr_in *sock = (struct sockaddr_in *)CFDataGetBytePtr(addrData);
			char *naddr = inet_ntoa(sock->sin_addr);
			[self setAddress:[NSString stringWithCString:naddr encoding:NSUTF8StringEncoding]];
			CFRelease(addrData);
		} else {
			[self setAddress:@"NULL"];
		}

		// Register for notification when data arrives
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(dataReceivedNotification:) name:NSFileHandleReadCompletionNotification object:fileHandle];
		[fileHandle readInBackgroundAndNotify];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if(message) {
		CFRelease(message);
	}
}

- (void)dataReceivedNotification:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
//	NSLog(@"info: %@", [notification userInfo]);
	if ([data length] == 0) {
		// NSFileHandle's way of telling us that the client closed the connection
		[self closeConnection];
	} else {
		if(isMessageComplete) {
			message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
		}
		
		[messageBuffer appendBytes:[data bytes] length:[data length]];
		
		Boolean success = CFHTTPMessageAppendBytes(message, [data bytes], [data length]);
		
		if(success) {
			if([self isMessageComplete]) {
				[self processMessage];
			}
		} else {
			NSLog(@"Incomming message not a HTTP header, ignored.");
			[self closeConnection];
		}
		
		[fileHandle readInBackgroundAndNotify];
	}
}

- (void)processMessage
{
	CFURLRef url = CFHTTPMessageCopyRequestURL(message);
	CFDataRef body = CFHTTPMessageCopyBody(message);
	CFStringRef method = CFHTTPMessageCopyRequestMethod(message);
	CFDictionaryRef headers = CFHTTPMessageCopyAllHeaderFields(message);
	
	// inform the delegate that a message has been received
	[delegate newRequestWithURL:(__bridge NSURL *)url
                         method:(__bridge NSString *)method
                           body:(__bridge NSData *)body
                        headers:(__bridge NSDictionary *)headers connection:self];
	
	CFRelease(url);
	CFRelease(body);
	CFRelease(method);
	CFRelease(headers);
	CFRelease(message);
	message = NULL;
}

- (void)closeConnection
{
	[delegate closeConnection:self];
	isMessageComplete = YES;
	message = NULL;
}

- (BOOL)isMessageComplete
{
	isMessageComplete = NO;
	
	if(CFHTTPMessageIsHeaderComplete(message)) {
		isMessageComplete = YES;
		
		CFStringRef contentLengthHeader = CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Content-Length"));
		
		if(contentLengthHeader != NULL) {
			// get expected content length
			int contentLength = CFStringGetIntValue(contentLengthHeader);
			CFRelease(contentLengthHeader);
			
			// get actual content length
			CFDataRef messageBody = CFHTTPMessageCopyBody(message);
			NSUInteger bodyLength = CFDataGetLength(messageBody);
			CFRelease(messageBody);
			
			// have we got the entire message body?
			if(contentLength != bodyLength) {
				isMessageComplete = NO;
			}
		}
	}
	
	return isMessageComplete;
}

@end
