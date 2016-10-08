
#import "CustomPlayerView.h"
#import "UIColor+UIColorExtension.h"

@implementation CustomPlayerView

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription duration:(NSUInteger)duration andBackgroundColor:(NSString *)colorName {
    
    self = [super init];
    
    if (self) {
        self.frame = frame;
        
        UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, self.frame.size.width - 16, self.frame.size.height/2)];
        self.descriptionLabel = descriptionLabel;
        self.descriptionLabel.text = intervalDescription;
        self.descriptionLabel.font = [UIFont systemFontOfSize: 44.0 weight: UIFontWeightThin];
        self.descriptionLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.numberOfLines = 3;
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        self.descriptionLabel.minimumScaleFactor = 0.7;
        [self addSubview: self.descriptionLabel];
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, self.frame.size.height/2, self.frame.size.width - 16, self.frame.size.height/2)];
        self.timeLabel = timeLabel;
        self.timeLabel.font = [UIFont systemFontOfSize: 120.0 weight: UIFontWeightThin];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        self.timeLabel.minimumScaleFactor = 0.7;
//        self.timeLabel.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        self.timeLabel.text = [self timeStringFromSecondsCount: duration];
        [self addSubview: self.timeLabel];
        
        [self updateBackgroundColorForString: colorName];
    }
    return self;
    
}

- (void)updateBackgroundColorForString:(NSString *)colorName {
    
    if ([colorName isEqualToString:@"red"]) {
        self.backgroundColor = [UIColor ntrvlsRed];
    }
    else if ([colorName isEqualToString:@"blue"]) {
        self.backgroundColor = [UIColor ntrvlsBlue];
    }
    else if ([colorName isEqualToString:@"green"]) {
        self.backgroundColor = [UIColor ntrvlsGreen];
    }
    else if ([colorName isEqualToString:@"grey"]) {
        self.backgroundColor = [UIColor ntrvlsGrey];
    }
    else if ([colorName isEqualToString:@"orange"]) {
        self.backgroundColor = [UIColor ntrvlsOrange];
    }
    else {
        self.backgroundColor = [UIColor ntrvlsYellow];
        }
}


- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
    
    NSUInteger hours = 0;
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount >= 3600) {
        hours = secondsCount / 3600;
        secondsCount = secondsCount - (hours * 3600);
    }
    
    if (secondsCount >= 60) {
        minutes = secondsCount / 60;
        seconds = secondsCount % 60;
    }
    else {
        seconds = secondsCount;
    }
    
    NSString *hoursString =  [NSString stringWithFormat: @"%lu", hours];
    NSString *minutesString =  [NSString stringWithFormat: @"%lu", minutes];
    NSString *secondsString = @"";
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat: @"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat: @"%lu", seconds];
    }
    
    NSString *timeString = [[NSString alloc]init];
    if (hours == 0) {
        // set minutes without 0 buffer
        minutesString = [NSString stringWithFormat: @"%lu", minutes];
        timeString = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    }
    else {
        if (minutes < 10) {
            minutesString = [NSString stringWithFormat: @"0%lu", minutes];
        }
        else {
            minutesString = [NSString stringWithFormat: @"%lu", minutes];
        }
        
        timeString = [NSString stringWithFormat: @"%@:%@:%@", hoursString, minutesString, secondsString];
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
