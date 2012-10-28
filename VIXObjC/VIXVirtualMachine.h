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

/*!
    @brief  Number of available processors. nil if property is not applicable.
 */
- (NSNumber *)numberOfProcessors;

/*!
    @brief  Available memory size in Mbytes. nil if property is not applicable.
 */
- (NSNumber *)memorySize;

/*!
    @brief  Power state of the VM. nil if property is not applicable.
    @see
 */
- (NSNumber *)powerState;

/*!
    @brief  VMware Tools suite state of the VM. nil if property is not applicable.
    @see    VixToolsState
 */
- (NSNumber *)toolsState;

/*!
    @brief  Indicates whether VM is running. nil if property is not applicable.
 */
- (NSNumber *)isRunning;

/*!
    @brief  Indicates whether VM is read only. nil if property is not applicable.
 */
- (NSNumber *)isReadOnly;

/*!
    @brief  Name of the VM. nil if property is not applicable.
 */
- (NSString *)name;

/*!
    @brief  Path to the VM configuration file (.vmx). nil if property is not applicable.
 */
- (NSString *)path;

/*!
    @brief  Indicates whether VM is part of team. nil if property is not applicable.
 */
- (NSNumber *)isPartOfTeam;

/*!
    @brief  Path to the VM team. nil if property is not applicable.
 */
- (NSString *)teamPath;

/*!
    @brief  Codename of the guestOS. nil if property is not applicable.
 */
- (NSString *)guestOS;

/*!
    @brief  SSL Error. nil if property is not applicable.
    @see    VIXHost
 */
- (NSNumber *)sslError;

- (NSNumber *)supportedFeatures;

@end
