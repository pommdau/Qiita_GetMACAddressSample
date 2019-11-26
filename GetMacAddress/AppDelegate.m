//
//  AppDelegate.m
//  GetMacAddress

#import "AppDelegate.h"
#include <stdio.h>
#include <string.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <net/if_types.h>

@interface AppDelegate ()
@property (weak) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSArray *macAddressList = [NSArray arrayWithArray:[self getMACAddress]];
    [_arrayController setContent:macAddressList];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

/**
 @brief MACアドレスを取得する
 */
- (NSArray *)getMACAddress {
    struct ifaddrs      *ifa_list, *ifa;
    struct sockaddr_dl  *dl;
    char                name[12];
    unsigned char       *addr;
    char                macAddress[18];
    NSMutableArray      *macAddressArray = [NSMutableArray array];
    // getifaddrs()で，MACアドレスも含めたネットワーク・インターフェース情報の一覧を取得できます。
    if (getifaddrs(&ifa_list) < 0) {
        return @[ @{@"name": @"", @"address" : @""} ];
    }
    for (ifa = ifa_list; ifa != NULL; ifa = ifa->ifa_next) {
        dl = (struct sockaddr_dl*)ifa->ifa_addr;
        if (dl->sdl_family == AF_LINK && dl->sdl_type == IFT_ETHER) {
            memcpy(name, dl->sdl_data, dl->sdl_nlen);
            name[dl->sdl_nlen] = '\0';
            addr = LLADDR(dl);
//            printf("%s: %02x:%02x:%02x:%02x:%02x:%02x\n",
//                   name,
//                   addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
            
            sprintf(macAddress, "%02x:%02x:%02x:%02x:%02x:%02x",
                    addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
            NSDictionary *macAddressDic = @{@"name"    : [NSString stringWithCString:name       encoding:NSUTF8StringEncoding],
                                            @"address" : [NSString stringWithCString:macAddress encoding:NSUTF8StringEncoding],
                                            };
            [macAddressArray addObject:macAddressDic];
        }
    }
    freeifaddrs(ifa_list);
    return macAddressArray.copy;
}

@end
