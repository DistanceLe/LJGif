//
//  GifEditCollectionViewController.h
//  LJGifDemo
//
//  Created by LiJie on 2018/2/7.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifEditCollectionViewController : UICollectionViewController

/**  从首页进入的Gif解析 */
@property(nonatomic, strong)NSString* gifName;

/**  从缓存目录进入的 */
@property(nonatomic, strong)NSString* cacheName;


@end
