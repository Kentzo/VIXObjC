//
//  VIXVirtualMachine.m
//  VIXObjC
//
//  Created by Илья Кулаков on 23.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import "VIXVirtualMachine.h"


@implementation VIXVirtualMachine
{
    VixHandle _handle;
}

- (instancetype)initWithHost:(VIXHost *)aHost
              nativeVMHandle:(VixHandle)aNativeVMHandle
{
    self = [super init];
    
    if (self)
    {
        _host = aHost;
        _handle = aNativeVMHandle;
    }
    
    return self;
}

- (void)dealloc
{
    Vix_ReleaseHandle(_handle);
}

@end
