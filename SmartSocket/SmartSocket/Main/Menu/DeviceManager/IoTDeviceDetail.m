/**
 * IoTDeviceDetail.m
 *
 * Copyright (c) 2014~2015 Xtreme Programming Group, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "IoTDeviceDetail.h"
#import "IoTAlertView.h"
#import "IoTPhotoRecorder.h"
#import "IoTDeviceSelectIcon.h"
#import "IoTInputView.h"

@interface IoTDeviceDetail () <XPGWifiDeviceDelegate, XPGWifiSDKDelegate, IoTInputViewDelegate, IoTAlertViewDelegate>
{
    //默认用于显示的名字
    NSString *strDefDispName;
}

@property (nonatomic, strong) XPGWifiDevice *device;

//设备信息
@property (weak, nonatomic) IBOutlet UITextView *textHWInfo;

//显示设备名称
@property (weak, nonatomic) IBOutlet UILabel *textProductName;

//图标
@property (weak, nonatomic) IBOutlet UIButton *imageIcon;

//图标底下的白色区域
@property (weak, nonatomic) IBOutlet UIView *viewWhite;

@end

@implementation IoTDeviceDetail

- (id)initWithDevice:(XPGWifiDevice *)device
{
    self = [super init];
    if(self)
    {
        self.device = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"设备管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    //为view倒圆角
    self.viewWhite.layer.masksToBounds =YES;
    self.viewWhite.layer.cornerRadius = 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [XPGWifiSDK sharedInstance].delegate = self;
    self.device.delegate = self;
    
    //小循环请求设备信息
    if(self.device.isOnline && self.device.isLAN)
        [self.device getHardwareInfo];
    else
        self.textHWInfo.text = @"无设备信息";
    
    NSInteger iconIndex = [IoTPhotoRecorder photoIndex:self.device];
    NSDictionary *dict = [IoTPhotoRecorder resources][iconIndex];
    UIImage *iconNormal = [dict valueForKey:@"table"];
    strDefDispName = [dict valueForKey:@"name"];
    
    [self.imageIcon setBackgroundImage:iconNormal forState:UIControlStateNormal];
    
    //设备名称
    if(self.device.remark.length == 0)
        self.textProductName.text = strDefDispName;
    else
        self.textProductName.text = self.device.remark;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [XPGWifiSDK sharedInstance].delegate = nil;
    self.device.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)onBack {
    if(self.navigationController.viewControllers.lastObject == self)
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDelete:(id)sender {
    [[[IoTAlertView alloc] initWithMessage:@"插座删除后需要重新配置才能控制，确认要删除吗？" delegate:self titleOK:@"确定" titleCancel:@"取消"] show:YES];
}

- (IBAction)onRename:(id)sender {
    [[[IoTInputView alloc] initWithTitle:@"重命名" content:self.device.remark defaultCtx:strDefDispName delegate:self titleOK:nil titleCancel:nil] show:YES];
}

- (IBAction)onChangeIcon:(id)sender {
    IoTDeviceSelectIcon *selectCtrl = [[IoTDeviceSelectIcon alloc] initWithDevice:self.device];
    [self.navigationController pushViewController:selectCtrl animated:YES];
}

#pragma mark - XPGWifiDeviceDelegate
- (void)XPGWifiDevice:(XPGWifiDevice *)device didQueryHardwareInfo:(NSDictionary *)hwInfo
{
    if(!hwInfo)
    {
        self.textHWInfo.text = @"获取设备信息失败。\n\n\n\n\n\n\n";
    }
    else
    {
        self.textHWInfo.text = [NSString stringWithFormat:@"WiFi Hardware Version: %@,\n\
WiFi Software Version: %@\n\
MCU Hardware Version: %@\n\
MCU Software Version: %@\n\
Firmware Id: %@\n\
Firmware Version: %@\n\
Product Key: %@\n\
Device ID: %@", [hwInfo valueForKey:XPGWifiDeviceHardwareWifiHardVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareWifiSoftVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUHardVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUSoftVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareIdKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareProductKey], self.device.did];
    }
}

- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didBindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage
{
    //更新别名
    if([error intValue] == 0)
    {
        //更新列表
        IoTAppDelegate.hud.labelText = @"更新列表...";
        [[XPGWifiSDK sharedInstance] getBoundDevicesWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken specialProductKeys:IOT_PRODUCT, nil];
    }
    else
    {
        //未能更新
        [IoTAppDelegate.hud hide:YES];
        NSString *message = [NSString stringWithFormat:@"无法为此设备设置别名，错误码：%@", error];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUnbindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage
{
    //删除设备
    if([error intValue] == 0)
    {
        //退回到列表
        if(self.navigationController.viewControllers.lastObject == self)
        {
            for(UIViewController *controller in self.navigationController.viewControllers)
            {
                if([controller isKindOfClass:[IoTDeviceList class]])
                {
                    NSLog(@"viewControllers: %@", self.navigationController.viewControllers);
                    NSLog(@"controller: %@", controller);
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        }
        [IoTAppDelegate.hud hide:YES];
    }
    else
    {
        [IoTAppDelegate.hud hide:YES];
        //未能删除
        NSString *message = [NSString stringWithFormat:@"无法删除此设备，错误码：%@", error];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result
{
    //分类
    NSMutableArray
    *arr1 = [NSMutableArray array], //在线
    *arr2 = [NSMutableArray array], //新设备
    *arr3 = [NSMutableArray array]; //不在线
    
    for(XPGWifiDevice *device in deviceList)
    {
        if(device.isLAN && ![device isBind:[IoTProcessModel sharedModel].currentUid])
        {
            [arr2 addObject:device];
            continue;
        }
        if(device.isLAN || device.isOnline)
        {
            [arr1 addObject:device];
            continue;
        }
        [arr3 addObject:device];
    }
    
    [IoTProcessModel sharedModel].devicesList = @[arr1, arr2, arr3];

    [IoTAppDelegate.hud performSelector:@selector(hide:) withObject:@YES afterDelay:0.2];
    
    //0.2s后自动退回到列表
    [self performSelector:@selector(onBack) withObject:nil afterDelay:0.2];
}

- (void)IoTInputViewDidDismissButton:(IoTInputView *)inputView withText:(NSString *)text
{
    if(nil != text)
    {
        const char *productName = [text UTF8String];
        BOOL isAllSpace = NO;
        for(int i=0; i<text.length; i++)
        {
            if(productName[i] == ' ')
            {
                if(i == 0)
                    isAllSpace = YES;
            }
            else
            {
                if(isAllSpace == YES)
                    isAllSpace = NO;
                break;
            }
        }
        
        if(isAllSpace)
        {
            //全都是空格？
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"输入的名称不能全部是空格" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return;
        }

        IoTAppDelegate.hud.labelText = @"正在更新设备名...";
        [IoTAppDelegate.hud show:YES];
        
        [[XPGWifiSDK sharedInstance] bindDeviceWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken did:self.device.did passCode:self.device.passcode remark:text];
    }
}

- (void)IoTAlertViewDidDismissButton:(IoTAlertView *)alertView withButton:(BOOL)isConfirm
{
    if(isConfirm)
    {
        IoTAppDelegate.hud.labelText = @"删除中...";
        [IoTAppDelegate.hud show:YES];
        [[XPGWifiSDK sharedInstance] unbindDeviceWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken did:self.device.did passCode:self.device.passcode];
    }
}

@end
