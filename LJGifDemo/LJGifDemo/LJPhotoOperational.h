//
//  LJPhotoOperational.h
//  LJGifDemo
//
//  Created by LiJie on 2017/12/19.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJPhotoOperational : NSObject


/**  Gif配置 */
@property(nonatomic, assign)BOOL      livephotoOpen;
@property(nonatomic, assign)NSInteger roopTimes;
@property(nonatomic, assign)CGFloat angleValue;
@property(nonatomic, assign)CGFloat frameInterval;
@property(nonatomic, assign)CGFloat gifSize;
@property(nonatomic, assign)CGFloat photoPercent;


/**  选中的所有图片名字，按顺序排列 */
@property(nonatomic, strong)NSMutableArray* imageNames;

/**  获取图片操作的单例 */
+(instancetype)shareOperational;

/**  根据文件名字获取 原始数据 的地址 */
-(NSString*)getOriginDataPathWithFileName:(NSString*)name;
-(NSURL*)getOriginDataURLPathWithFileName:(NSString*)name;

/**  根据图片名字获取 缩略图片 */
-(UIImage*)getImageWithIndex:(NSInteger)index;

/**  获取原始图片， 根据设置的尺寸和压缩比例 */
-(UIImage*)getOriginImageWithIndex:(NSInteger)index;
-(UIImage*)getOriginImageWithWithName:(NSString*)name;

-(NSData*)getOriginImageDataWithWithName:(NSString*)name;

/**  获取所有的 原图片 */
-(NSArray<UIImage*>*)getAllOriginImages;

/**  保持原始图片 */
-(void)saveOriginImageData:(id)data imageName:(NSString*)name;
/**  保存缩略图 */
-(void)saveThumbnailImageData:(id)data imageName:(NSString*)name;


/**  删除选中的图片 */
-(void)deleteImageWithName:(NSString*)name;
-(void)deleteImageWithIndex:(NSInteger)index;

/**  清空所有得图片 */
-(void)deleteAllImages;

@end
