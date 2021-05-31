//
//  AppDelegate.m
//  NEMeetingDemo
//
//  Copyright (c) 2014-2020 NetEase, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "SystemAuthHelper.h"
#import "LoginInfoManager.h"
#import "BaseViewController.h"
#import <NIMSDK/NIMSDK.h>
#import "NSString+Demo.h"

static NSString * const prefixName = @"meetingdemo://";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self doSetupMeetingSdk];
#if PRIVATE
/// 私有化AppKey
    [self setupIMSDKPrivateAppKey];
#endif
    [SystemAuthHelper requestAuthority];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)setupIMSDKPrivateAppKey {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NIMSDK sharedSDK] registerWithAppID:kIMAppKey cerName:nil];
    });
}
- (void)doSetupMeetingSdk {
    NEMeetingSDKConfig *config = [[NEMeetingSDKConfig alloc] init];
    config.appKey = kAppKey;
    config.reuseNIM = [LoginInfoManager shareInstance].reuseNIM;
//    config.enableDebugLog = YES;
    config.appName = @"测试APP Name";
    NELoggerConfig *loggerConfig = [[NELoggerConfig alloc] init];
    //默认等级
    loggerConfig.level = NELogLevelVerbose;
    // Document路径
    NSString *sdkDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    loggerConfig.path = [sdkDir stringByAppendingString: @"/log"];
    config.loggerConfig = loggerConfig;
    #if PRIVATE
    /// 私有化AppKey
        config.useAssetServerConfig = YES;
    #else
        config.useAssetServerConfig = NO;
    #endif
    
    [SVProgressHUD showWithStatus:@"初始化..."];
    [[NEMeetingSDK getInstance] initialize:config
                                  callback:^(NSInteger resultCode, NSString *resultMsg, id result) {
        NSLog(@"[demo init] code:%@ msg:%@ result:%@", @(resultCode), resultMsg, result);
        [SVProgressHUD dismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNEMeetingInitCompletionNotication
                                                            object:nil];
    }];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([url.absoluteString containsString:prefixName]) {
        NSDictionary *dic = [url.absoluteString queryParametersFromURLString];
        NSLog(@"dic:%@",dic);
        NSString *ssoToken = [dic objectForKey:@"ssoToken"]?:@"";
        NSString *appKey = [dic objectForKey:@"appKey"]?:@"";
        NSDictionary *ssoDict = @{@"appKey":appKey,@"ssoToken":ssoToken};

        [[NSNotificationCenter defaultCenter] postNotificationName:kNEMeetingDidGetSSOToken object:ssoDict];
        return YES;
    }
    return NO;
}


@end
