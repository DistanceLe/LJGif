//
//  GifEditCollectionViewController.m
//  LJGifDemo
//
//  Created by LiJie on 2018/2/7.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "GifEditCollectionViewController.h"
#import "FLAnimatedImage.h"
#import "LJPhotoOperational.h"
#import "TimeTools.h"
#import "LJPHPhotoTools.h"
#import "LJImageTools.h"
#import "YYCache.h"

#import "LJPhotoCollectionViewCell.h"

@interface GifEditCollectionViewController ()

@property(nonatomic, strong)FLAnimatedImage* gifImage;
@property(nonatomic, strong)NSMutableArray* selectedIndex;
@property(nonatomic, strong)NSMutableDictionary* frameImages;

@property (nonatomic, strong)YYCache* imageCache;

@end

@implementation GifEditCollectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing=8;
    layout.minimumInteritemSpacing=8;
    layout.itemSize=CGSizeMake((IPHONE_WIDTH-8)/2.0, (IPHONE_WIDTH-8)/2.0);
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LJPhotoCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellIdentify];
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self initData];
}

-(void)initData{
    self.selectedIndex=[NSMutableArray array];
    NSInteger imageCount = 0;
    if (self.cacheName) {
        self.title = @"帧缓存";
        self.imageCache = [YYCache cacheWithName:self.cacheName];
        imageCount = self.imageCache.diskCache.totalCount;
        
    }else if(self.gifName){
        self.frameImages = [NSMutableDictionary dictionary];
        NSData* gifData = [[LJPhotoOperational shareOperational]getOriginImageDataWithWithName:self.gifName];
        self.gifImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
        imageCount = self.gifImage.frameCount;
    }
    
    for (NSInteger i=0; i<imageCount; i++) {
        [self.selectedIndex addObject:@(NO)];
    }
    
    [self.collectionView reloadData];
}

-(void)dealloc{
    DLog(@"....");
}

#pragma mark - ================ Action ==================

- (IBAction)albumClick:(UIBarButtonItem *)sender {
    NSArray<UIImage*>* images = [self getSelectedImages];
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //保存原始图片到相册
        [LJPHPhotoTools saveImageToCameraRoll:obj handler:^(BOOL success) {
            if (idx == images.count-1 && success) {
                [LJInfoAlert showInfo:@"保存相册成功" bgColor:nil];
            }else{
                [LJInfoAlert showInfo:@"保存相册失败" bgColor:nil];
            }
        }];
    }];
}
- (IBAction)mainPageClick:(UIBarButtonItem *)sender {
    NSArray<UIImage*>* images = [self getSelectedImages];
    __block long long timestamp = [TimeTools getCurrentTimestamp];
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //保存原始图片
        NSString* tempName = [@((timestamp++)) stringValue];
        NSData* imageData = UIImageJPEGRepresentation(obj, 0.9);
        
        [[LJPhotoOperational shareOperational]saveOriginImageData:[UIImage imageWithData:imageData] imageName:tempName];
        
        //保存缩略图
        if (obj.size.width > IPHONE_WIDTH/1.5 || obj.size.height > IPHONE_WIDTH/1.5) {
            obj = [LJImageTools changeImage:[UIImage imageWithData:imageData] toRatioSize:CGSizeMake(IPHONE_WIDTH/1.5, IPHONE_WIDTH/1.5)];
        }
        [[LJPhotoOperational shareOperational]saveThumbnailImageData:obj imageName:tempName];
        if (idx == images.count-1) {
            [LJInfoAlert showInfo:@"保存首页成功" bgColor:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:photoSavedName object:nil];
        }
    }];
}

-(NSArray* )getSelectedImages{
    NSMutableArray* images = [NSMutableArray array];
    for (NSInteger i = 0; i<self.selectedIndex.count; i++) {
        if ([self.selectedIndex[i] boolValue]) {
            if (self.cacheName) {//缓存模式
                [images addObject:[self.imageCache objectForKey:@(i).stringValue]];
            }else if (self.gifName){
                [images addObject:[self.frameImages valueForKey:@(i).stringValue]];
            }
        }
    }
    return images;
}

#pragma mark - ================ Delegate ==================
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedIndex.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LJPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentify forIndexPath:indexPath];
    cell.gifImageView.hidden = YES;
    cell.videoDurationTimeLabel.hidden = YES;
    cell.selectButton.hidden=NO;
    cell.headImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (self.cacheName) {//缓存模式
        cell.headImageView.image = (UIImage*)[self.imageCache objectForKey:@(indexPath.row).stringValue];
        
    }else if (self.gifName){//gif 模式
        UIImage* image = [self.frameImages valueForKey:[@(indexPath.item) stringValue]];
        if (image) {
            cell.headImageView.image = image;
            DLog(@"直接取");
        }else{
            UIImage* frameImage = [self.gifImage imageLazilyCachedAtIndex:indexPath.item];
            if (frameImage) {
                DLog(@"动态取...-----------");
                [self.frameImages setValue:frameImage forKey:[@(indexPath.item) stringValue]];
                cell.headImageView.image = frameImage;
            }else{
                DLog(@"找不到图片La %ld", indexPath.item);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        }
    }
    cell.selectButton.selected=[self.selectedIndex[indexPath.item] boolValue];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LJPhotoCollectionViewCell* cell=(LJPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected=!cell.selectButton.selected;
    [self.selectedIndex replaceObjectAtIndex:indexPath.item withObject:@(cell.selectButton.selected)];
}

@end
