
#import <UIKit/UIKit.h>

@interface CustomPlayerView : UIView

@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *timeLabel;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription duration:(NSUInteger)duration andBackgroundColor:(NSString *)colorName;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription duration:(NSUInteger)duration andBackgroundColor:(NSString *)colorName isIpad:(BOOL)isIpad;

@end
