/**
 * IoTSubscribe.m
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

#import "IoTSubscribe.h"
#import "IoTTimingSubscribe.h"
#import "IoTMainController.h"
#import "IoTTimingSelection.h"

@interface IoTSubscribe () <UITableViewDataSource, UITableViewDelegate, IoTTimingSelectionDelegate>
{
    NSArray *items;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IoTMainController *mainCtrl;

@end

@implementation IoTSubscribe

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"预约";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];

    items = @[@"定时预约", @"延时预约"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    //Key value observer
    self.mainCtrl = [IoTMainController currentController];
    [self.mainCtrl addObserver:self forKeyPath:@"countDownTimer" options:NSKeyValueObservingOptionNew context:nil];
    [self.mainCtrl addObserver:self forKeyPath:@"timingSwitch" options:NSKeyValueObservingOptionNew context:nil];
    [self.mainCtrl addObserver:self forKeyPath:@"countDownSwitch" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Cleanup KVO
    [self.mainCtrl removeObserver:self forKeyPath:@"countDownTimer"];
    [self.mainCtrl removeObserver:self forKeyPath:@"timingSwitch"];
    [self.mainCtrl removeObserver:self forKeyPath:@"countDownSwitch"];
    
    self.mainCtrl = nil;
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
- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSwitch:(UISwitch *)sender
{
    IoTAppDelegate.hud.labelText = @"请稍候...";
    [IoTAppDelegate.hud show:YES];
    
    switch (sender.tag) {
        case 0:
            //定时预约开启、关闭
            [self.mainCtrl writeDataPoint:IoTDeviceWriteTimeSwitch value:@(sender.on)];
            break;
        case 1:
            //延时预约开启、关闭
            [self.mainCtrl writeDataPoint:IoTDeviceWriteCountDownSwitch value:@(sender.on)];
            break;
        default:
            break;
    }
    
    [self.mainCtrl onReload];
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifier = @"subscribeIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
        
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text = items[indexPath.row];
    
    //文本
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 80)];
    UILabel *_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 80)];
    
    _label.textAlignment = NSTextAlignmentRight;
    _label.textColor = [UIColor orangeColor];
    [view addSubview:_label];
    
    //开关按钮，设置对应的回调
    UISwitch *_switch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 25, 0, 80)];
    _switch.tag = indexPath.row;
    [_switch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:_switch];
    cell.accessoryView = view;
    
    switch (indexPath.row) {
        //定时预约
        case 0:
        {
            NSInteger timeOn = self.mainCtrl.timeOn;
            NSInteger timeOff = self.mainCtrl.timeOff;
            _label.text = [NSString stringWithFormat:@"%02i:%02i 至 %02i:%02i",
                           GetHourFromMinutes(timeOn),
                           GetMinuteFromMinutes(timeOn),
                           GetHourFromMinutes(timeOff),
                           GetMinuteFromMinutes(timeOff)];
            
            _switch.on = self.mainCtrl.timingSwitch;
            
            break;
        }
        //延时预约
        case 1:
        {
            NSInteger countDownTimer = self.mainCtrl.countDownTimer;
            _label.text = [NSString stringWithFormat:@"%02i:%02i",
                           GetHourFromMinutes(countDownTimer),
                           GetMinuteFromMinutes(countDownTimer)];
            
            _switch.on = self.mainCtrl.countDownSwitch;
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //跳转页面或设置详细信息
    switch (indexPath.row) {
        case 0:
        {
            //定时预约
            IoTTimingSubscribe *timingSubscribeCtrl = [[IoTTimingSubscribe alloc] init];
            [self.navigationController pushViewController:timingSubscribeCtrl animated:YES];
            break;
        }
        case 1:
        {
            //延时预约
            NSInteger countDownTimer = self.mainCtrl.countDownTimer;
            [[[IoTTimingSelection alloc] initWithTitle:@"延时预约" delegate:self currentValue:countDownTimer] show:YES];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Other delegates
- (void)IoTTimingSelectionDidConfirm:(IoTTimingSelection *)selection withValue:(NSInteger)value
{
    IoTAppDelegate.hud.labelText = @"请稍候...";
    [IoTAppDelegate.hud showAnimated:YES whileExecutingBlock:^{
        sleep(61);
    }];

    [self.mainCtrl writeDataPoint:IoTDeviceWriteCountDown value:@(value)];
    [self.mainCtrl writeDataPoint:IoTDeviceWriteUpdateData value:nil];
}

#pragma mark - Update datas
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}

@end
