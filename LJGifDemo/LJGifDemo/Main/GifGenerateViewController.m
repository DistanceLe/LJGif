//
//  GifGenerateViewController.m
//  LJGifDemo
//
//  Created by LiJie on 2017/12/21.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "GifGenerateViewController.h"

#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "LJImageTools.h"

#import "LJFileOperation.h"
#import "LJPhotoOperational.h"
#import "LJPHPhotoTools.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GifGenerateViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UILabel *gifInfoLabel;
@property (nonatomic, strong)LJFileOperation* fileOperational;

@end

@implementation GifGenerateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.gifInfoLabel.text = @"图片尺寸:0*0\n图片大小:0MB";
    self.fileOperational = [LJFileOperation shareOperationWithDocument:@"gif"];
    [self showGif];
}

/**  生成Gif图片 */
- (IBAction)generateClick:(UIButton *)sender {
    [self makeAnimatedGif];
}
/**  清空 */
- (IBAction)cleanGif:(UIButton *)sender {
    @weakify(self);
    [LJAlertView showAlertWithTitle:@"清除Gif图片" message:@"" showViewController:self cancelTitle:@"取消" otherTitles:@[@"删除"] clickHandler:^(NSInteger index, NSString *title) {
        if (index == 1) {
            @strongify(self);
            [self.fileOperational deleteObjectWithName:gifName];
            [self showGif];
        }
    }];
}

- (IBAction)saveToAlbum:(UIButton *)sender {
    [LJPHPhotoTools saveImageFileToCameraRoll:[self.fileOperational getUrlFilePathComponent:gifName] handler:^(BOOL success) {
        if (success) {
            [LJInfoAlert showInfo:@"保存成功" bgColor:nil];
        }else{
            [LJInfoAlert showInfo:@"保存失败╮(╯﹏╰)╭" bgColor:nil];
        }
    }];
}

-(void)showGif{
    NSData* gifData = [self.fileOperational readObjectWithName:gifName];
    FLAnimatedImage* gifImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    if (gifImage) {
        self.gifImageView.animatedImage = gifImage;
        CGFloat sizeData = gifData.length/1024.0/1024.0;
        
        self.gifInfoLabel.text = [NSString stringWithFormat:@"图片尺寸:%.0f*%.0f\n图片大小:%.2fMB\n首页资源:%.2fMB",gifImage.size.width, gifImage.size.height, sizeData, [[LJFileOperation shareOperationWithDocument:photoDirectory] getFileSize:@""]/1024.0/1024.0];
    }else{
        self.gifInfoLabel.text = [NSString stringWithFormat:@"图片尺寸:0*0\n图片大小:0MB\n首页资源:%.2fMB", [[LJFileOperation shareOperationWithDocument:photoDirectory] getFileSize:@""]/1024.0/1024.0];
        self.gifImageView.animatedImage = nil;
    }
}

-(void)makeAnimatedGif{
    [ProgressHUD show:@"处理中..."];
    LJPhotoOperational* operational = [LJPhotoOperational shareOperational];
    
    NSMutableArray* imagesName = [NSMutableArray arrayWithArray:operational.imageNames];
    for (NSString* string in operational.imageNames) {
        if ([string hasSuffix:@".MOV"] || [string hasSuffix:@".gif"]
            || ([string hasSuffix:@".livePhoto"] && ![LJPhotoOperational shareOperational].livephotoOpen)) {
            [imagesName removeObject:string];
        }
    }
    NSUInteger kFrameCount = imagesName.count;
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @(operational.roopTimes), // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(operational.frameInterval), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    NSURL *fileURL = [self.fileOperational getUrlFilePathComponent:gifName];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            UIImage* image = [operational getOriginImageWithWithName:imagesName[i]];
            //旋转图片
            if (fabs(operational.angleValue)>0.01) {
                image = [LJImageTools rotationImage:image angle:operational.angleValue clip:NO isZoom:NO];
            }
            
            
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    NSLog(@"url=%@", fileURL);
    [self showGif];
    [ProgressHUD dismiss];
}










@end
