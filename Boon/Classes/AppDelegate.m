/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  Boon
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <OneSignal/OneSignal.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    
    [OneSignal  initWithLaunchOptions:launchOptions
                appId:@"49c970a6-3f9b-4822-869a-3a691a946a94"
                handleNotificationAction:nil
                settings:@{kOSSettingsKeyAutoPrompt: @false}];
    OneSignal.inFocusDisplayType = OSNotificationDisplayTypeNotification;
    
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        NSLog(@"User accepted notifications: %d", accepted);
        if (accepted) {
            OSPermissionSubscriptionState* status = [OneSignal getPermissionSubscriptionState];
            
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://app.doingboon.com/save-push"]];
            
            NSString *userUpdate = [NSString stringWithFormat:@"userId=%@", status.subscriptionStatus.userId, nil];
        
            [urlRequest setHTTPMethod:@"POST"];
        
            NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
        
            [urlRequest setHTTPBody:data1];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if(httpResponse.statusCode == 200)
                {
                    NSError *parseError = nil;
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                    NSLog(@"The response is - %@",responseDictionary);
                    NSInteger success = [[responseDictionary objectForKey:@"success"] integerValue];
                    if(success == 1) {
                        NSLog(@"Login SUCCESS");
                    } else {
                        NSLog(@"Login FAILURE");
                    }
                }
                else {
                    NSLog(@" Connection Error");
                }
            }];
            [dataTask resume];
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
