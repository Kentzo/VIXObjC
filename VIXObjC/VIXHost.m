//
//  VIXHost.m
//  VIXObjC
//
//  Created by Ilya Kulakov on 22.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import "VIXHost.h"


@implementation VIXHost
{
    VixHandle _handle;
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
    self = [super init];

    if (self)
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

        if (!VIX_SUCCEEDED(e))
            return nil;
    }

    return self;
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

@end
