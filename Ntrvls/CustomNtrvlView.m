//
//  CustomNtrvlView.m
//  Ntrvls


#import "CustomNtrvlView.h"


@implementation CustomNtrvlView

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration {
    
    self =  [super init];
    
    if (self) {
        self.frame = frame;
        

        self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 8, self.frame.size.width, self.frame.size.height / 2)];
        self.userInteractionEnabled = YES;
        
        self.descriptionTextView.text = intervalDescription;
        self.descriptionTextView.backgroundColor = [UIColor clearColor];
        self.descriptionTextView.textContainer.maximumNumberOfLines = 3;
        self.descriptionTextView.userInteractionEnabled = NO;
        
        self.intervalDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.descriptionTextView.frame.size.height + 16, frame.size.width, frame.size.height / 4)];
        self.intervalDurationLabel.textAlignment = NSTextAlignmentCenter;
        self.intervalDurationLabel.text = [self timeStringFromSecondsCount:duration];


        
        self.minutesTextField = [[UITextField alloc]initWithFrame:CGRectMake(4, self.descriptionTextView.frame.size.height + 16, frame.size.width / 2 - 8, frame.size.height / 4)];
        
        self.minutesTextField.placeholder = @"min";
        self.minutesTextField.textAlignment = NSTextAlignmentCenter;
        self.minutesTextField.text = [self.intervalDurationLabel.text componentsSeparatedByString:@":"][0];
        self.minutesTextField.userInteractionEnabled = NO;
        self.minutesTextField.hidden = YES;
        
        self.secondsTextField = [[UITextField alloc]initWithFrame:CGRectMake(self.minutesTextField.frame.size.width + 12, self.descriptionTextView.frame.size.height + 16, frame.size.width / 2 - 8, frame.size.height / 4)];
        self.secondsTextField.placeholder = @"sec";
        self.secondsTextField.textAlignment = NSTextAlignmentCenter;
        self.secondsTextField.text = [self.intervalDurationLabel.text componentsSeparatedByString:@":"][1];
        self.secondsTextField.userInteractionEnabled = NO;
        self.secondsTextField.hidden = YES;
        
        UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.frame.size.height - self.frame.size.height / 12, self.frame.size.width / 7, self.frame.size.height / 12)];
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [deleteButton setTitle:@"X" forState:UIControlStateNormal];
        deleteButton.backgroundColor = [UIColor darkGrayColor];
        [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden = YES;
        self.deleteButton = deleteButton;
        
        [self addSubview: self.intervalDurationLabel];
        [self addSubview: self.minutesTextField];
        [self addSubview: self.secondsTextField];
        [self addSubview: self.descriptionTextView];
        [self addSubview: self.deleteButton];
    }
    return self;
}

- (void)deleteButtonTapped:(UIButton *)sender {
    [self.delegate deleteButtonTapped: sender];
}

- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
    
    NSUInteger hours = 0;
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount > 3600) {
        hours =  secondsCount / 3600;
        seconds = secondsCount % 3600;
    }
    if (secondsCount >= 60) {
        minutes = secondsCount / 60;
        seconds = secondsCount % 60;
    }
    else {
        seconds = secondsCount;
    }
    
    NSString *hoursString = @"";
    NSString *minutesString = @"";
    NSString *secondsString = @"";
    
    if (hours < 10) {
        hoursString = [NSString stringWithFormat:@"0%lu", hours];
    }
    else {
        hoursString = [NSString stringWithFormat:@"%lu", hours];
    }
    if (minutes < 10) {
        minutesString = [NSString stringWithFormat:@"0%lu", minutes];
    }
    else {
        minutesString = [NSString stringWithFormat:@"%lu", minutes];
    }
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat:@"%lu", seconds];
    }
    
    NSString *timeString = @"";
    if (hours == 0) {
        timeString = [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
    }
    else {
        timeString = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minutesString, secondsString];
    }
    return timeString;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
