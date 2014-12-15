// VDDAppDelegate.m
//
// Copyright (c) 2014 Venmo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VDDAppDelegate.h"
#import <VENVersionTracker/VENVersionTracker.h>
#import "VDDConstants.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation VDDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[CrashlyticsKit]];
    [Parse setApplicationId:VDDParseAppId
                  clientKey:VDDParseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [self startTrackingVersion];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationSettings* requestedSettings = [UIUserNotificationSettings settingsForTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:requestedSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound ];
    }
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)startTrackingVersion {
    [VENVersionTracker beginTrackingVersionForChannel:VDDChannelName
                                       serviceBaseUrl:VDDBaseUrl
                                         timeInterval:1800
                                          withHandler:^(VENVersionTrackerState state, VENVersion *version) {
                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                                  if (state == VENVersionTrackerStateDeprecated || state == VENVersionTrackerStateOutdated) {
                                                      [self promptInstallForVersion:version];
                                                  }
                                              });
                                          }];
}

- (void)promptInstallForVersion:(VENVersion *)version {
    if ([UIAlertController class]) {
        UIAlertController *alert= [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New version available", nil)
                                                                      message:NSLocalizedString(@"Please install the latest version of DryDock", nil)
                                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *install = [UIAlertAction actionWithTitle:NSLocalizedString(@"Install", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [version install];
                                                   }];
        
        [alert addAction:install];
        
        [self.window.rootViewController presentViewController:alert
                                                     animated:YES
                                                   completion:nil];
        
    } else {
        [UIAlertView showWithTitle:NSLocalizedString(@"New version available", nil) message:NSLocalizedString(@"Please install the latest version of DryDock", nil) cancelButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"Install", nil)] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }
}

@end
