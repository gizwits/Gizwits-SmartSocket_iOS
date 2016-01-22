/**
 * IoTMainController.h
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

typedef enum
{
    // writable
    IoTDeviceWriteUpdateData = 0,   //更新数据
    IoTDeviceWriteOnOff,            //开关
    IoTDeviceWriteWeekRepeat,       //每周重复
    IoTDeviceWriteTimeOn,           //定时开启
    IoTDeviceWriteTimeOff,          //定时关闭
    IoTDeviceWriteCountDown,        //延时预约
    
    IoTDeviceWriteTimeSwitch,       //定时开关
    IoTDeviceWriteCountDownSwitch,  //预约开关
    
    // readonly
    IoTDeviceReadPowerConsumption, //电池消耗
}IoTDeviceDataPoint;

typedef enum
{
    IoTDeviceCommandWrite    = 1,//写
    IoTDeviceCommandRead     = 2,//读
    IoTDeviceCommandResponse = 3,//读响应
    IoTDeviceCommandNotify   = 4,//通知
}IoTDeviceCommand;

#define DATA_CMD                    @"cmd"              //命令
#define DATA_ENTITY                 @"entity0"          //实体
#define DATA_ATTR_ONOFF             @"OnOff"            //属性：开关
#define DATA_ATTR_TIME_ONOFF        @"Time_OnOff"       //属性：定时预约开关
#define DATA_ATTR_COUNTDOWN_ONOFF   @"CountDown_OnOff"  //属性：延时预约开关
#define DATA_ATTR_WEEK_REPEAT       @"Week_Repeat"      //属性：每周重复
#define DATA_ATTR_ON_MINUTE         @"Time_On_Minute"   //属性：定时开启
#define DATA_ATTR_OFF_MINUTE        @"Time_Off_Minute"  //属性：定时关闭
#define DATA_ATTR_COUNTDOWN_MINUTE  @"CountDown_Minute" //属性：延时预约
#define DATA_ATTR_POWER_CONSUMPTION @"Power_Consumption"//属性：电池消耗

//每周重复星期对应值
#define WEAK_REPEAT_MONDAY          0x01
#define WEAK_REPEAT_TUESDAY         0x02
#define WEAK_REPEAT_WEDNESDAY       0x04
#define WEAK_REPEAT_THURSDAY        0x08
#define WEAK_REPEAT_FRIDAY          0x10
#define WEAK_REPEAT_SATURDAY        0x20
#define WEAK_REPEAT_SUNDAY          0x40

@interface IoTMainController : UIViewController <XPGWifiDeviceDelegate>

- (id)initWithDevice:(XPGWifiDevice *)device;

//用于切换设备
@property (nonatomic, strong) XPGWifiDevice *device;

//数据点值传递使用
@property (nonatomic, assign) NSInteger timeOn;
@property (nonatomic, assign) NSInteger timeOff;
@property (nonatomic, assign) NSInteger countDownTimer;

@property (nonatomic, assign) BOOL timingSwitch;
@property (nonatomic, assign) BOOL countDownSwitch;

@property (nonatomic, assign) NSArray *repeatIndexes;

- (void)setRepeatIndexes:(NSArray *)repeatIndexes withDataPoint:(BOOL)isDataPoint;

//写入数据接口
- (void)writeDataPoint:(IoTDeviceDataPoint)dataPoint value:(id)value;

- (void)onReload;

//当前已经创建的实例
+ (instancetype)currentController;

@end
