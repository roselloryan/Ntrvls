
#import <UIKit/UIKit.h>


@protocol DeleteButtonProtocol

- (void)deleteButtonTapped:(UIButton *)sender;

@end


@interface CustomNtrvlView : UIView

@property (assign, nonatomic) id <DeleteButtonProtocol> delegate;

@property (assign, nonatomic) BOOL isSelected;

@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) UITextField *minutesTextField;
@property (strong, nonatomic) UITextField *secondsTextField;
@property (strong, nonatomic) UILabel *colonLabel;
@property (strong, nonatomic) UILabel *intervalDurationLabel;

@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *selectColorButton;
@property (strong, nonatomic) UIButton *redButton;
@property (strong, nonatomic) UIButton *blueButton;
@property (strong, nonatomic) UIButton *yellowButton;
@property (strong, nonatomic) UIButton *greenButton;
@property (strong, nonatomic) UIButton *greyButton;
@property (strong, nonatomic) UIButton *orangeButton;

@property (strong, nonatomic) NSString *screenColor;

@property (assign, nonatomic) int64_t positionInWorkout;
@property (strong, nonatomic) UIView *selectColorsView;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration isIPad:(BOOL)isIPad;

- (void)hideSelectColorsViewAndButtons;

- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount;

@end
