/**
 * IoTInputView.h
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

#import <UIKit/UIKit.h>

@class IoTInputView;

@protocol IoTInputViewDelegate <NSObject>

- (void)IoTInputViewDidDismissButton:(IoTInputView *)inputView withText:(NSString *)text;

@end

@interface IoTInputView : UIViewController

/**
 * @param title         标题
 * @param content       输入框的值
 * @param defaultCtx    输入框的提示
 * @param delegate      回调
 * @param titleOK       确定按钮的文字，nil则为“确定”
 * @param titleCancel   取消按钮的文字，nil则为“取消”
 */
- (id)initWithTitle:(NSString *)title content:(NSString *)content defaultCtx:(NSString *)defaultCtx delegate:(id <IoTInputViewDelegate>)delegate titleOK:(NSString *)titleOK titleCancel:(NSString *)titleCancel;

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
