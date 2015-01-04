//
//  SwipeLeftInteractiveTransition.h
//  TabbarAnimation
//
//  Created by nathan@hoomic.com on 14-12-27.
//  Copyright (c) 2014年 Hoomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeLeftInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL interacting;
- (void)wireToViewController:(UIViewController *)viewContoller;

@end
