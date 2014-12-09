//
//  RNEncryptor+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNEncryptor.h"
#import "RCRDefinitions.h"

/**
 ReactiveCryptor strikes to be extremely powerful and extremely simple -- much like RNCryptor itself.  It doesn't allow
 much in the way of configuration, but does cover the most common use cases.
 */

@interface RNEncryptor (ReactiveCryptor)

/**
 Encrypts the specified data with the password.
 
 @param data A block of data.
 @param password A password.
 @return A signal that will at some point contain a block of encrypted data, or an error if the data could not be 
 encrypted.
 */

+ (RACSignal *)rcr_encryptData:(NSData *)data password:(NSString *)password;

@end
