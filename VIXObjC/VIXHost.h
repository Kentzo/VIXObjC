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
    @abstract       Objective-C friendly wrapper around VixHost functions.
    @discussion     It always keep connection during its lifetime or lifetime of any Virtual Machine it opened.
                    If you want to disconnect it, stop referencing it and all Virtual Machines you created using it.
 */
@interface VIXHost : NSObject

/*!
    @brief      Designated initializer. Initializes host with native handle which typically created using VixHost_Connect.
    @param      aNativeHandle VixHandle which typically created using VixHost_Connect.
    @result     Returns an initialized host or nil if passed handle is VIX_INVALID_HANDLE.
    @discussion By creating initializing host with a native handle you transfer ownership of the handle.
                Therefore you SHOULD NOT perform any operations using this handle anymore.
 */
- (instancetype)initWithNativeHandle:(VixHandle)aNativeHandle;

/*!
    @brief      Initialized host by connecting to the provider.
    @param      anAPIVersion MUST be VIX_API_VERSION.
    @param      aHostType With vCenter Server, ESX/ESXi hosts, and VMware Server 2.0, use VIX_SERVICEPROVIDER_VMWARE_VI_SERVER.
                With VMware Workstation/Fusion, use VIX_SERVICEPROVIDER_VMWARE_WORKSTATION.
                With VMware Workstation (shared mode), use VIX_SERVICEPROVIDER_VMWARE_WORKSTATION_SHARED.
                With VMware Player, use VIX_SERVICEPROVIDER_VMWARE_PLAYER.
                With VMware Server 1.0.x, use VIX_SERVICEPROVIDER_VMWARE_SERVER.
    @param      aHostName Varies by product platform.
                With vCenter Server, ESX/ESXi hosts, VMware Workstation (shared mode) and VMware Server 2.0,
                use a URL of the form "https://<hostName>:<port>/sdk" where <hostName> is either the DNS name or IP address.
                If missing, <port> MAY default to 443.
                In VIX API 1.10 and later, you can omit "https://" and "/sdk" specifying just the DNS name or IP address.
                Credentials are required even for connections made locally.
                With Workstation, use NULL to connect to the local host.
                With VMware Server 1.0.x, use the DNS name or IP address for remote connections, or the same as
                Workstation for local connections.
    @param      aHostPort TCP/IP port on the remote host.
                With VMware Workstation and VMware Player, use zero for the local host.
                With ESX/ESXi hosts, VMware Workstation (shared mode) and VMware Server 2.0 you specify port number
                within the hostName parameter, so this parameter is ignored.
    @param      aUserName Username for authentication on the remote machine.
                With VMware Workstation, VMware Player, and VMware Server 1.0.x, use NULL to authenticate as
                the current user on local host.
                With vCenter Server, ESX/ESXi hosts, VMware Workstation (shared mode) and VMware Server 2.0, you MUST
                use a valid login.
    @param      aPassword Password for authentication on the remote machine.
                With VMware Workstation, VMware Player, and VMware Server 1.0.x, use NULL to authenticate as
                the current user on local host.
                With ESX/ESXi, VMware Workstation (shared mode) and VMware Server 2.0, you MUST use a valid login.
    @param      anOptions SHOULD be zero or VIX_HOSTOPTION_VERIFY_SSL_CERT.
                The option VIX_HOSTOPTION_USE_EVENT_PUMP has been deprecated and MAY be removed from future versions of
                the VIX API.
    @param      aPropertyList MUST be VIX_INVALID_HANDLE.
    @result     Returns an initialized host or nil, if it's unable to connect.
    @discussion - To specify the local host (where the API client runs) with VMware Workstation and VMware Player,
                pass null values for the hostName, hostPort, userName, and password parameters.

                - With vCenter Server, ESX/ESXi hosts, and VMware Server 2.0, the URL for the hostName argument MAY
                specify the port. Otherwise an HTTPS connection is attempted on port 443. HTTPS is strongly recommended.
                Port numbers are set during installation of Server 2.0. The installer's default HTTP and HTTPS values
                are 8222 and 8333 for Server on Windows, or (if not already in use) 80 and 443 for Server on Linux,
                and 902 for the automation socket, authd. If connecting to a virtual machine though a firewall,
                port 902 and the communicating port must be opened to allow guest operations.

                - If a VMware ESX host is being managed by a VMware VCenter Server, you pass the hostname or IP address
                of the VCenter server, not the ESX host. Connecting directly to an ESX host while bypassing its
                VCenter Server can cause state inconsistency.

                - To enable SSL certificate verification, set the value of the options parameter to include the bit flag
                specified by VIX_HOSTOPTION_VERIFY_SSL_CERT. This option can also be set in the VMware config file by
                assigning vix.enableSslCertificateCheck as TRUE or FALSE. The vix.sslCertificateFile config option
                specifies the path to a file containing CA certificates in PEM format. The vix.sslCertificateDirectory
                config option can specify a directory containing files that each contain a CA certificate.
                Upon encountering a SSL validation error, the host is not created with a resulting error code of
                VIX_E_NET_HTTP_SSL_SECURITY.

                - The option VIX_HOSTOPTION_USE_EVENT_PUMP has been deprecated and may be removed from future versions
                of the VIX API.
 */
- (instancetype)initWithAPIVersion:(int)anAPIVersion
                          hostType:(VixServiceProvider)aHostType
                          hostName:(NSString *)aHostName
                          hostPort:(int)aHostPort
                          userName:(NSString *)aUserName
                          password:(NSString *)aPassword
                           options:(VixHostOptions)anOptions
                      propertyList:(VixHandle)aPropertyList;

/*!
    @brief  Initializes host by connecting to local workstation.
 */
+ (instancetype)localWorkstation;


#pragma mark Find Items

/*!
    @brief      Asynchronously finds paths to configuration files (.vmx) of currently running Virtual Machines.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                aPaths is always non-nil. It contains paths to configuration files (.vmx) of currently registered Virtual Machines.
                If anError is also non-nil, aPaths represents items found before the error.
    @see        synchronouslyFindRunningVirtualMachinePaths:
 */
- (void)findRunningVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler;

/*!
    @brief      Asynchronously finds paths to configuration files (.vmx) of currently registered Virtual Machines.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                aPaths is always non-nil. It contains paths to configuration files (.vmx) of registered registered Virtual Machines.
                If anError is also non-nil, aPaths represents items found before the error.
    @see        synchronouslyFindRegisteredVirtualMachinePaths:
 */
- (void)findRegisteredVirtualMachinePathsWithCompletionHandler:(void (^)(NSArray *aPaths, NSError *anError))aCompletionHandler;


#pragma mark Manage Virtual Machines

/*!
    @brief      Asynchronously adds a virtual machine to host's (Server of vSphere) inventory.
    @param      aPath Path to the Virtual Machine configuration file (.vmx) on the host.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                If any error occurs, anError will be non-nil.
    @see        synchronouslyRegisterVirtualMachineAtPath:error:
    @see        initWithAPIVersion:hostType:hostName:hostPort:userName:password:options:propertyList:
 */
- (void)registerVirtualMachineAtPath:(NSString *)aPath completionHandler:(void (^)(NSError *anError))aCompletionHandler;

/*!
    @brief      Asynchronously removes a virtual machine from host's (Server or vSphere) inventory.
    @param      aPath Path to the Virtual Machine configuration file (.vmx) on the host.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                If any error occurs, anError will be non-nil.
    @see        synchronouslyUnregisterVirtualMachineAtPath:error:
    @see        initWithAPIVersion:hostType:hostName:hostPort:userName:password:options:propertyList:
 */
- (void)unregisterVirtualMachineAtPath:(NSString *)aPath completionHandler:(void (^)(NSError *anError))aCompletionHandler;

/*!
    @brief      Asynchronously opens Virtual Machine on the receiver and returns its pointer.
    @param      aPath Path to the Virtual Machine configuration file on the host.
    @param      anOptions MUST be VIX_VMOPEN_NORMAL.
    @param      aPropertyList A handle to a property list containing extra information that might be needed
                to open the VM. This parameter is optional;
                you can pass VIX_INVALID_HANDLE if no extra information is needed.
    @param      aCompletionHandler The handler block to execute. MUST NOT be nil.
                If VM is successfully opened, aVM will be non-nil. Otherwise anError will be non-nil.
    @see        synchronouslyOpenVirtualMachineAtPath:options:propertyList:error:
    @see        initWithAPIVersion:hostType:hostName:hostPort:userName:password:options:propertyList:
    @see        synchronouslyRegisterVirtualMachineAtPath:error:
    @see        registerVirtualMachineAtPath:completionHandler:
 */
- (void)openVirtualMachineAtPath:(NSString *)aPath
                         options:(VixVMOpenOptions)anOptions
                    propertyList:(VixHandle)aPropertyList
               completionHandler:(void (^)(VIXVirtualMachine *aVM, NSError *anError))aCompletionHandler;

@end


@interface VIXHost (Synchronous)

/*!
    @brief      Returns paths to configuration files (.vmx) of currently running Virtual Machines.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @result     Non-nil array representing paths to configuration files (.vmx) of currently running Virtual Machines.
                If an error occurs, array contains items found "so far".
    @discussion Result is always non-nil. You have to check outError instead.
    @see        findRunningVirtualMachinePathsWithCompletionHandler:
 */
- (NSArray *)synchronouslyFindRunningVirtualMachinePaths:(__autoreleasing NSError **)outError;


/*!
    @brief      Returns paths to configuration files (.vmx) of currently registered Virtual Machines.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @result     Non-nil array representing paths to configuration files (.vmx) of currently registered Virtual Machines.
                If an error occurs, array contains items found "so far".
    @discussion Result is always non-nil. You have to check outError instead.

                This search applies only to platform products that maintain a virtual machine registry,
                such as ESX/ESXi and VMware Server, but not Workstation or Player.
    @see        findRegisteredVirtualMachinePathsWithCompletionHandler:
 */
- (NSArray *)synchronouslyFindRegisteredVirtualMachinePaths:(__autoreleasing NSError **)outError;

/*!
    @brief      Adds a virtual machine to host's (Server or vSphere) inventory.
    @param      aPath Path to the Virtual Machine configuration file (.vmx) on the host.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @discussion - You can register Virtual Machine regardless of its state.

                - The format of aPath depends on the host operating system.
                For example, a path name for a Windows host requires backslash as a directory separator,
                whereas a Linux/Mac OS X host requires a forward slash.
                If aPath includes backslash characters, you need to precede each one with an escape character.

                - It is not an error to register an already-registered virtual machine,
                although the VMware Server UI shows an error icon in the Task pane.
                Trying to register a non-existent virtual machine results in error with code VIX_E_NOT_FOUND.

                - For VMware Server 1.x, supply the full path name instead of storage path,
                and specify VIX_SERVICEPROVIDER_VMWARE_SERVER to connect.

                - Returns VIX_OK but has no effect on Workstation or Player,
                which lack a virtual machine inventory.
    @see        registerVirtualMachineAtPath:completionHandler:
    @see        initWithAPIVersion:hostType:hostName:hostPort:userName:password:options:propertyList:
 */
- (BOOL)synchronouslyRegisterVirtualMachineAtPath:(NSString *)aPath error:(__autoreleasing NSError **)outError;

/*!
    @brief      Removes a virtual machine from host's (Server or vSphere) inventory.
    @param      aPath Path to the Virtual Machine configuration file (.vmx) on the host.
    @param      outError Out parameter used if an error occurs. MAY be NULL.
    @discussion - A virtual machine must be powered off to unregister it.

                - The format of aPath depends on the host operating system.
                For example, a path name for a Windows host requires backslash as a directory separator,
                whereas a Linux/Mac OS X host requires a forward slash.
                If aPath includes backslash characters, you need to precede each one with an escape character.

                - It is not an error to unregister an already-unregistered virtual machine,
                nor is it a an error to unregister a non-existent virtual machine.

                - For VMware Server 1.x, supply the full path name instead of storage path,
                and specify VIX_SERVICEPROVIDER_VMWARE_SERVER to connect.

                - Returns VIX_OK but has no effect on Workstation or Player.

                - For ESX/ESXi hosts and vSphere, the user account specified must have "System.View" privilege
                at the level of the Data center containing the ESX server that hosts the VM to be unregistered.
    @see        unregisterVirtualMachineAtPath:completionHandler:
    @see        initWithAPIVersion:hostType:hostName:hostPort:userName:password:options:propertyList:
 */
- (BOOL)synchronouslyUnregisterVirtualMachineAtPath:(NSString *)aPath error:(__autoreleasing NSError **)outError;


/*!
    @brief      Opens Virtual Machine on the receiver and returns its pointer.
    @param      aPath Path to the Virtual Machine configuration file on the host.
    @param      anOptions MUST be VIX_VMOPEN_NORMAL.
    @param      aPropertyList A handle to a property list containing extra information that might be needed
                to open the VM. This parameter is optional;
                you can pass VIX_INVALID_HANDLE if no extra information is needed.
    @param      outError outError Out parameter used if an error occurs. MAY be NULL.
    @discussion - Returned Virtual Machine keep strong reference to the host.
                That is, host will not be disconnected until at least one Virtual Machine exist.

                - The format of aPath depends on the host operating system.
                For example, a path name for a Windows host requires backslash as a directory separator,
                whereas a Linux/Mac OS X host requires a forward slash.
                If aPath includes backslash characters, you need to precede each one with an escape character.

                - For vSphere, the virtual machine opened MAY NOT be the one desired if more than one Data center
                contains aPath.

                - For VMware Server hosts, a virtual machine must be registered before you can open it.

                - To open an encrypted virtual machine, pass a handle to a property list containing the property
                VIX_PROPERTY_VM_ENCRYPTION_PASSWORD set to the password for the virtual machine.

                - If host is created with the VIX_HOSTOPTION_VERIFY_SSL_CERT option, one must check the boolean property
                VIX_PROPERTY_VM_SSL_ERROR on the resulting Virtual Machine handle to determine if the host machine's
                SSL certificate was signed by a trusted certificate authority.

                - For ESX/ESXi hosts and vSphere, the user account MUST have "System.View" privilege at the level
                of the Data center containing the ESX server that hosts the VM to be opened.

                - For ESX/ESXi hosts and vSphere, the user account MUST have sufficient privileges to access
                guest operations in the virtual machine. For vSphere 4.1 and later, the privilege is
                "Virtual Machine.Interaction.Acquire Guest Control Ticket".
                For 4.0, the privilege is "Virtual Machine.Interaction.Console Interaction".
    @see        openVirtualMachineAtPath:options:propertyList:completionHandler:
    @see        initWithAPIVersion:hostType:hostName:hostPort:userName:password:options:propertyList:
    @see        synchronouslyRegisterVirtualMachineAtPath:error:
    @see        registerVirtualMachineAtPath:completionHandler:
 */
- (VIXVirtualMachine *)synchronouslyOpenVirtualMachineAtPath:(NSString *)aPath
                                                     options:(VixVMOpenOptions)anOptions
                                                propertyList:(VixHandle)aPropertyList
                                                       error:(__autoreleasing NSError **)outError;

@end
