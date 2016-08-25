//
//  YYBaseNavViewController.m
//  YouYunDemo
//
//  Created by Frederic on 16/1/14.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseNavViewController.h"

@interface YYBaseNavViewController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation YYBaseNavViewController

+ (void)initialize {
    
    if(self == [YYBaseNavViewController class]){
        
    }
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    
    if(self = [super initWithRootViewController:rootViewController]){
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    __weak __typeof(self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if(self.viewControllers.count > 0){
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if(gestureRecognizer == self.interactivePopGestureRecognizer){
        
        if(self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0]){
            
            return NO;
        }
    }
    
    return YES;
}

@end
