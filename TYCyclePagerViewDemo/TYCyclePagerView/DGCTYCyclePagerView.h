//
//  DGCTYCyclePagerView.h
//  DGCTYCyclePagerViewDemo
//
//  Created by tany on 2017/6/14.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<DGCTYCyclePagerView/DGCTYCyclePagerView.h>)
#import <DGCTYCyclePagerView/DGCTYCyclePagerTransformLayout.h>
#else
#import "DGCTYCyclePagerTransformLayout.h"
#endif
#if __has_include(<DGCTYCyclePagerView/DGCTYPageControl.h>)
#import <DGCTYCyclePagerView/DGCTYPageControl.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    NSInteger index;
    NSInteger section;
}TYIndexSection;

// pagerView scrolling direction
typedef NS_ENUM(NSUInteger, TYPagerScrollDirection) {
    TYPagerScrollDirectionLeft,
    TYPagerScrollDirectionRight,
};

@class DGCTYCyclePagerView;
@protocol DGCTYCyclePagerViewDataSource <NSObject>

- (NSInteger)numberOfItemsInPagerView:(DGCTYCyclePagerView *)pageView;

- (__kindof UICollectionViewCell *)pagerView:(DGCTYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index;

/**
 return pagerView layout,and cache layout
 */
- (DGCTYCyclePagerViewLayout *)layoutForPagerView:(DGCTYCyclePagerView *)pageView;

@end

@protocol DGCTYCyclePagerViewDelegate <NSObject>

@optional

/**
 pagerView did scroll to new index page
 */
- (void)pagerView:(DGCTYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/**
 pagerView did selected item cell
 */
- (void)pagerView:(DGCTYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;
- (void)pagerView:(DGCTYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndexSection:(TYIndexSection)indexSection;

// custom layout
- (void)pagerView:(DGCTYCyclePagerView *)pageView initializeTransformAttributes:(UICollectionViewLayoutAttributes *)attributes;

- (void)pagerView:(DGCTYCyclePagerView *)pageView applyTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes;


// scrollViewDelegate

- (void)pagerViewDidScroll:(DGCTYCyclePagerView *)pageView;

- (void)pagerViewWillBeginDragging:(DGCTYCyclePagerView *)pageView;

- (void)pagerViewDidEndDragging:(DGCTYCyclePagerView *)pageView willDecelerate:(BOOL)decelerate;

- (void)pagerViewWillBeginDecelerating:(DGCTYCyclePagerView *)pageView;

- (void)pagerViewDidEndDecelerating:(DGCTYCyclePagerView *)pageView;

- (void)pagerViewWillBeginScrollingAnimation:(DGCTYCyclePagerView *)pageView;

- (void)pagerViewDidEndScrollingAnimation:(DGCTYCyclePagerView *)pageView;

@end


@interface DGCTYCyclePagerView : UIView

// will be automatically resized to track the size of the pagerView
@property (nonatomic, strong, nullable) UIView *backgroundView; 

@property (nonatomic, weak, nullable) id<DGCTYCyclePagerViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<DGCTYCyclePagerViewDelegate> delegate;

// pager view, don't set dataSource and delegate
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
// pager view layout
@property (nonatomic, strong, readonly) DGCTYCyclePagerViewLayout *layout;

/**
 is infinite cycle pageview
 */
@property (nonatomic, assign) BOOL isInfiniteLoop;

/**
 pagerView automatic scroll time interval, default 0,disable automatic
 */
@property (nonatomic, assign) CGFloat autoScrollInterval;

@property (nonatomic, assign) BOOL reloadDataNeedResetIndex;

/**
 current page index
 */
@property (nonatomic, assign, readonly) NSInteger curIndex;
@property (nonatomic, assign, readonly) TYIndexSection indexSection;

// scrollView property
@property (nonatomic, assign, readonly) CGPoint contentOffset;
@property (nonatomic, assign, readonly) BOOL tracking;
@property (nonatomic, assign, readonly) BOOL dragging;
@property (nonatomic, assign, readonly) BOOL decelerating;


/**
 reload data, !!important!!: will clear layout and call delegate layoutForPagerView
 */
- (void)reloadData;

/**
 update data is reload data, but not clear layuot
 */
- (void)updateData;

/**
 if you only want update layout
 */
- (void)setNeedUpdateLayout;

/**
 will set layout nil and call delegate->layoutForPagerView
 */
- (void)setNeedClearLayout;

/**
 current index cell in pagerView
 */
- (__kindof UICollectionViewCell * _Nullable)curIndexCell;

/**
 visible cells in pageView
 */
- (NSArray<__kindof UICollectionViewCell *> *_Nullable)visibleCells;


/**
 visible pageView indexs, maybe repeat index
 */
- (NSArray *)visibleIndexs;

/**
 scroll to item at index
 */
- (void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate;
- (void)scrollToItemAtIndexSection:(TYIndexSection)indexSection animate:(BOOL)animate;
/**
 scroll to next or pre item
 */
- (void)scrollToNearlyIndexAtDirection:(TYPagerScrollDirection)direction animate:(BOOL)animate;

/**
 register pager view cell with class
 */
- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;

/**
 register pager view cell with nib
 */
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/**
 dequeue reusable cell for pagerView
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
