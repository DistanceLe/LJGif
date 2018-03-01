//
//  LJAlertView.m
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import "LJAlertView.h"
#import "AppDelegate.h"
//#define LJAlertButtonTextColor [UIColor whiteColor]

@interface LJAlertView ()

@end

@implementation LJAlertView


+(void)showAlertWithTitle:(NSString*)title
                  message:(NSString *)message
       showViewController:(UIViewController*)viewController
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString*>*)otherTitles
             clickHandler:(void(^)(NSInteger index, NSString* title))handler{
    
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", cancelTitle] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        if (handler){
            handler(0, cancelTitle);
        }
    }];
    //[cancelAction setValue:LJAlertButtonTextColor forKey:@"titleTextColor"];
    [alertVC addAction:cancelAction];
    
    for (NSInteger i = 0; i < otherTitles.count; i++) {
        NSString* title = otherTitles[i];
        UIAlertAction* action=[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", title] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (handler){
                handler(i+1, title);
            }
        }];
        //[action setValue:LJAlertButtonTextColor forKey:@"titleTextColor"];
        [alertVC addAction:action];
    }
    if (!viewController) {
        viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    [viewController presentViewController:alertVC animated:YES completion:nil];
}

@end
