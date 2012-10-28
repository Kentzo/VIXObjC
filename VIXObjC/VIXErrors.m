//
//  VIXErrors.m
//  VIXObjC
//
//  Created by Ilya Kulakov on 23.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import "VIXErrors.h"


NSString *VIXErrorDomain = @"com.kulakov.VIXObjC";


@implementation NSError (VIX)

+ (NSError *)VIX_errorWithVixError:(VixError)anErrorCode
{
    const char *errorText = Vix_GetErrorText(anErrorCode, NULL);
    return [NSError errorWithDomain:VIXErrorDomain
                               code:anErrorCode
                           userInfo:errorText ? @{NSLocalizedDescriptionKey : @(errorText)} : nil];
}

@end
