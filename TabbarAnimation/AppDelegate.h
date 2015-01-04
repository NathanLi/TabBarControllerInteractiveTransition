//
//  AppDelegate.h
//  TabbarAnimation
//
//  Created by nathan@hoomic.com on 14-12-27.
//  Copyright (c) 2014年 Hoomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) UITabBarController *tabBarController;
@end

