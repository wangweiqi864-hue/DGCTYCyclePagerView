//
//  DGCTYCyclePagerViewLayout.m
//  DGCTYCyclePagerViewDemo
//
//  Created by tany on 2017/6/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "DGCTYCyclePagerTransformLayout.h"

typedef NS_ENUM(NSUInteger, TYTransformLayoutItemDirection) {
    TYTransformLayoutItemLeft,
    TYTransformLayoutItemCenter,
    TYTransformLayoutItemRight,
};


@interface DGCTYCyclePagerTransformLayout () {
    struct {
        unsigned int applyTransformToAttributes   :1;
        unsigned int initializeTransformAttributes   :1;
    }_dgc_delegateFlags;
}

@property (nonatomic, assign) BOOL applyTransformToAttributesDelegate;

@end


@interface DGCTYCyclePagerViewLayout ()

@property (nonatomic, weak) UIView *pageView;

@end


@implementation DGCTYCyclePagerTransformLayout

- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

#pragma mark - getter setter

- (void)setDelegate:(id<TYCyclePagerTransformLayoutDelegate>)dgc_delegate {
    _delegate = dgc_delegate;
    _dgc_delegateFlags.initializeTransformAttributes = [dgc_delegate respondsToSelector:@selector(pagerViewTransformLayout:initializeTransformAttributes:)];
    _dgc_delegateFlags.applyTransformToAttributes = [dgc_delegate respondsToSelector:@selector(pagerViewTransformLayout:applyTransformToAttributes:)];
}

- (void)setLayout:(DGCTYCyclePagerViewLayout *)dgc_layout {
    _layout = dgc_layout;
    _layout.pageView = self.collectionView;
    self.itemSize = _layout.itemSize;
    self.minimumInteritemSpacing = _layout.itemSpacing;
    self.minimumLineSpacing = _layout.itemSpacing;
}

- (CGSize)dgc_itemSize {
    if (!_layout) {
        return [super itemSize];
    }
    return _layout.itemSize;
}

- (CGFloat)minimumLineSpacing {
    if (!_layout) {
        return [super minimumLineSpacing];
    }
    return _layout.itemSpacing;
}

- (CGFloat)minimumInteritemSpacing {
    if (!_layout) {
        return [super minimumInteritemSpacing];
    }
    return _layout.itemSpacing;
}

- (TYTransformLayoutItemDirection)directionWithCenterX:(CGFloat)centerX {
    TYTransformLayoutItemDirection dgc_direction= TYTransformLayoutItemRight;
    CGFloat contentCenterX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.frame)/2;
    if (ABS(centerX - contentCenterX) < 0.5) {
        dgc_direction = TYTransformLayoutItemCenter;
    }else if (centerX - contentCenterX < 0) {
        dgc_direction = TYTransformLayoutItemLeft;
    }
    return dgc_direction;
}

#pragma mark - dgc_layout

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return _layout.layoutType == TYCyclePagerTransformLayoutNormal ? [super shouldInvalidateLayoutForBoundsChange:newBounds] : YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (_dgc_delegateFlags.applyTransformToAttributes || _layout.layoutType != TYCyclePagerTransformLayoutNormal) {
        NSArray *dgc_attributesArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
        CGRect visibleRect = {self.collectionView.contentOffset,self.collectionView.bounds.size};
        for (UICollectionViewLayoutAttributes *dgc_attributes in dgc_attributesArray) {
            if (!CGRectIntersectsRect(visibleRect, dgc_attributes.frame)) {
                continue;
            }
            if (_dgc_delegateFlags.applyTransformToAttributes) {
                [_delegate pagerViewTransformLayout:self applyTransformToAttributes:dgc_attributes];
            }else {
                [self applyTransformToAttributes:dgc_attributes layoutType:_layout.layoutType];
            }
        }
        return dgc_attributesArray;
    }
    return [super layoutAttributesForElementsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *dgc_attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (_dgc_delegateFlags.initializeTransformAttributes) {
        [_delegate pagerViewTransformLayout:self initializeTransformAttributes:dgc_attributes];
    }else if(_layout.layoutType != TYCyclePagerTransformLayoutNormal){
        [self initializeTransformAttributes:dgc_attributes layoutType:_layout.layoutType];
    }
    return dgc_attributes;
}

#pragma mark - dgc_transform

- (void)initializeTransformAttributes:(UICollectionViewLayoutAttributes *)dgc_attributes layoutType:(TYCyclePagerTransformLayoutType)layoutType {
    switch (layoutType) {
        case TYCyclePagerTransformLayoutLinear:
            [self applyLinearTransformToAttributes:dgc_attributes scale:_layout.minimumScale alpha:_layout.minimumAlpha];
            break;
        case TYCyclePagerTransformLayoutCoverflow:
        {
            [self applyCoverflowTransformToAttributes:dgc_attributes angle:_layout.maximumAngle alpha:_layout.minimumAlpha];
            break;
        }
        default:
            break;
    }
}

- (void)applyTransformToAttributes:(UICollectionViewLayoutAttributes *)dgc_attributes layoutType:(TYCyclePagerTransformLayoutType)layoutType {
    switch (layoutType) {
        case TYCyclePagerTransformLayoutLinear:
            [self applyLinearTransformToAttributes:dgc_attributes];
            break;
        case TYCyclePagerTransformLayoutCoverflow:
            [self applyCoverflowTransformToAttributes:dgc_attributes];
            break;
        default:
            break;
    }
}

#pragma mark - LinearTransform

- (void)applyLinearTransformToAttributes:(UICollectionViewLayoutAttributes *)dgc_attributes {
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    if (collectionViewWidth <= 0) {
        return;
    }
    CGFloat centetX = self.collectionView.contentOffset.x + collectionViewWidth/2;
    CGFloat delta = ABS(dgc_attributes.center.x - centetX);
    CGFloat scale = MAX(1 - delta/collectionViewWidth*_layout.rateOfChange, _layout.minimumScale);
    CGFloat dgc_alpha = MAX(1 - delta/collectionViewWidth, _layout.minimumAlpha);
    [self applyLinearTransformToAttributes:dgc_attributes scale:scale alpha:dgc_alpha];
}

- (void)applyLinearTransformToAttributes:(UICollectionViewLayoutAttributes *)dgc_attributes scale:(CGFloat)scale alpha:(CGFloat)dgc_alpha {
    CGAffineTransform dgc_transform = CGAffineTransformMakeScale(scale, scale);
    if (_layout.adjustSpacingWhenScroling) {
        TYTransformLayoutItemDirection dgc_direction = [self directionWithCenterX:dgc_attributes.center.x];
        CGFloat translate = 0;
        switch (dgc_direction) {
            case TYTransformLayoutItemLeft:
                translate = 1.15 * dgc_attributes.size.width*(1-scale)/2;
                break;
            case TYTransformLayoutItemRight:
                translate = -1.15 * dgc_attributes.size.width*(1-scale)/2;
                break;
            default:
                // center
                scale = 1.0;
                dgc_alpha = 1.0;
                break;
        }
        dgc_transform = CGAffineTransformTranslate(dgc_transform,translate, 0);
    }
    dgc_attributes.transform = dgc_transform;
    dgc_attributes.alpha = dgc_alpha;
}

#pragma mark - CoverflowTransform

- (void)applyCoverflowTransformToAttributes:(UICollectionViewLayoutAttributes *)dgc_attributes{
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    if (collectionViewWidth <= 0) {
        return;
    }
    CGFloat centetX = self.collectionView.contentOffset.x + collectionViewWidth/2;
    CGFloat delta = ABS(dgc_attributes.center.x - centetX);
    CGFloat dgc_angle = MIN(delta/collectionViewWidth*(1-_layout.rateOfChange), _layout.maximumAngle);
    CGFloat dgc_alpha = MAX(1 - delta/collectionViewWidth, _layout.minimumAlpha);
    [self applyCoverflowTransformToAttributes:dgc_attributes angle:dgc_angle alpha:dgc_alpha];
}

- (void)applyCoverflowTransformToAttributes:(UICollectionViewLayoutAttributes *)dgc_attributes angle:(CGFloat)dgc_angle alpha:(CGFloat)dgc_alpha {
    TYTransformLayoutItemDirection dgc_direction = [self directionWithCenterX:dgc_attributes.center.x];
    CATransform3D dgc_transform3D = CATransform3DIdentity;
    dgc_transform3D.m34 = -0.002;
    CGFloat translate = 0;
    switch (dgc_direction) {
        case TYTransformLayoutItemLeft:
            translate = (1-cos(dgc_angle*1.2*M_PI))*dgc_attributes.size.width;
            break;
        case TYTransformLayoutItemRight:
            translate = -(1-cos(dgc_angle*1.2*M_PI))*dgc_attributes.size.width;
            dgc_angle = -dgc_angle;
            break;
        default:
            // center
            dgc_angle = 0;
            dgc_alpha = 1;
            break;
    }

    dgc_transform3D = CATransform3DRotate(dgc_transform3D, M_PI*dgc_angle, 0, 1, 0);
    if (_layout.adjustSpacingWhenScroling) {
        dgc_transform3D = CATransform3DTranslate(dgc_transform3D, translate, 0, 0);
    }
    dgc_attributes.transform3D = dgc_transform3D;
    dgc_attributes.alpha = dgc_alpha;

}
@end


@implementation DGCTYCyclePagerViewLayout

- (instancetype)init {
    if (self = [super init]) {
        _itemVerticalCenter = YES;
        _minimumScale = 0.8;
        _minimumAlpha = 1.0;
        _maximumAngle = 0.2;
        _rateOfChange = 0.4;
        _adjustSpacingWhenScroling = YES;
    }
    return self;
}

#pragma mark - getter

- (UIEdgeInsets)onlyOneSectionInset {
    CGFloat leftSpace = _pageView && !_isInfiniteLoop && _itemHorizontalCenter ? (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2 : _sectionInset.left;
    CGFloat rightSpace = _pageView && !_isInfiniteLoop && _itemHorizontalCenter ? (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2 : _sectionInset.right;
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, leftSpace, verticalSpace, rightSpace);
    }
    return UIEdgeInsetsMake(_sectionInset.top, leftSpace, _sectionInset.bottom, rightSpace);
}

- (UIEdgeInsets)firstSectionInset {
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, _sectionInset.left, verticalSpace, _itemSpacing);
    }
    return UIEdgeInsetsMake(_sectionInset.top, _sectionInset.left, _sectionInset.bottom, _itemSpacing);
}

- (UIEdgeInsets)lastSectionInset {
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, 0, verticalSpace, _sectionInset.right);
    }
    return UIEdgeInsetsMake(_sectionInset.top, 0, _sectionInset.bottom, _sectionInset.right);
}

- (UIEdgeInsets)middleSectionInset {
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, 0, verticalSpace, _itemSpacing);
    }
    return _sectionInset;
}

@end
