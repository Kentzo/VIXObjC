//
//  VIXErrors.h
//  VIXObjC
//
//  Created by Ilya Kulakov on 23.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VIXObjC/vix.h>


extern NSString *VIXErrorDomain;


@interface NSError (VIX)

+ (NSError *)VIX_errorWithVixError:(VixError)anErrorCode;

@end
