
#import <UIKit/UIKit.h>

@interface IntervalLabel : UILabel

@property (assign, nonatomic) BOOL isSelected;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration;

@end
