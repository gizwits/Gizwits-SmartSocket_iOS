//
//  IoTDeviceCollectIcon.m
//  SmartSocket-Debug
//
//  Created by GeHaitong on 15/3/16.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "IoTDeviceCollectIcon.h"
#import "IoTPhotoRecorder.h"
#import "IoTDeviceCollectItem.h"

@interface IoTDeviceCollectIcon ()

@property (nonatomic, strong) XPGWifiDevice *device;

@end

@implementation IoTDeviceCollectIcon

static NSString * const reuseIdentifier = @"Cell";

- (id)initWithDevice:(XPGWifiDevice *)device {
    //Item size
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(106, 100/*135*/);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    self = [super initWithCollectionViewLayout:flowLayout];
    if(self)
    {
        self.device = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = @"插座管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack {
    if(self.navigationController.viewControllers.lastObject == self)
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectDefaultItem {
    //选中状态
    NSInteger index = [IoTPhotoRecorder photoIndex:self.device];
    NSInteger row = index/3;
    NSInteger section = index%3;
    
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [IoTPhotoRecorder resources].count;
    
    [self performSelector:@selector(selectDefaultItem) withObject:nil afterDelay:0.1];
    
    return (count / 3) + ((count % 3) > 0 ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //初始化两种状态的 view
    if(![cell.backgroundView isMemberOfClass:[IoTDeviceCollectItem class]])
    {
        cell.backgroundView = [[IoTDeviceCollectItem alloc] initWithIndexPath:indexPath isSelectec:NO];
        cell.selectedBackgroundView = [[IoTDeviceCollectItem alloc] initWithIndexPath:indexPath isSelectec:YES];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //防止在拖动的时候选中
    if(self.collectionView.isDragging || self.collectionView.isDecelerating)
        return;
    
    //如果超出范围
    NSInteger maximizeCount = [IoTPhotoRecorder resources].count;
    if(indexPath.row*3 + indexPath.section >= maximizeCount)
    {
        [self selectDefaultItem];
        return;
    }

    [IoTPhotoRecorder setDevicePhoto:self.device photoIndex:indexPath.row*3 + indexPath.section];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
