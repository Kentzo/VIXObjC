//
//  VIXObjCTests.m
//  VIXObjCTests
//
//  Created by Ilya Kulakov on 22.10.12.
//  Copyright (c) 2012 Ilya Kulakov. All rights reserved.
//

#import "VIXObjCTests.h"
#import <VIXObjC/VIXObjC.h>


@implementation VIXObjCTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    VIXHost *host = [[VIXHost alloc] initWithAPIVersion:VIX_API_VERSION
                                               hostType:VIX_SERVICEPROVIDER_VMWARE_WORKSTATION
                                               hostName:NULL
                                               hostPort:0
                                               userName:NULL
                                               password:NULL
                                                options:0];
    NSLog(@"%@", host);
}

@end
