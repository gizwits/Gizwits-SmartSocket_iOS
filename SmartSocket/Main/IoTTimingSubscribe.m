/**
 * IoTTimingSubscribe.m
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

#import "IoTTimingSubscribe.h"
#import "IoTTimingSubscribeCell.h"
#import "IoTMainController.h"
#import "IoTTimingSelection.h"

@interface IoTTimingSubscribe () <UITableViewDataSource, UITableViewDelegate, IoTTimingSubscribeCellDelegate, IoTTimingSelectionDelegate>
{
    NSArray *items;
    IoTTimingSelection *onTimingSelectionCtrl;
    IoTTimingSelection *offTimingSelectionCtrl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IoTMainController *mainCtrl;

@end

@implementation IoTTimingSubscribe

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"定时预约";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    items = @[@"开启时间", @"关闭时间", @"重复"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Key value observer
    self.mainCtrl = [IoTMainController currentController];
    [self.mainCtrl addObserver:self forKeyPath:@"timeOn" options:NSKeyValueObservingOptionNew context:nil];
    [self.mainCtrl addObserver:self forKeyPath:@"timeOff" options:NSKeyValueObservingOptionNew context:nil];
    [self.mainCtrl addObserver:self forKeyPath:@"repeatIndexes" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Cleanup KVO
    [self.mainCtrl removeObserver:self forKeyPath:@"timeOn"];
    [self.mainCtrl removeObserver:self forKeyPath:@"timeOff"];
    [self.mainCtrl removeObserver:self forKeyPath:@"repeatIndexes"];
    self.mainCtrl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action
- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    static NSString *strIdentifier = @"timingSubscribeIdentifier";
    
    UITableViewCell *cell = nil;
    if(indexPath.row == 2)
    {
        static NSString *strIdentifier = @"timingSubscribeCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
        if(nil == cell)
        {
            UINib *nib = [UINib nibWithNibName:@"IoTTimingSubscribeCell" bundle:nil];
            if(nib)
            {
                [tableView registerNib:nib forCellReuseIdentifier:strIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
            }
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
        }
    }
    
    if(indexPath.row < 2)
    {
        cell.textLabel.text = items[indexPath.row];
        
        //加标签
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 80)];
        switch (indexPath.row) {
            //开启时间
            case 0:
            {
                NSInteger timeOn = self.mainCtrl.timeOn;
                label.text = [NSString stringWithFormat:@"%02i:%02i",
                              GetHourFromMinutes(timeOn),
                              GetMinuteFromMinutes(timeOn)];
                break;
            }
            //关闭时间
            case 1:
            {
                NSInteger timeOff = self.mainCtrl.timeOff;
                label.text = [NSString stringWithFormat:@"%02i:%02i",
                              GetHourFromMinutes(timeOff),
                              GetMinuteFromMinutes(timeOff)];
                break;
            }
            default:
                break;
        }
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor orangeColor];
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(130, 32, 9, 15)];
        accessoryView.image = [UIImage imageNamed:@"accessory.png"];
        
        [view addSubview:label];
        [view addSubview:accessoryView];
        
        cell.accessoryView = view;
    }
    else
    {
        IoTTimingSubscribeCell *subscribeCell = (IoTTimingSubscribeCell *)cell;
        subscribeCell.delegate = self;
        subscribeCell.indexes = self.mainCtrl.repeatIndexes;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            //开启时间
            NSInteger timeOn = self.mainCtrl.timeOn;
            onTimingSelectionCtrl = [[IoTTimingSelection alloc] initWithTitle:@"开启时间" delegate:self currentValue:timeOn];
            [onTimingSelectionCtrl show:YES];
            break;
        }
        case 1:
        {
            //关闭时间
            NSInteger timeOff = self.mainCtrl.timeOff;
            offTimingSelectionCtrl = [[IoTTimingSelection alloc] initWithTitle:@"关闭时间" delegate:self currentValue:timeOff];
            [offTimingSelectionCtrl show:YES];
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
- (void)IoTTimingSubscribeCell:(IoTTimingSubscribeCell *)cell indexes:(NSArray *)indexes
{
    IoTAppDelegate.hud.labelText = @"请稍候...";
    [IoTAppDelegate.hud show:YES];

    [[IoTMainController currentController] setRepeatIndexes:indexes withDataPoint:YES];
    [self.mainCtrl onReload];
}

- (void)IoTTimingSelectionDidConfirm:(IoTTimingSelection *)selection withValue:(NSInteger)value
{
    if(selection == onTimingSelectionCtrl)
    {
        onTimingSelectionCtrl = nil;
        
        //设置开启时间，与开启时间必须不相等
        if(value != self.mainCtrl.timeOff)
        {
            IoTAppDelegate.hud.labelText = @"请稍候...";
            [IoTAppDelegate.hud showAnimated:YES whileExecutingBlock:^{
                sleep(61);
            }];
            
            [[IoTMainController currentController] writeDataPoint:IoTDeviceWriteTimeOn value:@(value)];
            [self.mainCtrl onReload];
        }
        else
        {
            [[[IoTAlertView alloc] initWithMessage:@"开启时间不能与关闭时间相同" delegate:nil titleOK:@"确定"] show:YES];
        }
    }
    
    if(selection == offTimingSelectionCtrl)
    {
        offTimingSelectionCtrl = nil;
        
        //设置关闭时间，与开启时间必须不相等
        if(value != self.mainCtrl.timeOn)
        {
            IoTAppDelegate.hud.labelText = @"请稍候...";
            [IoTAppDelegate.hud showAnimated:YES whileExecutingBlock:^{
                sleep(61);
            }];
            
            [[IoTMainController currentController] writeDataPoint:IoTDeviceWriteTimeOff value:@(value)];
            [self.mainCtrl onReload];
        }
        else
        {
            [[[IoTAlertView alloc] initWithMessage:@"开启时间不能与关闭时间相同" delegate:nil titleOK:@"确定"] show:YES];
        }
    }
}

#pragma mark - Update datas
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}

@end
