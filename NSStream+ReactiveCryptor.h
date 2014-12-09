//
//  NSStream+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <Foundation/Foundation.h>
#import "RCRDefinitions.h"

@interface NSStream (ReactiveCryptor)

/**
 Indicates when the stream has opened, using polling.
 
 @return A signal that completes when the stream is opened.
 */

- (RACSignal *)rcr_openSignal;

@end
