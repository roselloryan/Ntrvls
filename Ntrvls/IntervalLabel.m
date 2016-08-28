
#import "IntervalLabel.h"

@implementation IntervalLabel

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration {
    
    self =  [super init];
    
    if (self) {
        self.frame = frame;
        self.numberOfLines = 3;
        self.textAlignment = NSTextAlignmentCenter;
        
        self.text = [NSString stringWithFormat:@"%@\n%@",intervalDescription, [self timeStringFromSecondsCount:duration]];
        
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.cornerRadius = 1.0f;
        
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        self.contentMode = UIViewContentModeScaleToFill;
        
    }
    return self;
}

- (void)getBigger {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 3 * self.frame.size.width, 3 * self.frame.size.height);
}

- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
    
    NSUInteger hours = 0;
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount > 3600) {
        hours =  secondsCount / 3600;
        seconds = secondsCount % 3600;
    }
    if (seconds > 60) {
        minutes = seconds / 60;
        seconds = seconds % 60;
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
