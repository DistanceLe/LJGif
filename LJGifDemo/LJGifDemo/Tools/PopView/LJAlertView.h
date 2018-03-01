//
//  LJAlertView.h
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommitBlock)(NSInteger flag);

@interface LJAlertView : UIView

/**  cancel的Index = 0， 其他从1开始依次累加 */
+(void)showAlertWithTitle:(NSString*)title
                  message:(NSString *)message
       showViewController:(UIViewController*)viewController
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString*>*)otherTitles
             clickHandler:(void(^)(NSInteger index, NSString* title))handler;

@end
