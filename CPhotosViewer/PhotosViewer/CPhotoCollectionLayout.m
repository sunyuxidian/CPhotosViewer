//
//  WDSPhotoCollectionLayout.m
//
//  Created by SunYu on 2017/8/31.
//  Copyright © 2017年 COSMOS.Inc. All rights reserved.
//

#import "CPhotoCollectionLayout.h"

@interface CPhotoCollectionLayout()

@property (nonatomic,strong) NSMutableArray <UICollectionViewLayoutAttributes*>*attributesArray;

@end

@implementation CPhotoCollectionLayout

- (NSMutableArray <UICollectionViewLayoutAttributes*>*)attributesArray
{
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

- (void)prepareLayout {
    [super prepareLayout];

    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = CGSizeMake(self.collectionView.frame.size.width + self.itemPadding,
                               self.collectionView.frame.size.height);

    NSInteger itemTotalCount = [self.collectionView numberOfItemsInSection:0];

    for (int i = 0; i < itemTotalCount; i++)
    {
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexpath];
        [self.attributesArray addObject:attributes];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = self.collectionView.frame.size.width - self.itemPadding;
    CGFloat itemHeight = self.collectionView.frame.size.height;
    
    NSInteger pageNumber = indexPath.item;
    NSInteger x = pageNumber * self.itemPadding + pageNumber * itemWidth + self.itemPadding * 0.5;
    NSInteger y = 0;
    
    UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    attributes.frame = CGRectMake(x, y, itemWidth, itemHeight);

    return attributes;
}

- (CGSize)collectionViewContentSize
{
    CGFloat itemWidth = self.collectionView.frame.size.width - self.itemPadding;
    NSInteger itemTotalCount = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(itemTotalCount * itemWidth + self.itemPadding * itemTotalCount, self.collectionView.bounds.size.height);
}
@end
