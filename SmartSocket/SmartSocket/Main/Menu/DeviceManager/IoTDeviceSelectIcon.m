/**
 * IoTDeviceSelectIcon.m
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

#import "IoTDeviceSelectIcon.h"
#import "IoTDeviceSelectionCell.h"
#import "IoTPhotoRecorder.h"

@interface IoTDeviceSelectIcon () <UITableViewDataSource, UITableViewDelegate, IoTDeviceSelectionCellDelegate>

@property (nonatomic, assign) XPGWifiDevice *device;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IoTDeviceSelectIcon

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
    self.navigationItem.title = @"插座管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onConfirm)];
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

#pragma mark - Actions
- (void)onBack {
    if(self.navigationController.viewControllers.lastObject == self)
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)onConfirm {
    
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [IoTPhotoRecorder resources].count;
    return (count / 3) + ((count % 3) > 0 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifier = @"selectIconCell";
    IoTDeviceSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(nil == cell)
    {
        UINib *nib = [UINib nibWithNibName:@"IoTDeviceSelectionCell" bundle:nil];
        if(nib)
        {
            [tableView registerNib:nib forCellReuseIdentifier:strIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
        }
    }
    
    //计算范围
    NSArray *resources = [IoTPhotoRecorder resources];
    NSInteger start = indexPath.row * 3;
    NSInteger count = resources.count - start;
    if(count > 3)
        count = 3;
    
    //给cell设置值
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, count)];
    cell.datas = [resources objectsAtIndexes:indexSet];
    
    //索引：将实际索引变成相对索引
    NSInteger index = [IoTPhotoRecorder photoIndex:self.device];
    cell.selectedIndex = (index - start);
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)IoTDeviceSelectionCell:(IoTDeviceSelectionCell *)cell didSelectedIndex:(NSInteger)index
{
    //防止在拖动的时候选中
    if(self.tableView.isDragging || self.tableView.isDecelerating)
        return;
    
    NSInteger section = 0;
    for(int i=0; i < [self tableView:self.tableView numberOfRowsInSection:section]; i++)
    {
        if(cell.tag == i)
        {
            //选中部分
            IoTDeviceSelectionCell *cell = (IoTDeviceSelectionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
            [IoTPhotoRecorder setDevicePhoto:self.device photoIndex:cell.tag * 3 + cell.selectedIndex];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            //未选中部分
            IoTDeviceSelectionCell *cell = (IoTDeviceSelectionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
            cell.selectedIndex = -1;
        }
    }
}

@end
