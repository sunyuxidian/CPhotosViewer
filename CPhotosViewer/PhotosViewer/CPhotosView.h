//
//  WDSPhotosView.h
//
//  Created by SunYu on 2017/8/22.
//  Copyright © 2017年 COSMOS.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPhotosView : UIView
@property (nonatomic,strong) UICollectionView *collectionView;


/**
 启动

 @param imgs 所有图片数据源，可以是UIImage * 也可以是 NSString *， 不支持其它类型
 @param selectedIndex 点击的图片所在imgs中的索引
 @param selectedImageView 点击的View
 @param visibleViews 所有的可视范围视图
 @param closeBlock 关闭后的回调
 */
+ (void)showWithImgs:(NSArray *)imgs
       selectedIndex:(NSInteger)selectedIndex
   selectedImageView:(nullable UIImageView *)selectedImageView
     allVisibleViews:(nullable NSArray *)visibleViews
          closeBlock:(nullable void (^)(NSInteger currentIndex))closeBlock;

@end

NS_ASSUME_NONNULL_END
