//
//  VIXVirtualMachine.h
//  VIXObjC
//
//  Created by Ilya Kulakov on 23.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VIXObjC/vix.h>


@class VIXHost;


@interface VIXVirtualMachine : NSObject

@property (strong, readonly) VIXHost *host;

- (instancetype)initWithHost:(VIXHost *)aHost
              nativeVMHandle:(VixHandle)aNativeVMHandle;

@end
