//
//  NSOutputStream+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCRDefinitions.h"
#import "NSStream+ReactiveCryptor.h"

@interface NSOutputStream (ReactiveCryptor)

/**
 Writes out the specified data.
 
 @param data The data to write.
 @return A signal that completes when the stream has written the data, or an error if one occurred while writing.
 */

- (RACSignal *)rcr_write:(NSData *)data;

@end
