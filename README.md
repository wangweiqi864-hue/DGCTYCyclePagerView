# DGCTYCyclePagerView
a simple and usefull cycle pager view ,and auto scroll banner view ,include pageControl for iOS,support Objective-C and swift.this has been used in APP.

## CocoaPods
```
pod 'DGCTYCyclePagerView'
```
## Carthage
```
github "12207480/DGCTYCyclePagerView"
```
## Requirements
* Xcode 8 or higher
* iOS 7.0 or higher
* ARC

### ScreenShot

![image](https://github.com/12207480/DGCTYCyclePagerView/blob/master/ScreenShot/DGCTYCyclePagerView.gif)

## API

*  DataSource and Delegate 
```objc

@protocol DGCTYCyclePagerViewDataSource <NSObject>

- (NSInteger)numberOfItemsInPagerView:(DGCTYCyclePagerView *)pageView;

- (__kindof UICollectionViewCell *)pagerView:(DGCTYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index;

/**
 return pagerView layout,and cache layout
 */
- (DGCTYCyclePagerViewLayout *)layoutForPagerView:(DGCTYCyclePagerView *)pageView;

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

// More API see project
```

* Class

```objc

@interface DGCTYCyclePagerView : UIView

// will be automatically resized to track the size of the pagerView
@property (nonatomic, strong, nullable) UIView *backgroundView; 

@property (nonatomic, weak, nullable) id<DGCTYCyclePagerViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<DGCTYCyclePagerViewDelegate> delegate;

// pager view layout is important
@property (nonatomic, strong, readonly) DGCTYCyclePagerViewLayout *layout;

/**
 is infinite cycle pageview
 */
@property (nonatomic, assign) BOOL isInfiniteLoop;

/**
 pagerView automatic scroll time interval, default 0,disable automatic
 */
@property (nonatomic, assign) CGFloat autoScrollInterval;


@interface DGCTYCyclePagerViewLayout : NSObject

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) TYCyclePagerTransformLayoutType layoutType;

@property (nonatomic, assign) CGFloat minimumScale; // sacle default 0.8
@property (nonatomic, assign) CGFloat minimumAlpha; // alpha default 1.0
@property (nonatomic, assign) CGFloat maximumAngle; // angle is % default 0.2


@interface TYPageControl : UIControl

@property (nonatomic, assign) NSInteger numberOfPages;          // default is 0
@property (nonatomic, assign) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1

// indicatorTint color
@property (nullable, nonatomic,strong) UIColor *pageIndicatorTintColor;
@property (nullable, nonatomic,strong) UIColor *currentPageIndicatorTintColor;

// indicator image
@property (nullable, nonatomic,strong) UIImage *pageIndicatorImage;
@property (nullable, nonatomic,strong) UIImage *currentPageIndicatorImage;
```

## Usage

```objc

- (void)addPagerView {
    DGCTYCyclePagerView *pagerView = [[DGCTYCyclePagerView alloc]init];
    pagerView.layer.borderWidth = 1;
    pagerView.isInfiniteLoop = YES;
    pagerView.autoScrollInterval = 3.0;
    pagerView.dataSource = self;
    pagerView.delegate = self;
    // registerClass or registerNib
    [pagerView registerClass:[DGCTYCyclePagerViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self.view addSubview:pagerView];
    _pagerView = pagerView;
}

- (void)addPageControl {
    TYPageControl *pageControl = [[TYPageControl alloc]init];
    //pageControl.numberOfPages = _datas.count;
    pageControl.currentPageIndicatorSize = CGSizeMake(8, 8);
//    pageControl.pageIndicatorImage = [UIImage imageNamed:@"Dot"];
//    pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"DotSelected"];
//    [pageControl addTarget:self action:@selector(pageControlValueChangeAction:) forControlEvents:UIControlEventValueChanged];
    [_pagerView addSubview:pageControl];
    _pageControl = pageControl;
}
- (void)loadData {
    // load data to _datas
    _pageControl.numberOfPages = _datas.count;
    [_pagerView reloadData];
}

```

### Contact
如果你发现bug，please pull reqeust me <br>
如果你有更好的改进，please pull reqeust me <br>

### License
DGCTYCyclePagerView is released under the MIT license. See LICENSE for details.
