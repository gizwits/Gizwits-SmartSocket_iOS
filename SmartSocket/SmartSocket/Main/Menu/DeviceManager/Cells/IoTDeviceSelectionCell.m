/**
 * IoTDeviceSelectionCell.m
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

#import "IoTDeviceSelectionCell.h"

@interface IoTDeviceSelectionCell()

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UILabel *text1;

@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UILabel *text2;

@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UILabel *text3;

@end

@implementation IoTDeviceSelectionCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedIndex = -1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - events
- (IBAction)onBtn1:(id)sender {
    self.selectedIndex = 0;
}

- (IBAction)onBtn2:(id)sender {
    self.selectedIndex = 1;
}

- (IBAction)onBtn3:(id)sender {
    self.selectedIndex = 2;
}

#pragma mark - Properties
- (void)setGroupProperties:(NSDictionary *)dict group:(NSInteger)index
{
    NSArray *groups = @[@[self.button1, self.text1],
                        @[self.button2, self.text2],
                        @[self.button3, self.text3]];
    NSArray *group = groups[index];
    UIButton *button = group[0];
    UILabel *text = group[1];
    
    //设置属性
    text.text = [dict valueForKey:@"name"];
    
    button.layer.masksToBounds =YES;
    button.layer.cornerRadius = 10;
    
    [button setImage:[dict valueForKey:@"table"] forState:UIControlStateNormal];
    [button setImage:[dict valueForKey:@"table-H"] forState:UIControlStateSelected];
}

- (void)updateGroups
{
    //清理数据
    for(NSInteger i=0; i<3; i++)
    {
        [self setGroupProperties:@{} group:i];
    }
    
    //设置新数据
    NSInteger count = _datas.count;
    if(count > 3)
        count = 3;
    
    for(NSInteger i=0; i<count; i++)
    {
        NSDictionary *dict = _datas[i];
        [self setGroupProperties:dict group:i];
    }
}

- (void)setDatas:(NSArray *)datas
{
    _datas = datas;
    
    [self updateGroups];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    if(selectedIndex >= 0 && selectedIndex < 3)
    {
        //更新 UI 数据
        NSArray *buttons = @[self.button1,
                            self.button2,
                            self.button3];
        
        for(UIButton *btn in buttons)
        {
            NSInteger index = [buttons indexOfObject:btn];
            BOOL isSelected = index == selectedIndex;
            
            btn.selected = isSelected;
            btn.backgroundColor = isSelected?[UIColor colorWithRed:0.0390625 green:0.57421875 blue:0.8046875 alpha:1]:[UIColor whiteColor];
        }
        
        //回调出去
        if([_delegate respondsToSelector:@selector(IoTDeviceSelectionCell:didSelectedIndex:)])
            [_delegate IoTDeviceSelectionCell:self didSelectedIndex:0];
    }
    else
    {
        NSArray *buttons = @[self.button1,
                             self.button2,
                             self.button3];
        for(UIButton *btn in buttons)
        {
            btn.selected = NO;
            btn.backgroundColor = [UIColor whiteColor];
        }
        
        _selectedIndex = -1;
    }
}

@end
