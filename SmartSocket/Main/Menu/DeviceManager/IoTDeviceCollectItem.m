//
//  IoTDeviceCollectItem.m
//  SmartSocket-Debug
//
//  Created by GeHaitong on 15/3/16.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "IoTDeviceCollectItem.h"
#import "IoTPhotoRecorder.h"

@interface IoTDeviceCollectItem()

@end

@implementation IoTDeviceCollectItem

- (id)initWithIndexPath:(NSIndexPath *)indexPath isSelectec:(BOOL)isSelected
{
    NSString *nibName = [NSString stringWithUTF8String:object_getClassName(self)];
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    self = [nib instantiateWithOwner:nil options:nil][0];
    if(self)
    {
        //超出范围
        NSInteger maximizeCount = [IoTPhotoRecorder resources].count;
        if(indexPath.row*3+indexPath.section >= maximizeCount)
        {
            return nil;
        }
        
        UIImageView *imageView = (UIImageView *)[self viewWithTag:1];
        UILabel *labelView = (UILabel *)[self viewWithTag:2];
        NSArray *resources = [IoTPhotoRecorder resources];
        NSDictionary *dict = resources[indexPath.row*3 + indexPath.section];
        NSString *strImageKey = isSelected?@"table-H":@"table";
        
        imageView.layer.masksToBounds =YES;
        imageView.layer.cornerRadius = 10;
        
        labelView.text = [dict valueForKey:@"name"];
        imageView.image = dict[strImageKey];
        
        if(isSelected)
            imageView.backgroundColor = [UIColor colorWithRed:0.0390625 green:0.57421875 blue:0.8046875 alpha:1];
    }
    return self;
}

@end
