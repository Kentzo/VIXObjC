//
//  VIXHost.m
//  VIXObjC
//
//  Created by Ilya Kulakov on 22.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import "VIXHost.h"
#import "VIXErrors.h"


static NSString *const _VIXCompletionHandlerKey = @"block";

static NSString *const _VIXFoundItemsKey = @"foundItems";

static NSString *const _VIXHostKey = @"host";


@implementation VIXHost
{
    VixHandle _handle;
}

- (instancetype)initWithNativeHandle:(VixHandle)aNativeHandle
{
    self = [super init];
    
    if (self)
    {
        if (aNativeHandle == VIX_INVALID_HANDLE)
            return nil;

        _handle = aNativeHandle;
    }
    
    return self;
}

- (instancetype)initWithAPIVersion:(int)anAPIVersion
                          hostType:(VixServiceProvider)aHostType
                          hostName:(NSString *)aHostName
                          hostPort:(int)aHostPort
                          userName:(NSString *)aUserName
                          password:(NSString *)aPassword
                           options:(VixHostOptions)anOptions
                      propertyList:(VixHandle)aPropertyList
{
    VixHandle h = VixHost_Connect(anAPIVersion,
                                  aHostType,
                                  [aHostName UTF8String],
                                  aHostPort,
                                  [aUserName UTF8String],
                                  [aPassword UTF8String],
                                  anOptions,
                                  aPropertyList,
                                  NULL,
                                  NULL);
    VixError e = VixJob_Wait(h,
                             VIX_PROPERTY_JOB_RESULT_HANDLE,
                             &_handle,
                             VIX_PROPERTY_NONE);
    Vix_ReleaseHandle(h);
    
    if (VIX_SUCCEEDED(e))
        return [self initWithNativeHandle:h];
    else
        return nil;
}

- (void)dealloc
{
    VixHost_Disconnect(_handle);
}

+ (instancetype)localWorkstation
{
    return [[self alloc] initWithAPIVersion:VIX_API_VERSION
                                   hostType:VIX_SERVICEPROVIDER_VMWARE_WORKSTATION
                                   hostName:nil
                                   hostPort:0
                                   userName:nil
                                   password:nil
                                    options:0
                               propertyList:VIX_INVALID_HANDLE];
}


#pragma mark - Methods

#pragma mark Find Items

static void SynchronouslyFindItemsCallback(VixHandle aJobHandle,
                                           VixEventType anEventType,
                                           VixHandle anEventInfo,
                                           void *aContext)
{
    if (aContext == NULL)
        return;

    if (anEventType != VIX_EVENTTYPE_FIND_ITEM)
        return;

    char *path = NULL;
    VixError error = Vix_GetProperties(anEventInfo,
                                       VIX_PROPERTY_FOUND_ITEM_LOCATION, &path,
                                       VIX_PROPERTY_NONE);
    if (VIX_SUCCEEDED(error) && path)
    {
        NSMutableArray *foundItems = (__bridge NSMutableArray *)aContext;
        [foundItems addObject:@(path)];
        Vix_FreeBuffer(path);
    }
    else
    {
        // Ignore this error
        // TODO: log error
    }
}

static void AsynchronouslyFindItemsCallback(VixHandle aJobHandle,
                                            VixEventType anEventType,
                                            VixHandle anEventInfo,
                                            void *aContext)
{
    assert(aContext != NULL);

    if (anEventType == VIX_EVENTTYPE_FIND_ITEM)
    {
        char *path = NULL;
        VixError error = Vix_GetProperties(anEventInfo,
                                           VIX_PROPERTY_FOUND_ITEM_LOCATION, &path,
                                           VIX_PROPERTY_NONE);

        if (VIX_SUCCEEDED(error) && path)
        {
            NSDictionary *arguments = (__bridge NSDictionary *)aContext;
            NSMutableArray *foundItems = arguments[_VIXFoundItemsKey];

            assert(foundItems != nil);

            [foundItems addObject:@(path)];
            Vix_FreeBuffer(path);
        }
    }
    else if (anEventType == VIX_EVENTTYPE_JOB_COMPLETED)
    {
        NSDictionary *arguments = (NSDictionary *)CFBridgingRelease(aContext);
        void (^completionHandler)(NSArray *aPaths, NSError *anError) = arguments[_VIXCompletionHandlerKey];
        NSMutableArray *foundItems = arguments[_VIXFoundItemsKey];
        NSError *objcError = nil;

        assert(completionHandler != nil);
        assert(foundItems != nil);

        VixError jobError = VIX_OK;
        VixError error = Vix_GetProperties(aJobHandle,
                                           VIX_PROPERTY_JOB_RESULT_ERROR_CODE, &jobError,
                                           VIX_PROPERTY_NONE);
        if (VIX_SUCCEEDED(error))
        {
            if (!VIX_SUCCEEDED(jobError))
                objcError = [NSError VIX_errorWithVixError:jobError];
        }
        else
            objcError = [NSError VIX_errorWithVixError:error];

        completionHandler(foundItems, objcError);
    }
}

- (NSArray *)synchronouslyFindRunningVirtualMachinePaths:(out __autoreleasing NSError **)outError
{
    NSMutableArray *foundItems = [NSMutableArray array];
    VixHandle jobHandle = VixHost_FindItems(_handle,
                                            VIX_FIND_RUNNING_VMS,
                                            VIX_INVALID_HANDLE,
                                            -1,
                                            SynchronouslyFindItemsCallback,
                                            (__bridge void *)(foundItems));
    VixError error = VixJob_Wait(jobHandle, VIX_PROPERTY_NONE);
    Vix_ReleaseHandle(jobHandle);

    if (!VIX_SUCCEEDED(error) && outError)
        *outError = [NSError VIX_errorWithVixError:error];

    return foundItems;
}

- (void)findRunningVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler
{
    NSParameterAssert(aCompletionHandler);

    NSDictionary *arguments = @{
    _VIXCompletionHandlerKey        : [aCompletionHandler copy],
        _VIXFoundItemsKey   : [NSMutableArray array]
    };
    VixHost_FindItems(_handle,
                      VIX_FIND_RUNNING_VMS,
                      VIX_INVALID_HANDLE,
                      -1,
                      AsynchronouslyFindItemsCallback,
                      (void *)CFBridgingRetain(arguments));
}

- (NSArray *)synchronouslyFindRegisteredVirtualMachinePaths:(out __autoreleasing NSError **)outError
{
    NSMutableArray *foundItems = [NSMutableArray array];
    VixHandle jobHandle = VixHost_FindItems(_handle,
                                            VIX_FIND_REGISTERED_VMS,
                                            VIX_INVALID_HANDLE,
                                            -1,
                                            SynchronouslyFindItemsCallback,
                                            (__bridge void *)(foundItems));
    VixError error = VixJob_Wait(jobHandle, VIX_PROPERTY_NONE);
    Vix_ReleaseHandle(jobHandle);

    if (!VIX_SUCCEEDED(error) && outError)
        *outError = [NSError VIX_errorWithVixError:error];

    return foundItems;
}

- (void)findRegisteredVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler
{
    NSParameterAssert(aCompletionHandler);

    NSDictionary *arguments = @{
    _VIXCompletionHandlerKey        : [aCompletionHandler copy],
        _VIXFoundItemsKey   : [NSMutableArray array]
    };
    VixHost_FindItems(_handle,
                      VIX_FIND_REGISTERED_VMS,
                      VIX_INVALID_HANDLE,
                      -1,
                      AsynchronouslyFindItemsCallback,
                      (void *)CFBridgingRetain(arguments));
}


#pragma mark Manage Virtual Machines

static void AsynchronouslyChangeRegisterVMCallback(VixHandle aJobHandle,
                                                   VixEventType anEventType,
                                                   VixHandle anEventInfo,
                                                   void *aContext)
{
    assert (aContext != NULL);

    if (anEventType != VIX_EVENTTYPE_JOB_COMPLETED)
        return;

    NSDictionary *arguments = (NSDictionary *)CFBridgingRelease(aContext);
    void (^completionHandler)(NSError *) = arguments[_VIXCompletionHandlerKey];

    VixError jobError = VIX_OK;
    VixError error = Vix_GetProperties(aJobHandle,
                                       VIX_PROPERTY_JOB_RESULT_ERROR_CODE, &jobError,
                                       VIX_PROPERTY_NONE);

    NSError *objcError = nil;

    if (VIX_SUCCEEDED(error))
    {
        if (!VIX_SUCCEEDED(jobError))
            objcError = [NSError VIX_errorWithVixError:jobError];
    }
    else
        objcError = [NSError VIX_errorWithVixError:jobError];

    completionHandler(objcError);
}

- (BOOL)synchronouslyRegisterVirtualMachineAtPath:(NSString *)aPath error:(__autoreleasing NSError **)outError
{
    VixHandle jobHandle = VixHost_RegisterVM(_handle,
                                             [aPath UTF8String],
                                             NULL,
                                             NULL);
    VixError error = VixJob_Wait(jobHandle, VIX_PROPERTY_NONE);
    Vix_ReleaseHandle(jobHandle);

    if (VIX_SUCCEEDED(error))
        return YES;
    else if (outError)
    {
        *outError = [NSError VIX_errorWithVixError:error];
        return NO;
    }
}

- (void)registerVirtualMachineAtPath:(NSString *)aPath completionHandler:(void (^)(NSError *))aCompletionHandler
{
    NSParameterAssert(aCompletionHandler != nil);

    NSDictionary *arguments = @{
    _VIXCompletionHandlerKey    : [aCompletionHandler copy]
        };
    VixHost_RegisterVM(_handle,
                       [aPath UTF8String],
                       AsynchronouslyChangeRegisterVMCallback,
                       (void *)CFBridgingRetain(arguments));
}

- (BOOL)synchronouslyUnregisterVirtualMachineAtPath:(NSString *)aPath error:(__autoreleasing NSError **)outError
{
    VixHandle jobHandle = VixHost_UnregisterVM(_handle,
                                             [aPath UTF8String],
                                             NULL,
                                             NULL);
    VixError error = VixJob_Wait(jobHandle, VIX_PROPERTY_NONE);
    Vix_ReleaseHandle(jobHandle);

    if (VIX_SUCCEEDED(error))
        return YES;
    else if (outError)
    {
        *outError = [NSError VIX_errorWithVixError:error];
        return NO;
    }
}


static void AsynchronouslyOpenVMCallback(VixHandle aJobHandle,
                                         VixEventType anEventType,
                                         VixHandle anEventInfo,
                                         void *aContext)
{
    assert(aContext != NULL);

    if (anEventType != VIX_EVENTTYPE_JOB_COMPLETED)
        return;

    NSDictionary *arguments = (NSDictionary *)CFBridgingRelease(aContext);
    void (^completionHandler)(VIXVirtualMachine *aVM, NSError *anError) = arguments[_VIXCompletionHandlerKey];
    VIXHost *host = arguments[_VIXHostKey];

    assert(completionHandler != nil);
    assert(host != nil);

    VixError jobError = VIX_OK;
    VixHandle vmHandle = VIX_INVALID_HANDLE;
    VixError error = Vix_GetProperties(aJobHandle,
                                       VIX_PROPERTY_JOB_RESULT_ERROR_CODE, &jobError,
                                       VIX_PROPERTY_JOB_RESULT_HANDLE, &vmHandle,
                                       VIX_PROPERTY_NONE);
    VIXVirtualMachine *vm = nil;
    NSError *objcError = nil;

    if (VIX_SUCCEEDED(error))
    {
        if (VIX_SUCCEEDED(jobError))
            vm = [[VIXVirtualMachine alloc] initWithHost:host nativeVMHandle:vmHandle];
        else
            objcError = [NSError VIX_errorWithVixError:jobError];
    }
    else
        objcError = [NSError VIX_errorWithVixError:error];

    completionHandler(vm, objcError);
}

- (void)openVirtualMachineAtPath:(NSString *)aPath
                         options:(VixVMOpenOptions)anOptions
                    propertyList:(VixHandle)aPropertyList
                 completionHandler:(void (^)(VIXVirtualMachine *aVM, NSError *anError))aCompletionHandler
{
    NSParameterAssert(aCompletionHandler != nil);

    NSDictionary *arguments = @{
    _VIXCompletionHandlerKey    : [aCompletionHandler copy],
        _VIXHostKey     : self
    };
    VixHost_OpenVM(_handle,
                   [aPath UTF8String],
                   anOptions,
                   aPropertyList,
                   AsynchronouslyOpenVMCallback,
                   (void *)CFBridgingRetain(arguments));
}

- (void)unregisterVirtualMachineAtPath:(NSString *)aPath completionHandler:(void (^)(NSError *))aCompletionHandler
{
    NSParameterAssert(aCompletionHandler != nil);

    NSDictionary *arguments = @{
    _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixHost_UnregisterVM(_handle,
                         [aPath UTF8String],
                         AsynchronouslyChangeRegisterVMCallback,
                         (void *)CFBridgingRetain(arguments));
}

- (VIXVirtualMachine *)synchronouslyOpenVirtualMachineAtPath:(NSString *)aPath
                                                     options:(VixVMOpenOptions)anOptions
                                                propertyList:(VixHandle)aPropertyList
                                                       error:(__autoreleasing NSError **)outError
{
    VixHandle jobHandle = VixHost_OpenVM(_handle,
                                         [aPath UTF8String],
                                         anOptions,
                                         aPropertyList,
                                         NULL,
                                         NULL);
    VixHandle vmHandle = VIX_INVALID_HANDLE;
    VixError error = VixJob_Wait(jobHandle,
                                 VIX_PROPERTY_JOB_RESULT_HANDLE, &vmHandle,
                                 VIX_PROPERTY_NONE);
    Vix_ReleaseHandle(jobHandle);

    if (VIX_SUCCEEDED(error))
        return [[VIXVirtualMachine alloc] initWithHost:self nativeVMHandle:vmHandle];
    else
    {
        if (outError)
            *outError = [NSError VIX_errorWithVixError:error];

        return nil;
    }
}

@end
