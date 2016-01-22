/**
 * IoTInputView.m
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

#import "IoTInputView.h"

@interface IoTInputView () <UITextFieldDelegate>
{
    IoTInputView *inputCtrl;
}

@property (weak, nonatomic) IBOutlet UILabel *textTitle;
@property (weak, nonatomic) IBOutlet UITextField *textContent;

@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (nonatomic, assign) id <IoTInputViewDelegate>delegate;

@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic, strong) NSString *strContent;
@property (nonatomic, strong) NSString *strDefCtx;
@property (nonatomic, strong) NSString *strTitleOK;
@property (nonatomic, strong) NSString *strTitleCancel;

@end

@implementation IoTInputView

- (id)initWithTitle:(NSString *)title content:(NSString *)content defaultCtx:(NSString *)defaultCtx delegate:(id <IoTInputViewDelegate>)delegate titleOK:(NSString *)titleOK titleCancel:(NSString *)titleCancel
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
        self.strTitle = title;
        self.strContent = content;
        self.strDefCtx = defaultCtx;
        self.strTitleOK = titleOK;
        self.strTitleCancel = titleCancel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textTitle.text = self.strTitle;
    self.textContent.text = self.strContent;
    self.textContent.placeholder = self.strDefCtx;
    
    if(self.strTitleOK.length > 0)
        [self.btnConfirm setTitle:self.strTitleOK forState:UIControlStateNormal];
    if(self.strTitleCancel.length > 0)
        [self.btnCancel setTitle:self.strTitleCancel forState:UIControlStateNormal];
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
- (void)onCallback:(BOOL)isConfirm {
    [self hide:YES];
    if([self.delegate respondsToSelector:@selector(IoTInputViewDidDismissButton:withText:)])
        [self.delegate IoTInputViewDidDismissButton:self withText:isConfirm?self.textContent.text:nil];
}

- (IBAction)onConfirm:(id)sender {
    [self onCallback:YES];
}

- (IBAction)onCancel:(id)sender {
    [self onCallback:NO];
}

- (void)show:(BOOL)animated
{
    inputCtrl = self;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:animated];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [UIView commitAnimations];
    
    self.view.frame = [UIApplication sharedApplication].keyWindow.frame;
}

- (void)hide:(BOOL)animated
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:animated];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.view removeFromSuperview];
    [UIView commitAnimations];
    
    inputCtrl = nil;
}

#pragma mark - delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    CGRect frame = self.view.frame;
    frame.origin.y = -60;
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onConfirm:nil];
    return YES;
}

@end
