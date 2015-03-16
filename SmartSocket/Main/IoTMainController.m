/**
 * IoTMainController.m
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

#import "IoTMainController.h"
#import "IoTSubscribe.h"
#import "IoTMainMenu.h"
#import "IoTSubscribe.h"
#import "IoTTimingSubscribe.h"

@interface IoTMainController ()
{
    //数据点临时变量
    BOOL bOnOff;
    NSInteger iWeekRepeat;
    NSInteger iTimeOn;
    NSInteger iTimeOff;
    NSInteger iCountDown;
    BOOL bTimeSwitch;
    BOOL bCountDownSwitch;
    NSInteger iPowerConsumption;
}

//开关
@property (weak, nonatomic) IBOutlet UIButton *btnSwitch;

//详细信息，包括定时、延时
@property (weak, nonatomic) IBOutlet UIView *viewTiming;
@property (weak, nonatomic) IBOutlet UIView *viewCountDown;
@property (weak, nonatomic) IBOutlet UILabel *textTiming;
@property (weak, nonatomic) IBOutlet UILabel *textCountDown;

//用电量
@property (weak, nonatomic) IBOutlet UIView *viewPower;
@property (weak, nonatomic) IBOutlet UILabel *textConsumption;

//更新
@property (assign, nonatomic) BOOL reloading;
@property (strong, nonatomic) IoTAlertView *alertView;

@end

@implementation IoTMainController

- (id)initWithDevice:(XPGWifiDevice *)device
{
    self = [super init];
    if(self)
    {
        if(nil == device)
        {
            NSLog(@"warning: device can't be null.");
            return nil;
        }
        _device = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"控制";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.device.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initDevice];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if([self.navigationController.viewControllers indexOfObject:self] >= self.navigationController.viewControllers.count)
    {
        self.device.delegate = nil;
    }
}

- (void)dealloc
{
    //退到设备列表，Cleanup
    self.device.delegate = nil;
    [self.alertView hide:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDevice {
    //设备已解除绑定，或者断开连接，退出
    if(![self.device isBind:[IoTProcessModel sharedModel].currentUid] || !self.device.isConnected)
    {
        [self onDisconnected];
        return;
    }
    
    //初始化数据点
    bOnOff = NO;
    iWeekRepeat = 0;
    iTimeOn = 1080;
    iTimeOff = 1320;
    iCountDown = 0;
    bTimeSwitch = NO;
    bCountDownSwitch = NO;
    iPowerConsumption = 0;
    
    //更新页面内容
    [self updateUI];

    //更新侧边菜单数据
    [((IoTMainMenu *)[SlideNavigationController sharedInstance].leftMenu).tableView reloadData];
    
    //在页面加载后，自动更新数据
    if(self.device.isOnline)
    {
        [self onReload];
    }
    
    self.view.userInteractionEnabled = self.device.isOnline;
}

- (void)updateUI
{
    self.btnSwitch.selected = bOnOff;
    if(bOnOff)
    {
        //更新定时、延时信息
        self.textTiming.text = [NSString stringWithFormat:@"%02i:%02i～%02i:%02i",
                                GetHourFromMinutes(self.timeOn),
                                GetMinuteFromMinutes(self.timeOn),
                                GetHourFromMinutes(self.timeOff),
                                GetMinuteFromMinutes(self.timeOff)];
        self.textCountDown.text = [NSString stringWithFormat:@"%02i:%02i",
                                   GetHourFromMinutes(self.countDownTimer),
                                   GetMinuteFromMinutes(self.countDownTimer)];
        
        [self.view bringSubviewToFront:self.viewPower];
        
        
        //用电量信息
        NSString *strPower = [NSString stringWithFormat:@"%@", @(iPowerConsumption)];
        
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]
                                           initWithString:@"用电量："
                                           attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                                         NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [mStr appendAttributedString:[[NSMutableAttributedString alloc]
                                      initWithString:strPower
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:24],
                                                   NSForegroundColorAttributeName: [UIColor colorWithRed:0.992157 green:0.819608 blue:0.219608 alpha:1]}]];
        [mStr appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:@"度"
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                                   NSForegroundColorAttributeName: [UIColor colorWithRed:0.992157 green:0.819608 blue:0.219608 alpha:1]}]];
        
        self.textConsumption.attributedText = mStr;
        
        //时间信息的开关，单独打开才显示
        if(bTimeSwitch)
            [self.view bringSubviewToFront:self.viewTiming];
        else
            [self.view sendSubviewToBack:self.viewTiming];
        
        if(bCountDownSwitch)
            [self.view bringSubviewToFront:self.viewCountDown];
        else
            [self.view sendSubviewToBack:self.viewCountDown];
        
        [self.view bringSubviewToFront:self.btnSwitch];
    }
    else
    {
        [self.view sendSubviewToBack:self.viewPower];
        [self.view sendSubviewToBack:self.viewTiming];
        [self.view sendSubviewToBack:self.viewCountDown];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (void)onDisconnected {
    //断线且页面在控制页面时才弹框
    UIViewController *currentController = self.navigationController.viewControllers.lastObject;

    if(!self.device.isConnected &&
       ([currentController isKindOfClass:[IoTMainController class]] ||
        [currentController isKindOfClass:[IoTSubscribe class]] ||
        [currentController isKindOfClass:[IoTTimingSubscribe class]]))
    {
        [IoTAppDelegate.hud hide:YES];
        [[[IoTAlertView alloc] initWithMessage:@"连接已断开" delegate:nil titleOK:@"确定"] show:YES];
        
        //退出到列表
        for(UIViewController *controller in self.navigationController.viewControllers)
        {
            if([controller isKindOfClass:[IoTDeviceList class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
    }
}

- (IBAction)onSwitch:(id)sender {
    IoTAppDelegate.hud.labelText = @"请稍候...";
    [IoTAppDelegate.hud show:YES];

    bOnOff = !bOnOff;
    
    [self writeDataPoint:IoTDeviceWriteOnOff value:@(bOnOff)];
    
    //关机清理预约
    if(!bOnOff)
    {
        [self writeDataPoint:IoTDeviceWriteCountDownSwitch value:@NO];
        [self writeDataPoint:IoTDeviceWriteCountDown value:@0];
    }
    
    [self onReload];
}

- (IBAction)onSubscribe:(id)sender {
    IoTSubscribe *subscribeCtrl = [[IoTSubscribe alloc] init];
    [self.navigationController pushViewController:subscribeCtrl animated:YES];
}

- (void)onReload
{
    IoTAppDelegate.hud.labelText = @"正在更新数据...";
    [IoTAppDelegate.hud showAnimated:YES whileExecutingBlock:^{
        NSLog(@"loading...");
        for(int i=0; i<1200; i++)
        {
            if(!self.reloading)
                return;
            usleep(50000);
        }
        NSLog(@"load timeout.");
        if(self.reloading)
            [self performSelectorOnMainThread:@selector(onReloadFailed) withObject:nil waitUntilDone:YES];
    }];

    [self writeDataPoint:IoTDeviceWriteUpdateData value:nil];
}

- (void)onReloadFailed
{
    [self.alertView hide:YES];
    self.alertView = [[IoTAlertView alloc] initWithMessage:@"网络异常，无法加载设备数据" delegate:nil titleOK:@"确定"];
    [self.alertView show:YES];
}

#pragma mark - Properties
- (void)setDevice:(XPGWifiDevice *)device
{
    _device.delegate = nil;
    _device = device;
    [self initDevice];
}

- (void)setTimeOn:(NSInteger)timeOn
{
    iTimeOn = timeOn;
}

- (NSInteger)timeOn
{
    return iTimeOn;
}

- (void)setTimeOff:(NSInteger)timeOff
{
    iTimeOff = timeOff;
}

- (NSInteger)timeOff
{
    return iTimeOff;
}

- (void)setCountDownTimer:(NSInteger)countDownTimer
{
    iCountDown = countDownTimer;
}

- (NSInteger)countDownTimer
{
    return iCountDown;
}

- (void)setTimingSwitch:(BOOL)timingSwitch
{
    bTimeSwitch = timingSwitch;
}

- (BOOL)timingSwitch
{
    return bTimeSwitch;
}

- (void)setCountDownSwitch:(BOOL)countDownSwitch
{
    bCountDownSwitch = countDownSwitch;
}

- (BOOL)countDownSwitch
{
    return bCountDownSwitch;
}

- (void)setRepeatIndexes:(NSArray *)repeatIndexes
{
    iWeekRepeat = 0;
    for(NSNumber *num in repeatIndexes)
    {
        NSInteger index = [num integerValue];
        switch (index) {
            case 0:
                iWeekRepeat |= WEAK_REPEAT_MONDAY;
                break;
            case 1:
                iWeekRepeat |= WEAK_REPEAT_TUESDAY;
                break;
            case 2:
                iWeekRepeat |= WEAK_REPEAT_WEDNESDAY;
                break;
            case 3:
                iWeekRepeat |= WEAK_REPEAT_THURSDAY;
                break;
            case 4:
                iWeekRepeat |= WEAK_REPEAT_FRIDAY;
                break;
            case 5:
                iWeekRepeat |= WEAK_REPEAT_SATURDAY;
                break;
            case 6:
                iWeekRepeat |= WEAK_REPEAT_SUNDAY;
                break;
            default:
                break;
        }
    }
}

- (void)setRepeatIndexes:(NSArray *)repeatIndexes withDataPoint:(BOOL)isDataPoint
{
    [self setRepeatIndexes:repeatIndexes];
    if(isDataPoint)
        [self writeDataPoint:IoTDeviceWriteWeekRepeat value:@(iWeekRepeat)];
}

- (NSArray *)repeatIndexes
{
    NSMutableArray *indexes = [NSMutableArray array];
    if(iWeekRepeat & WEAK_REPEAT_MONDAY)
        [indexes addObject:@0];
    if(iWeekRepeat & WEAK_REPEAT_TUESDAY)
        [indexes addObject:@1];
    if(iWeekRepeat & WEAK_REPEAT_WEDNESDAY)
        [indexes addObject:@2];
    if(iWeekRepeat & WEAK_REPEAT_THURSDAY)
        [indexes addObject:@3];
    if(iWeekRepeat & WEAK_REPEAT_FRIDAY)
        [indexes addObject:@4];
    if(iWeekRepeat & WEAK_REPEAT_SATURDAY)
        [indexes addObject:@5];
    if(iWeekRepeat & WEAK_REPEAT_SUNDAY)
        [indexes addObject:@6];
    
    return [NSArray arrayWithArray:indexes];
}

#pragma mark -
+ (instancetype)currentController
{
    //返回当前已经存在到实例
    for(UIViewController *controller in IoTAppDelegate.navCtrl.viewControllers)
    {
        if([controller isMemberOfClass:[IoTMainController class]])
            return (id)controller;
    }
    return nil;
}

#pragma mark - Data Point
- (void)writeDataPoint:(IoTDeviceDataPoint)dataPoint value:(id)value
{
    NSDictionary *data = nil;
    switch (dataPoint) {
        case IoTDeviceWriteUpdateData:
            if(self.reloading)
            {
                NSLog(@"Could not reload data, because the data is reloading.");
                return;
            }
            self.reloading = YES;
            data = @{DATA_CMD: @(IoTDeviceCommandRead)};
            break;
        case IoTDeviceWriteOnOff:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_ONOFF: value}};
            break;
        case IoTDeviceWriteWeekRepeat:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_WEEK_REPEAT: value}};
            break;
        case IoTDeviceWriteTimeOn:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_ON_MINUTE: value}};
            break;
        case IoTDeviceWriteTimeOff:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_OFF_MINUTE: value}};
            break;
        case IoTDeviceWriteCountDown:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_COUNTDOWN_MINUTE: value}};
            break;
        case IoTDeviceWriteTimeSwitch:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_TIME_ONOFF: value}};
            break;
        case IoTDeviceWriteCountDownSwitch:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite), DATA_ENTITY: @{DATA_ATTR_COUNTDOWN_ONOFF: value}};
            break;
        default:
            NSLog(@"Error: write invalid datapoint, skip.");
            return;
    }
    
    NSLog(@"Write data: %@", data);
    [self.device write:data];
}

- (id)readDataPoint:(IoTDeviceDataPoint)dataPoint data:(NSDictionary *)data
{
    if(![data isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Error: could not read data, error data format.");
        return nil;
    }
    
    NSNumber *nCommand = [data valueForKey:DATA_CMD];
    if(![nCommand isKindOfClass:[NSNumber class]])
    {
        NSLog(@"Error: could not read cmd, error cmd format.");
        return nil;
    }
    
    int nCmd = [nCommand intValue];
    if(nCmd != IoTDeviceCommandResponse && nCmd != IoTDeviceCommandNotify)
    {
        NSLog(@"Error: command is invalid, skip.");
        return nil;
    }
    
    NSDictionary *attributes = [data valueForKey:DATA_ENTITY];
    if(![attributes isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Error: could not read attributes, error attributes format.");
        return nil;
    }
    
    switch (dataPoint) {
        case IoTDeviceWriteOnOff:
            return [attributes valueForKey:DATA_ATTR_ONOFF];
        case IoTDeviceWriteWeekRepeat:
            return [attributes valueForKey:DATA_ATTR_WEEK_REPEAT];
        case IoTDeviceWriteTimeOn:
            return [attributes valueForKey:DATA_ATTR_ON_MINUTE];
        case IoTDeviceWriteTimeOff:
            return [attributes valueForKey:DATA_ATTR_OFF_MINUTE];
        case IoTDeviceWriteCountDown:
            return [attributes valueForKey:DATA_ATTR_COUNTDOWN_MINUTE];
        case IoTDeviceWriteTimeSwitch:
            return [attributes valueForKey:DATA_ATTR_TIME_ONOFF];
        case IoTDeviceWriteCountDownSwitch:
            return [attributes valueForKey:DATA_ATTR_COUNTDOWN_ONOFF];
        case IoTDeviceReadPowerConsumption:
            return [attributes valueForKey:DATA_ATTR_POWER_CONSUMPTION];
        default:
            NSLog(@"Error: read invalid datapoint, skip.");
            break;
    }
    return nil;
}

- (CGFloat)prepareForUpdateFloat:(NSString *)str value:(CGFloat)value
{
    if([str isKindOfClass:[NSNumber class]] ||
       ([str isKindOfClass:[NSString class]] && str.length > 0))
    {
        CGFloat newValue = [str floatValue];
        if(newValue != value)
        {
            value = newValue;
        }
    }
    return value;
}

- (NSInteger)prepareForUpdateInteger:(NSString *)str value:(NSInteger)value
{
    if([str isKindOfClass:[NSNumber class]] ||
       ([str isKindOfClass:[NSString class]] && str.length > 0))
    {
        NSInteger newValue = [str integerValue];
        if(newValue != value)
        {
            value = newValue;
        }
    }
    return value;
}

#pragma mark - XPGWifiDeviceDelegate
- (void)XPGWifiDeviceDidDisconnected:(XPGWifiDevice *)device
{
    if(![device.did isEqualToString:self.device.did])
        return;
    
    [self onDisconnected];
}

- (BOOL)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result
{
    if(![device.did isEqualToString:self.device.did])
        return YES;
    
    [IoTAppDelegate.hud hide:YES];
    
    /**
     * 数据部分
     */
    NSDictionary *_data = [data valueForKey:@"data"];
    
    if(nil != _data)
    {
        NSString *onOff = [self readDataPoint:IoTDeviceWriteOnOff data:_data];
        NSString *weekRepeat = [self readDataPoint:IoTDeviceWriteWeekRepeat data:_data];
        NSString *timeOn = [self readDataPoint:IoTDeviceWriteTimeOn data:_data];
        NSString *timeOff = [self readDataPoint:IoTDeviceWriteTimeOff data:_data];
        NSString *countDown = [self readDataPoint:IoTDeviceWriteCountDown data:_data];
        NSString *timeSwitch = [self readDataPoint:IoTDeviceWriteTimeSwitch data:_data];
        NSString *countDownSwitch = [self readDataPoint:IoTDeviceWriteCountDownSwitch data:_data];
        NSString *powerConsumption = [self readDataPoint:IoTDeviceReadPowerConsumption data:_data];
        
        bOnOff = [self prepareForUpdateInteger:onOff value:bOnOff];
        iWeekRepeat = [self prepareForUpdateInteger:weekRepeat value:iWeekRepeat];
        NSInteger tmpOn = [self prepareForUpdateInteger:timeOn value:self.timeOn];
        NSInteger tmpOff = [self prepareForUpdateInteger:timeOff value:self.timeOff];
        self.countDownTimer = [self prepareForUpdateInteger:countDown value:self.countDownTimer];
        self.countDownSwitch = [self prepareForUpdateInteger:countDownSwitch value:self.countDownSwitch];
        iPowerConsumption = [self prepareForUpdateInteger:powerConsumption value:iPowerConsumption];
        
        //开启时间不能与关闭时间相等
        if((tmpOn % 1440) != (tmpOff % 1440))
        {
            self.timeOn = tmpOn;
            self.timeOff = tmpOff;
            self.timingSwitch = [self prepareForUpdateInteger:timeSwitch value:self.timingSwitch];
        }
        else
        {
            [self writeDataPoint:IoTDeviceWriteTimeOn value:@(iTimeOn)];
            [self writeDataPoint:IoTDeviceWriteTimeOff value:@(iTimeOff)];
            [self writeDataPoint:IoTDeviceWriteTimeSwitch value:@NO];
            self.timingSwitch = NO;
        }
        
        //强制更新一个属性
        self.repeatIndexes = self.repeatIndexes;
        
        //更新到 UI
        [self updateUI];
        
        //重置读取状态
        self.reloading = NO;
    }
    
    return YES;
}

@end
