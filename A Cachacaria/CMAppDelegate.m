//
//  CMAppDelegate.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/4/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CMAppDelegate.h"

@implementation CMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Parse ID
    [Parse setApplicationId:@"I4yUEcW7Gwn5qEzoyC9eMmQbfes00PQSw8TwzOdB"
                  clientKey:@"6cRoZmsAvK7xeB8tb0y9w1EModI7HPGidx4G64Qb"];
    
    // Parse Notification
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    //Initialize Facebook
    [PFFacebookUtils initializeFacebook];
    
    [PFImageView class];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [PFFacebookUtils handleOpenURL:url];
}


#pragma mark - Parse Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

@end
