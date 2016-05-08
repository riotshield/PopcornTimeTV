
#import <UIKit/UIKit.h>
#import "SQTabMenuCollectionViewCell.h"

@protocol SYVLCPlayerViewControllerDelegate <NSObject>

- (void) setRatio:(float) ratio;
- (float) currentRatio;

@end

@class SYLoadingProgressView;


@interface SYVLCPlayerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *osdView;
@property (nonatomic, weak) IBOutlet UIView *lineBackView;
@property (nonatomic, weak) IBOutlet UIView *currentLineView;
@property (nonatomic, weak) IBOutlet UIView *topButtonContainerView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *swipeTopConstraint;
@property (nonatomic, weak) IBOutlet UIView *swipeMesaggeContainerView;
@property (nonatomic, weak) IBOutlet UILabel *swipeMesaggeLabel;

@property (nonatomic, weak) IBOutlet UIImageView *loadingLogo;

// Focus
@property (nonatomic, weak) IBOutlet UIView *topMenuContainerView;
@property (nonatomic, weak) IBOutlet UIButton *middleButton;
@property (nonatomic, weak) IBOutlet UIButton *topButton;
@property (nonatomic, weak) IBOutlet UIButton *subValueDelayButton;

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@property (nonatomic, weak) IBOutlet UITextView *subtitleTextView;
@property (nonatomic, weak) IBOutlet UICollectionView *subTabBarCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *audioTabBarCollectionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topTopMenuSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *subtitlesBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftCurrentLineSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightCurrentLineSpace;

@property (nonatomic, weak) IBOutlet UIButton *subsButton;
@property (nonatomic, weak) IBOutlet UIButton *subsDelayButton;
@property (nonatomic, weak) IBOutlet UIButton *audioButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *middleSubsConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *middleAudioConstraint;

@property (nonatomic, weak) IBOutlet UIButton *backSubtitle;
@property (nonatomic, weak) IBOutlet UIView *backSubtitleView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthSubtitleConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightSubtitleConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthSubtitleViewConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightSubtitleViewConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightSubtitleTextConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) float initialRatio;
@property (nonatomic, assign) BOOL isFile;
@property (nonatomic, assign) float currentSubTitleDelay;
@property (nonatomic, weak)   UIViewController <SYVLCPlayerViewControllerDelegate> *rootViewController;
@property (nonatomic, weak) id <SQTabMenuCollectionViewCellDelegate> delegate;

- (id) initWithURL:(NSURL *) url andHash:(NSString *) hash;

@end
