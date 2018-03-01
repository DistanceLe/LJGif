//
//  LJGif.h
//  TestDemoString
//
//  Created by LiJie on 2017/12/14.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAssetImageGenerator;

@interface LJGif : NSObject


+(UIImage*)getGifImage;

/**  根据视频的路径获取 某一帧 */
+(UIImage*)getVideoPreViewImageWithURL:(NSURL*)videoPath;

/**  同步获取 根据视频的路径，一个时间点，获取 某一帧 */
+(UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

/**  异步获取 time时间的那一帧图片 */
+(void)getVideoFrameAsyncForVideo:(NSURL*)videoURL atTime:(NSTimeInterval)time complete:(void(^)(UIImage* image))handler;

/**  异步获取 time时间的那一帧图片 */
+(void)getVideoFrameAsyncWithGenerator:(AVAssetImageGenerator*)assetImageGenerator atTime:(NSTimeInterval)time complete:(void(^)(UIImage* image))handler;

@end
