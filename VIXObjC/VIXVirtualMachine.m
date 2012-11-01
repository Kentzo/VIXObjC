//
//  VIXVirtualMachine.m
//  VIXObjC
//
//  Created by Илья Кулаков on 23.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import "VIXVirtualMachine.h"
#import "VIXErrors.h"


static NSString *const _VIXCompletionHandlerKey = @"block";


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


#pragma mark Properties

static NSString* GetStringProperty(VixHandle aVMHandle, VixPropertyID aPropertyID)
{
    VixPropertyType type = VIX_PROPERTYTYPE_ANY;
    VixError error = Vix_GetPropertyType(aVMHandle,
                                         aPropertyID,
                                         &type);

    if (VIX_SUCCEEDED(error) && type == VIX_PROPERTYTYPE_STRING)
    {
        char *string = NULL;
        error = Vix_GetProperties(aVMHandle,
                                  aPropertyID, &string,
                                  VIX_PROPERTY_NONE);
        NSString *objcString = nil;

        if (VIX_SUCCEEDED(error))
            objcString = @(string);

        Vix_FreeBuffer(string);
        return objcString;
    }
    else
        return nil;
}

static NSNumber* GetNumberProperty(VixHandle aVMHandle, VixPropertyID aPropertyID)
{
    VixPropertyType type = VIX_PROPERTYTYPE_ANY;
    VixError error = Vix_GetPropertyType(aVMHandle,
                                         aPropertyID,
                                         &type);

    if (VIX_SUCCEEDED(error))
    {
        switch (type)
        {
            case VIX_PROPERTYTYPE_INTEGER:
            {
                int value = 0;
                error = Vix_GetProperties(aVMHandle,
                                          aPropertyID, &value,
                                          VIX_PROPERTY_NONE);

                if (VIX_SUCCEEDED(error))
                    return @(value);
                else
                    return nil;
            }
            case VIX_PROPERTYTYPE_INT64:
            {
                long long value = 0;
                error = Vix_GetProperties(aVMHandle,
                                          aPropertyID, &value,
                                          VIX_PROPERTY_NONE);

                if (VIX_SUCCEEDED(error))
                    return @(value);
                else
                    return nil;
            }
            case VIX_PROPERTYTYPE_BOOL:
            {
                Bool value = 0;
                error = Vix_GetProperties(aVMHandle,
                                          aPropertyID, &value,
                                          VIX_PROPERTY_NONE);

                if (VIX_SUCCEEDED(error))
                    return @(value);
                else
                    return nil;
            }
            default:
                return nil;
        }
    }
    else
        return nil;
}

- (NSNumber *)numberOfProcessors
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_NUM_VCPUS);
}

- (NSString *)path
{
    return GetStringProperty(_handle, VIX_PROPERTY_VM_VMX_PATHNAME);
}

- (NSString *)teamPath
{
    return GetStringProperty(_handle, VIX_PROPERTY_VM_VMTEAM_PATHNAME);
}

- (NSNumber *)memorySize
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_MEMORY_SIZE);
}

- (NSNumber *)isReadOnly
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_READ_ONLY);
}

- (NSString *)name
{
    return GetStringProperty(_handle, VIX_PROPERTY_VM_NAME);
}

- (NSString *)guestOS
{
    return GetStringProperty(_handle, VIX_PROPERTY_VM_GUESTOS);

}

- (NSNumber *)sslError
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_SSL_ERROR);
}

- (NSNumber *)supportedFeatures
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_SUPPORTED_FEATURES);
}

- (NSNumber *)isPartOfTeam
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_IN_VMTEAM);
}

- (NSNumber *)powerState
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_POWER_STATE);
}

- (NSNumber *)toolsState
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_TOOLS_STATE);
}

- (NSNumber *)isRunning
{
    return GetNumberProperty(_handle, VIX_PROPERTY_VM_IS_RUNNING);
}


#pragma mark Methods

static void PowerOperationCallback(VixHandle aJobHandle,
                                   VixEventType anEventType,
                                   VixHandle anEventInfo,
                                   void *aContext)
{
    if (aContext == NULL)
        return;

    if (anEventType != VIX_EVENTTYPE_JOB_COMPLETED)
        return;

    VixError error = VixJob_GetError(aJobHandle);
    NSError *objcError = nil;

    if (!VIX_SUCCEEDED(error))
        objcError = [NSError VIX_errorWithVixError:error];

    NSDictionary *arguments = (NSDictionary *)CFBridgingRelease(aContext);
    void (^completionHandler)(NSError *anError) = arguments[_VIXCompletionHandlerKey];
    completionHandler(objcError);
}

- (void)pauseWithCompletionHandler:(void (^)(NSError *))aCompletionHandler
{
    NSDictionary *arguments = @{
        _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixVM_Pause(_handle,
                0,
                VIX_INVALID_HANDLE,
                PowerOperationCallback,
                (void *)CFBridgingRetain(arguments));
}

- (void)unpauseWithCompletionHandler:(void (^)(NSError *))aCompletionHandler
{
    NSDictionary *arguments = @{
        _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixVM_Unpause(_handle,
                  0,
                  VIX_INVALID_HANDLE,
                  PowerOperationCallback,
                  (void *)CFBridgingRetain(arguments));
}

- (void)powerOffFromGuest:(BOOL)aFromGuest completionHandler:(void (^)(NSError *anError))aCompletionHandler
{
    NSDictionary *arguments = @{
        _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixVM_PowerOff(_handle,
                   aFromGuest ? VIX_VMPOWEROP_FROM_GUEST : VIX_VMPOWEROP_NORMAL,
                   PowerOperationCallback,
                   (void *)CFBridgingRetain(arguments));
}

- (void)powerOnWithGUI:(BOOL)aShouldShowGUI completionHandler:(void (^)(NSError *))aCompletionHandler
{
    NSDictionary *arguments = @{
        _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixVM_PowerOn(_handle,
                  aShouldShowGUI ? VIX_VMPOWEROP_LAUNCH_GUI : VIX_VMPOWEROP_NORMAL,
                  VIX_INVALID_HANDLE,
                  PowerOperationCallback,
                  (void *)CFBridgingRetain(arguments));
}

- (void)resetFromGuest:(BOOL)aFromGuest completionHandler:(void (^)(NSError *anError))aCompletionHandler
{
    NSDictionary *arguments = @{
        _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixVM_Reset(_handle,
                aFromGuest ? VIX_VMPOWEROP_FROM_GUEST : VIX_VMPOWEROP_NORMAL,
                PowerOperationCallback,
                (void *)CFBridgingRetain(arguments));
}

- (void)suspendWithCompletionHandler:(void (^)(NSError *))aCompletionHandler
{
    NSDictionary *arguments = @{
        _VIXCompletionHandlerKey    : [aCompletionHandler copy]
    };
    VixVM_Suspend(_handle,
                  0,
                  PowerOperationCallback,
                  (void *)CFBridgingRetain(arguments));
}

@end
