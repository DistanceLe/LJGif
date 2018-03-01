//
//  CacheTableViewController.m
//  LJGifDemo
//
//  Created by LiJie on 2018/2/5.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "CacheTableViewController.h"
#import "GifEditCollectionViewController.h"

#import "YYCache.h"

@interface CacheTableViewController ()

@property(nonatomic, strong)NSMutableArray* cacheNamesArray;
@property(nonatomic, strong)NSMutableDictionary* cacheCostNumDic;
@property(nonatomic, strong)NSMutableDictionary* cacheDic;

@end

@implementation CacheTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cacheCostNumDic = [NSMutableDictionary dictionary];
    
    YYCache* cache = [YYCache cacheWithName:allCacheNames];
    id cacheDic = [cache.diskCache objectForKey:allCacheNames];
    self.cacheDic = cacheDic;
    if ([self.cacheDic allKeys].count)  {
        NSDictionary* namesDic = cacheDic;
        NSArray* namesArray = namesDic.allKeys;
        self.cacheNamesArray = [NSMutableArray arrayWithArray:namesArray];
        DLog(@"%@", namesArray);
        
        [ProgressHUD show:@"读取数据库" autoStop:NO];
        for (NSString* name in self.cacheNamesArray) {
            YYCache* vidioCache = [YYCache cacheWithName:name];
            NSInteger cost = [vidioCache.diskCache totalCost];
            [self.cacheCostNumDic setValue:@(cost) forKey:name];
            DLog(@"cost: %ld, name:%@", cost, name);
        }
        [ProgressHUD dismiss];
        [self.tableView reloadData];
    }
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
}
-(void)dealloc{
    DLog(@"dealloc cache VC");
}

-(void)deleteItem:(NSInteger)index{
    NSString* name = [self.cacheNamesArray objectAtIndex:index];
    YYCache* cache = [YYCache cacheWithName:name];
    [ProgressHUD show:@"删除中" autoStop:NO];
    [cache.diskCache removeAllObjects];
    [self.cacheNamesArray removeObjectAtIndex:index];
    [ProgressHUD dismiss];
    
    [self.cacheCostNumDic removeObjectForKey:name];
    [self.cacheDic removeObjectForKey:name];
    YYCache* nameArrayCache = [YYCache cacheWithName:allCacheNames];
    [nameArrayCache setObject:self.cacheDic forKey:allCacheNames];
}

#pragma mark - ================ Delegate ==================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cacheNamesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.textLabel.text = self.cacheNamesArray[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", [[self.cacheCostNumDic valueForKey:self.cacheNamesArray[indexPath.row]] integerValue]/1024.0f/1024.0f];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"cache" sender:self.cacheNamesArray[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteItem:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //cache
    if ([segue.identifier isEqualToString:@"cache"]) {
        GifEditCollectionViewController* gifVC = [segue destinationViewController];
        gifVC.cacheName = sender;
    }
}

@end
