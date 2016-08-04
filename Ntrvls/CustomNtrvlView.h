//
//  CustomNtrvlView.h
//  Ntrvls

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
@property (strong, nonatomic) UILabel *intervalDurationLabel;
@property (strong, nonatomic) UIButton *deleteButton;
@property (assign, nonatomic) int64_t positionInWorkout;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration;


@end
