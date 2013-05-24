//
//  SimpleHTTPConnection.h
//  SimpleCocoaHTTPServer
//
//  Created by Jürgen Schweizer on 13.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//
//  Refactored for new objC,ARC and ios/foundation.framework 24.5.13
//  Copyright 2013 Dominik Pich
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>


@interface SimpleHTTPConnection : NSObject

- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl;
@property(nonatomic, readonly) NSFileHandle *fileHandle;
@property(nonatomic, copy) NSString *address;

@end
