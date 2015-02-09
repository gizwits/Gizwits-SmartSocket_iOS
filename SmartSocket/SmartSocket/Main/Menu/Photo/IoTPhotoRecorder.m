/**
 * IoTPhotoRecorder.m
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

#import "IoTPhotoRecorder.h"

NSArray *tmpResources = nil;

@implementation IoTPhotoRecorder

+ (NSArray *)resources
{
    if(tmpResources == nil)
    {
        //生成 Resource
        NSMutableArray *marray = [NSMutableArray array];
        NSArray *names = @[@"电视", @"插座", @"空调",
                           @"冰箱", @"洗衣机", @"DVD",
                           @"音响", @"厨具", @"风扇"];
        NSInteger index = 0;
        for(NSString *name in names)
        {
            index++;
            
            NSString *strListImage = [NSString stringWithFormat:@"list_icon%@", @(index)];
            NSString *strImage = [NSString stringWithFormat:@"head_icon%@", @(index)];
            NSString *strImageH = [NSString stringWithFormat:@"head_icon%@_down", @(index)];
            UIImage *listImage = [UIImage imageNamed:strListImage];
            UIImage *tableImage = [UIImage imageNamed:strImage];
            UIImage *tableImageH = [UIImage imageNamed:strImageH];
            
            if(listImage && tableImage && tableImageH)
            {
                [marray addObject:@{@"name": name,
                                    @"list": listImage,
                                    @"table": tableImage,
                                    @"table-H": tableImageH}];
            }
            else
            {
                abort();
            }
        }
        
        tmpResources = [NSArray arrayWithArray:marray];
    }
    
    return tmpResources;
}

+ (NSString *)deviceId:(XPGWifiDevice *)device
{
    return [NSString stringWithFormat:@"mac:%@ did:%@", device.macAddress, device.did];
}

+ (NSInteger)photoIndex:(XPGWifiDevice *)device
{
    //默认值
    if(nil == device)
        return 1;
    
    NSDictionary *photos = [[NSUserDefaults standardUserDefaults] valueForKey:@"photos"];
    NSString *devId = [self deviceId:device];
    NSNumber *index = [photos valueForKey:devId];
    
    //默认值
    if(nil == index)
        return 1;
    
    return [index integerValue];
}

+ (void)setDevicePhoto:(XPGWifiDevice *)device photoIndex:(NSInteger)index
{
    if(nil != device && index >= 0 && index < [self resources].count)
    {
        NSMutableDictionary *photos = [[NSUserDefaults standardUserDefaults] valueForKey:@"photos"];
        NSString *devId = [self deviceId:device];
        if(nil == photos)
            photos = [NSMutableDictionary dictionary];
        else
            photos = [NSMutableDictionary dictionaryWithDictionary:photos];
        
        [photos setValue:@(index) forKey:devId];
        [[NSUserDefaults standardUserDefaults] setValue:photos forKey:@"photos"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"Warning: [IoTPhotoRecoder setDevicePhoto:photoIndex] invalid parameters.");
    }
}

@end
