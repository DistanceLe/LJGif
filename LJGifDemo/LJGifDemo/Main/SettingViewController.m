//
//  SettingViewController.m
//  LJGifDemo
//
//  Created by LiJie on 2017/12/21.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "SettingViewController.h"
#import "LJPhotoOperational.h"

@interface SettingViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *roopLabel;
@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@property (weak, nonatomic) IBOutlet UILabel *frameTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gifSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoPersentLabel;

@property (weak, nonatomic) IBOutlet UITextField *angleTextField;
@property (weak, nonatomic) IBOutlet UITextField *roopTextField;

@property (weak, nonatomic) IBOutlet UISwitch *livePhotoSwitch;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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

/**  是否将livePhoto当做图片 */
- (IBAction)livephotoSwitchClick:(UISwitch *)sender {
    [LJPhotoOperational shareOperational].livephotoOpen = sender.isOn;
}

/**  每帧间隔 */
- (IBAction)frameIntervalTimes:(UISlider *)sender {
    self.frameTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
    [LJPhotoOperational shareOperational].frameInterval = [self.frameTimeLabel.text floatValue];
}

/**  gif图片尺寸 */
- (IBAction)gifSize:(UISlider *)sender {
    self.gifSizeLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
    [LJPhotoOperational shareOperational].gifSize = [self.gifSizeLabel.text floatValue];
}

/**  图片压缩比例 */
- (IBAction)photoPersent:(UISlider *)sender {
    self.photoPersentLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
    [LJPhotoOperational shareOperational].photoPercent = [self.photoPersentLabel.text floatValue];
}

#pragma mark - ================ Delegate ==================
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.roopTextField) {
        NSInteger num = [textField.text integerValue];
        textField.text = @(num).stringValue;
        self.roopLabel.text = textField.text;
        [LJPhotoOperational shareOperational].roopTimes = num;
    }else if (textField == self.angleTextField){
        NSInteger num = [textField.text integerValue];
        
        self.angleLabel.text = [NSString stringWithFormat:@"%ld", num];
        [LJPhotoOperational shareOperational].angleValue = num;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





@end
