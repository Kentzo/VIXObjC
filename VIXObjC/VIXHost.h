//
//  VIXHost.h
//  VIXObjC
//
//  Created by Ilya Kulakov on 22.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VIXObjC/vix.h>


@interface VIXHost : NSObject

- (instancetype)initWithAPIVersion:(int)anAPIVersion
                          hostType:(VixServiceProvider)aHostType
                          hostName:(NSString *)aHostName
                          hostPort:(int)aHostPort
                          userName:(NSString *)aUserName
                          password:(NSString *)aPassword
                           options:(VixHostOptions)anOptions
                      propertyList:(VixHandle)aPropertyList;

+ (instancetype)localWorkstation;


#pragma mark Find Items

/*!
    @brief      Returns paths to currently running Virtual Machines.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @result     Non-nil array representing paths to currently running Virtual Machines.
                If an error occurs, array contains items found "so far".
    @discussion Result is always non-nil. You have to check outError instead.
 */
- (NSArray *)synchronouslyFindRunningVirtualMachinePaths:(out __autoreleasing NSError **)outError;

/*!
    @brief      Asynchronously finds paths to currently running Virtual Machines.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                aPaths is always non-nil. It contains paths to currently registered Virtual Machines.
                If anError is also non-nil, aPaths represents items found before the error.
 */
- (void)findRunningVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler;

/*!
    @brief      Returns paths to currently registered Virtual Machines.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @result     Non-nil array representing paths to currently registered Virtual Machines.
                If an error occurs, array contains items found "so far".
    @discussion Result is always non-nil. You have to check outError instead.

    This search applies only to platform products that maintain a virtual machine registry, such as ESX/ESXi and VMware Server, but not Workstation or Player.
 */
- (NSArray *)synchronouslyFindRegisteredVirtualMachinePaths:(out __autoreleasing NSError **)outError;

/*!
    @brief      Asynchronously finds paths to currently registered Virtual Machines.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                aPaths is always non-nil. It contains paths to registered registered Virtual Machines.
                If anError is also non-nil, aPaths represents items found before the error.
    @discussion This search applies only to platform products that maintain a virtual machine registry, such as ESX/ESXi and VMware Server, but not Workstation or Player.
 */
- (void)findRegisteredVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler;

@end
