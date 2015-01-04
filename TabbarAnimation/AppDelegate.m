//
//  AppDelegate.m
//  TabbarAnimation
//
//  Created by nathan@hoomic.com on 14-12-27.
//  Copyright (c) 2014年 Hoomic. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "SwipeLeftInteractiveTransition.h"

@interface AppDelegate ()<UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;
@property (nonatomic, strong) UIPanGestureRecognizer     *panGesture;
@property (nonatomic, assign) BOOL                                  interacting;

@end

@implementation AppDelegate

- (UITabBarController *)tabBarController {
  return (UITabBarController *)self.window.rootViewController;
}


#pragma mark - UITabBarControllerDelegate
- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController {
  return self.interacting ? self.interactivePopTransition : nil;
}

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC {
  return self;
}

#pragma mark - Life cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.tabBarController.delegate = self;
  self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
  self.panGesture.delegate = self;
  
  [self.tabBarController.view addGestureRecognizer:self.panGesture];
  
  return YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
  CGPoint point = [gestureRecognizer translationInView:gestureRecognizer.view];
  
  CGPoint pointTabView = [gestureRecognizer locationInView:gestureRecognizer.view];
  if (CGRectContainsPoint(self.tabBarController.tabBar.frame, pointTabView)) {
    return NO;
  }
  
  if (point.x < 0) {
    return self.tabBarController.selectedIndex < ([self.tabBarController.viewControllers count] - 1);
  } else {
    return self.tabBarController.selectedIndex > 0;
  }
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
  UIView *view = gesture.view;
  CGPoint point = [gesture translationInView:view];
  CGFloat percent = fabs(point.x / CGRectGetWidth(view.bounds));
  UIGestureRecognizerState state = gesture.state;
  BOOL isRight = [gesture translationInView:gesture.view].x < 0;
  
  if (state == UIGestureRecognizerStateBegan) {
    self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
    self.interacting = YES;
    if (isRight) {
      self.tabBarController.selectedIndex = self.tabBarController.selectedIndex + 1;
    } else {
      self.tabBarController.selectedIndex = self.tabBarController.selectedIndex - 1;
    }
  } else if ( state == UIGestureRecognizerStateChanged) {
    [self.interactivePopTransition updateInteractiveTransition:percent];
  } else if (state == UIGestureRecognizerStateEnded) {
    if (percent > .4) {
      [self.interactivePopTransition finishInteractiveTransition];
    } else {
      [self.interactivePopTransition cancelInteractiveTransition];
    }
    self.interacting = NO;
  } else if (state == UIGestureRecognizerStateCancelled) {
    [self.interactivePopTransition cancelInteractiveTransition];
    self.interacting = NO;
  }
}


#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return .5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
  UIView *toView   = [transitionContext viewForKey:UITransitionContextToViewKey];
  
  UIView *containerView = [transitionContext containerView];
  CGRect rectFromView = [transitionContext initialFrameForViewController:fromVC];
  CGRect rectEndView  = [transitionContext finalFrameForViewController:toVC];
  
  NSUInteger indexFromVC = [self.tabBarController.viewControllers indexOfObject:fromVC];
  NSUInteger indexToVC   = [self.tabBarController.viewControllers indexOfObject:toVC];
  CGFloat dir = indexFromVC < indexToVC ? 1 : -1;
  CGRect  fromEndRect = CGRectOffset(rectFromView, -(CGRectGetWidth(rectFromView) * dir), .0);
  
  CGRect rectToViewStart = CGRectOffset(rectEndView, CGRectGetWidth(rectEndView) * dir, .0);
  toView.frame = rectToViewStart;
  
  [containerView addSubview:toView];
  
  if (!self.interacting) {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
  }
  
  UIViewAnimationOptions option = self.interacting ? UIViewAnimationOptionCurveEaseOut : 0;
  [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:.0 options:option animations:^{
    fromView.frame = fromEndRect;
    toView.frame = rectEndView;
  } completion:^(BOOL finished) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      BOOL isCancelled = [transitionContext transitionWasCancelled];
      [transitionContext completeTransition:!isCancelled];
      [UIView setAnimationsEnabled:YES];
      if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
      }
    });
  }];
}

@end
