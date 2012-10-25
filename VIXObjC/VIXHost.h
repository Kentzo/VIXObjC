//
//  VIXHost.h
//  VIXObjC
//
//  Created by Ilya Kulakov on 22.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VIXObjC/vix.h>
#import <VIXObjC/VIXVirtualMachine.h>


/*!
    @discussion     It always keep connection during its lifetime or lifetime of any Virtual Machine it opened.
                    If you want to disconnect it, stop referencing it and all Virtual Machines you created using it.
 */
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
    @brief      Returns paths to configuration files (.vmx) of currently running Virtual Machines.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @result     Non-nil array representing paths to configuration files (.vmx) of currently running Virtual Machines.
                If an error occurs, array contains items found "so far".
    @discussion Result is always non-nil. You have to check outError instead.
 */
- (NSArray *)synchronouslyFindRunningVirtualMachinePaths:(__autoreleasing NSError **)outError;

/*!
    @brief      Asynchronously finds paths to configuration files (.vmx) of currently running Virtual Machines.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                aPaths is always non-nil. It contains paths to configuration files (.vmx) of currently registered Virtual Machines.
                If anError is also non-nil, aPaths represents items found before the error.
 */
- (void)findRunningVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler;

/*!
    @brief      Returns paths to configuration files (.vmx) of currently registered Virtual Machines.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @result     Non-nil array representing paths to configuration files (.vmx) of currently registered Virtual Machines.
                If an error occurs, array contains items found "so far".
    @discussion Result is always non-nil. You have to check outError instead.

    This search applies only to platform products that maintain a virtual machine registry,
    such as ESX/ESXi and VMware Server, but not Workstation or Player.
 */
- (NSArray *)synchronouslyFindRegisteredVirtualMachinePaths:(__autoreleasing NSError **)outError;

/*!
    @brief      Asynchronously finds paths to configuration files (.vmx) of currently registered Virtual Machines.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                aPaths is always non-nil. It contains paths to configuration files (.vmx) of registered registered Virtual Machines.
                If anError is also non-nil, aPaths represents items found before the error.
    @discussion This search applies only to platform products that maintain a virtual machine registry,
                such as ESX/ESXi and VMware Server, but not Workstation or Player.
 */
- (void)findRegisteredVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler;


#pragma mark Manage Virtual Machines

/*!
    @brief      Opens Virtual Machine on the receiver and returns its pointer.
    @param      aPath Path to the Virtual Machine configuration file on the host.

                The format of aPath depends on the host operating system.
                For example, a path name for a Windows host requires backslash as a directory separator,
                whereas a Linux/Mac OS X host requires a forward slash.
                If the path name includes backslash characters, you need to precede each one with an escape character.
    @discussion Returned Virtual Machine keep strong reference to the host.
                That is, host will not be disconnected until at least one Virtual Machine exist.
 */
- (VIXVirtualMachine *)synchronouslyOpenVirtualMachineAtPath:(NSString *)aPath
                                                     options:(VixVMOpenOptions)anOptions
                                                propertyList:(VixHandle)aPropertyList
                                                       error:(__autoreleasing NSError **)outError;

- (void)openVirtualMachineAtPath:(NSString *)aPath
                         options:(VixVMOpenOptions)anOptions
                    propertyList:(VixHandle)aPropertyList
               completionHandler:(void (^)(VIXVirtualMachine *aVM, NSError *anError))aCompletionHandler;

@end
