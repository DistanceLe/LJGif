//
//  LJPhotoOperational.m
//  LJGifDemo
//
//  Created by LiJie on 2017/12/19.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJPhotoOperational.h"

#import "LJFileOperation.h"
#import "LJImageTools.h"

@interface LJPhotoOperational()

@property(nonatomic, strong)LJFileOperation* originOperation;
@property(nonatomic, strong)LJFileOperation* thumbnailOperation;

/**  已经读取的图片Data */
@property(nonatomic, strong)NSMutableDictionary* thumbnailImages;

@end

@implementation LJPhotoOperational

+(instancetype)shareOperational{
    static dispatch_once_t onceToken;
    static LJPhotoOperational* operational = nil;
    dispatch_once(&onceToken, ^{
        if (operational == nil) {
            operational = [[LJPhotoOperational alloc]init];
            [operational initData];
        }
    });
    return operational;
}

-(void)initData{
    self.livephotoOpen = YES;
    self.roopTimes = 0;
    self.frameInterval = 0.2;
    self.gifSize = 1;
    self.photoPercent = 1;
    
    
    self.thumbnailOperation = [LJFileOperation shareOperationWithDocument:thumbnailDirectory];
    self.originOperation = [LJFileOperation shareOperationWithDocument:photoDirectory];
    self.thumbnailImages = [NSMutableDictionary dictionary];
    self.imageNames = [NSMutableArray array];
    NSArray* names = [self.thumbnailOperation readAllFileName];
    if (names.count>0) {
        [self.imageNames setArray:names];
    }
}

-(UIImage*)getImageWithIndex:(NSInteger)index{
    
    NSString* name;
    if (self.imageNames.count>index) {
        name = self.imageNames[index];
    }else{
        return nil;
    }
    if ([self.thumbnailImages valueForKey:name]) {
        return [self.thumbnailImages valueForKey:name];
    }else{
        NSData* imageData = [self.thumbnailOperation readObjectWithName:name];
        UIImage* image = [UIImage imageWithData:imageData];
        [self.thumbnailImages setValue:image forKey:name];
        return image;
    }
}
-(UIImage*)getOriginImageWithIndex:(NSInteger)index{
    NSString* name;
    if (self.imageNames.count>index) {
        name = self.imageNames[index];
    }else{
        return nil;
    }
    NSData* imageData = [self.originOperation readObjectWithName:name];
    UIImage* image = [UIImage imageWithData:imageData];
    imageData = UIImageJPEGRepresentation(image, self.photoPercent);
    image = [LJImageTools changeImage:[UIImage imageWithData:imageData] toRatio:self.gifSize];
    
    return image;
}
-(NSArray<UIImage *> *)getAllOriginImages{
    NSMutableArray* imagesData = [NSMutableArray array];
    for (NSString* name in self.imageNames) {
        NSData* data = [self.originOperation readObjectWithName:name];
        UIImage* image = [UIImage imageWithData:data];
        [imagesData addObject:image];
    }
    return imagesData;
}

-(UIImage*)getOriginImageWithWithName:(NSString*)name{
   
    NSData* imageData = [self.originOperation readObjectWithName:name];
    UIImage* image = [UIImage imageWithData:imageData];
    imageData = UIImageJPEGRepresentation(image, self.photoPercent);
    image = [LJImageTools changeImage:[UIImage imageWithData:imageData] toRatio:self.gifSize];
    
    return image;
}
-(NSData*)getOriginImageDataWithWithName:(NSString*)name{
    NSData* imageData = [self.originOperation readObjectWithName:name];
    return imageData;
}
/**  根据文件名字获取 原始数据 的地址 */
-(NSString*)getOriginDataPathWithFileName:(NSString*)name{
    NSString* filePath = [self.originOperation readFilePath:name];
    return filePath;
}
-(NSURL*)getOriginDataURLPathWithFileName:(NSString*)name{
    NSURL* filePath = [self.originOperation getUrlFilePathComponent:name];
    return filePath;
}
/**  保持原始图片 */
-(void)saveOriginImageData:(id)data imageName:(NSString*)name{
    [self.originOperation saveObject:data name:name];
}
/**  保存缩略图 */
-(void)saveThumbnailImageData:(id)data imageName:(NSString*)name{
    [self.thumbnailOperation saveObject:data name:name];
    [self.imageNames addObject:name];
}


-(void)deleteImageWithName:(NSString *)name{
    [self.thumbnailOperation deleteObjectWithName:name];
    [self.originOperation deleteObjectWithName:name];
    [self.imageNames removeObject:name];
    [self.thumbnailImages removeObjectForKey:name];
}
-(void)deleteImageWithIndex:(NSInteger)index{
    NSString* name;
    if (self.imageNames.count>index) {
        name = self.imageNames[index];
    }else{
        return;
    }
    [self.imageNames removeObject:name];
    [self.thumbnailImages removeObjectForKey:name];
    
    [self.thumbnailOperation deleteObjectWithName:name];
    [self.originOperation deleteObjectWithName:name];
    DLog(@"删除 index=%ld", index);
}
-(void)deleteAllImages{
    [self.thumbnailImages removeAllObjects];
    [self.imageNames removeAllObjects];
    
    [self.thumbnailOperation deleteAllFile];
    [self.originOperation deleteAllFile];
}

@end
