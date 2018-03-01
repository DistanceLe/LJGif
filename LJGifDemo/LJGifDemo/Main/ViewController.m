//
//  ViewController.m
//  LJGifDemo
//
//  Created by LiJie on 2017/12/15.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "LJPhotoAlbumTableViewController.h"
#import "VideoEditViewController.h"
#import "GifEditCollectionViewController.h"

#import "LJPhotoCollectionViewCell.h"


#import "LJPhotoOperational.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong, nonatomic)UIButton *cleanAllBut;

@property(nonatomic, strong)NSMutableArray<NSIndexPath*>* editIndexPaths;
@property(nonatomic, assign)BOOL isEdit;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initData];
    [self initUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //self.hidesBottomBarWhenPushed = NO;
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count >1) {
        self.tabBarController.tabBar.hidden = YES;
        //self.hidesBottomBarWhenPushed = YES;
    }
}


-(void)initData{
    self.editIndexPaths = [NSMutableArray array];
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter]addObserverForName:photoSavedName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self refreshData];
    }];
}

-(void)initUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc]init];
    NSInteger itemWidth=(IPHONE_WIDTH-9)/4;
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.sectionInset = UIEdgeInsetsMake(2, 0, 2, 0);
    
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LJPhotoCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellIdentify];
    UILongPressGestureRecognizer* longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
    longGesture.minimumPressDuration = 0.1;
    [self.collectionView addGestureRecognizer:longGesture];
    
    
    UIButton* rightBut = [UIButton buttonWithType:UIButtonTypeSystem];
    rightBut.frame = CGRectMake(0, 0, 44, 44);
    [rightBut setTitle:@"相册" forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    @weakify(self);
    [rightBut addTargetClickHandler:^(UIButton *but, id obj) {
        @strongify(self);
        if (self.isEdit) {
            [self deleteItems];
        }else{
            LJPhotoAlbumTableViewController* albumVC = [[LJPhotoAlbumTableViewController alloc]init];
            [self.navigationController pushViewController:albumVC animated:YES];
        }
    }];
    
    self.cleanAllBut = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cleanAllBut.frame = CGRectMake(0, 0, 44, 44);
    [self.cleanAllBut setTitle:@"" forState:UIControlStateNormal];
    self.cleanAllBut.enabled = NO;
    [self.cleanAllBut setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBut];
    UIBarButtonItem* cleanItem = [[UIBarButtonItem alloc]initWithCustomView:self.cleanAllBut];
    self.navigationItem.rightBarButtonItems = @[rightItem, cleanItem];
    
    
    UIButton* leftBut = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBut.frame = CGRectMake(0, 0, 44, 44);
    [leftBut setTitle:@"编辑" forState:UIControlStateNormal];
    [leftBut setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [leftBut addTargetClickHandler:^(UIButton *but, id obj) {
        @strongify(self);
        self.isEdit = !self.isEdit;
        if (self.isEdit) {
            [but setTitle:@"完成" forState:UIControlStateNormal];
            [rightBut setTitle:@"删除" forState:UIControlStateNormal];
            self.cleanAllBut.enabled = YES;
            [self.cleanAllBut setTitle:@"清空" forState:UIControlStateNormal];
        }else{
            [but setTitle:@"编辑" forState:UIControlStateNormal];
            [rightBut setTitle:@"相册" forState:UIControlStateNormal];
            self.cleanAllBut.enabled = NO;
            [self.cleanAllBut setTitle:@"" forState:UIControlStateNormal];
        }
        [self.collectionView reloadData];
    }];
    
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBut];
    self.navigationItem.leftBarButtonItems = @[leftItem];
    
    
    [self.cleanAllBut addTargetClickHandler:^(UIButton *but, id obj) {
        @strongify(self);
        [LJAlertView showAlertWithTitle:@"删除全部" message:@"确认删除所有的图片" showViewController:self cancelTitle:@"取消" otherTitles:@[@"删除"] clickHandler:^(NSInteger index, NSString *title) {
            if (index == 1) {
                [[LJPhotoOperational shareOperational]deleteAllImages];
                
                self.isEdit = !self.isEdit;
                [but setTitle:@"编辑" forState:UIControlStateNormal];
                [rightBut setTitle:@"相册" forState:UIControlStateNormal];
                self.cleanAllBut.enabled = NO;
                [self.cleanAllBut setTitle:@"" forState:UIControlStateNormal];
                [self.collectionView reloadData];
            }
        }];
    }];
}

-(void)refreshData{
    [self.collectionView reloadData];
}
-(void)deleteItems{
    @weakify(self);
    if (self.editIndexPaths.count>0) {
    [LJAlertView showAlertWithTitle:@"删除" message:@"确认删除选中的图片" showViewController:self cancelTitle:@"取消" otherTitles:@[@"删除"] clickHandler:^(NSInteger index, NSString *title) {
        if (index == 1) {
            @strongify(self);
            NSMutableArray* names = [NSMutableArray array];
            for (NSIndexPath* indexPath in self.editIndexPaths) {
                [names addObject: [LJPhotoOperational shareOperational].imageNames[indexPath.item]];
            }
            for (NSString* name in names) {
                [[LJPhotoOperational shareOperational]deleteImageWithName:name];
            }
            
            NSArray* deleteItems = [NSArray arrayWithArray:self.editIndexPaths];
            [self.editIndexPaths removeAllObjects];
            
            [self.collectionView deleteItemsAtIndexPaths:deleteItems];
        }
    }];
    }
}
-(void)longGesture:(UILongPressGestureRecognizer*)longGesture{
    //获取此次点击的坐标，根据坐标获取cell对应的indexPath
    CGPoint point = [longGesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    //根据长按手势的状态进行处理。
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
            //当没有点击到cell的时候不进行处理
            if (!indexPath) {
                break;
            }
            //开始移动
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程中更新位置坐标
            [self.collectionView updateInteractiveMovementTargetPosition:point];
            break;
        case UIGestureRecognizerStateEnded:
            //停止移动调用此方法
            [self.collectionView endInteractiveMovement];
            break;
        default:
            //取消移动
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}


#pragma mark - ================ Delegate ==================
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [LJPhotoOperational shareOperational].imageNames.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LJPhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentify forIndexPath:indexPath];
    
    cell.headImageView.image=[[LJPhotoOperational shareOperational]getImageWithIndex:indexPath.item];
    
    if ([[LJPhotoOperational shareOperational].imageNames[indexPath.item] hasSuffix:@".MOV"]) {
        cell.playImageView.hidden = NO;
    }else{
        cell.playImageView.hidden = YES;
    }
    if ([[LJPhotoOperational shareOperational].imageNames[indexPath.item] hasSuffix:@".gif"]) {
        cell.gifImageView.hidden = NO;
    }else{
        cell.gifImageView.hidden = YES;
    }
    if ([[LJPhotoOperational shareOperational].imageNames[indexPath.item] hasSuffix:@".livePhoto"]) {
        cell.livePhotoImageView.hidden = NO;
    }else{
        cell.livePhotoImageView.hidden = YES;
    }
    
    
    if (self.isEdit) {
        cell.selectButton.hidden=NO;
        cell.selectButton.selected=[self.editIndexPaths containsObject:indexPath];
    }else{
        cell.selectButton.hidden=YES;
    }
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isEdit) {
        LJPhotoCollectionViewCell* cell=(LJPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selectButton.selected=!cell.selectButton.selected;
        if (cell.selectButton.selected) {
            [self.editIndexPaths addObject:indexPath];
        }else{
            [self.editIndexPaths removeObject:indexPath];
        }
    }else{
        //是否是视频，视频则进去 编辑
        NSString* imageName = [LJPhotoOperational shareOperational].imageNames[indexPath.item];
        
        if ([imageName hasSuffix:@".MOV"] || [imageName hasSuffix:@".livePhoto"]) {
            [self performSegueWithIdentifier:@"videoEdit" sender:imageName];
            
        }else if ([imageName hasSuffix:@".gif"]) {
            [self performSegueWithIdentifier:@"gifEdit" sender:imageName];
        }
    }
}

#pragma mark - ================ Edit ==================
-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    if ([LJPhotoOperational shareOperational].imageNames.count > sourceIndexPath.item &&
        [LJPhotoOperational shareOperational].imageNames.count > destinationIndexPath.item) {
        id source = [[LJPhotoOperational shareOperational].imageNames objectAtIndex:sourceIndexPath.item];
        [[LJPhotoOperational shareOperational].imageNames removeObjectAtIndex:sourceIndexPath.item];
        [[LJPhotoOperational shareOperational].imageNames insertObject:source atIndex:destinationIndexPath.item];
    }
}

#pragma mark - ================ Segue ==================
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"videoEdit"]) {
        VideoEditViewController* videoVC = [segue destinationViewController];
        videoVC.videoName = sender;
    }else if ([segue.identifier isEqualToString:@"gifEdit"]) {
        GifEditCollectionViewController* gifVC = [segue destinationViewController];
        gifVC.gifName = sender;
    }
}

@end
