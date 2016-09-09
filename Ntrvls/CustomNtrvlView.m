
#import "CustomNtrvlView.h"
#import "UIColor+UIColorExtension.h"


@implementation CustomNtrvlView

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration {
    
    self =  [super init];
    
    if (self) {
        self.frame = frame;
        

        self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(8, 8, frame.size.width - 16, frame.size.height / 2.5)];
        self.userInteractionEnabled = YES;
        
        self.descriptionTextView.text = intervalDescription;
        self.descriptionTextView.textColor = [UIColor whiteColor];
        self.descriptionTextView.backgroundColor = [UIColor clearColor];
        self.descriptionTextView.textContainer.maximumNumberOfLines = 3;
//        self.descriptionTextView.font = [UIFont systemFontOfSize: 15.0 weight:UIFontWeightThin];
        self.descriptionTextView.userInteractionEnabled = NO;
        
        self.intervalDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.descriptionTextView.frame.size.height + 16, frame.size.width, frame.size.height / 4)];
        self.intervalDurationLabel.textAlignment = NSTextAlignmentCenter;
//        self.intervalDurationLabel.font = [UIFont systemFontOfSize: 15.0 weight:UIFontWeightThin];
        self.intervalDurationLabel.text = [self timeStringFromSecondsCount:duration];
        self.intervalDurationLabel.textColor = [UIColor whiteColor];


        
        self.minutesTextField = [[UITextField alloc]initWithFrame:CGRectMake(8, self.descriptionTextView.frame.size.height + 20, frame.size.width / 2 - 16, frame.size.height / 4)];
        
        self.minutesTextField.placeholder = @"min";
        self.minutesTextField.textAlignment = NSTextAlignmentCenter;
        self.minutesTextField.text = [self.intervalDurationLabel.text componentsSeparatedByString:@":"][0];
        self.minutesTextField.textColor = [UIColor whiteColor];
        self.minutesTextField.userInteractionEnabled = NO;
        self.minutesTextField.hidden = YES;
        self.minutesTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.secondsTextField = [[UITextField alloc]initWithFrame:CGRectMake(self.minutesTextField.frame.size.width + 24, self.descriptionTextView.frame.size.height + 20, frame.size.width / 2 - 16, frame.size.height / 4)];
        self.secondsTextField.placeholder = @"sec";
        self.secondsTextField.textAlignment = NSTextAlignmentCenter;
        self.secondsTextField.text = [self.intervalDurationLabel.text componentsSeparatedByString:@":"][1];
        self.secondsTextField.textColor = [UIColor whiteColor];
        self.secondsTextField.userInteractionEnabled = NO;
        self.secondsTextField.hidden = YES;
        self.secondsTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        UILabel *colonLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.descriptionTextView.frame.size.height + 16, frame.size.width, frame.size.height / 4)];
        colonLabel.font = [UIFont systemFontOfSize: 30.0];
        colonLabel.text = @":";
        colonLabel.textColor = [UIColor whiteColor];
//        colonLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        colonLabel.textAlignment = NSTextAlignmentCenter;
        colonLabel.hidden = YES;
        self.colonLabel = colonLabel;
        
        UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(4, frame.size.height - frame.size.height / 16 - 4, frame.size.width / 11, frame.size.height / 16)];
        [deleteButton setBackgroundImage:[UIImage imageNamed: @"grey trashcan icon"] forState: UIControlStateNormal];
        deleteButton.backgroundColor = [UIColor clearColor];
        [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden = YES;
        deleteButton.alpha = 0.9;
        self.deleteButton = deleteButton;
        
        UIButton *selectColorButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - frame.size.width / 11 - 4, frame.size.height - frame.size.height / 16 - 4, frame.size.width / 11, frame.size.height / 16)];
        [selectColorButton setBackgroundImage:[UIImage imageNamed:@"grey palette icon"] forState: UIControlStateNormal];
        selectColorButton.backgroundColor = [UIColor clearColor];
        [selectColorButton addTarget:self action:@selector(selectColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        selectColorButton.hidden = YES;
        selectColorButton.alpha = 0.9;
        self.selectColorButton = selectColorButton;
        
        UIView *selectColorsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        selectColorsView.backgroundColor = [UIColor whiteColor];
        selectColorsView.hidden = YES;
        self.selectColorsView = selectColorsView;
        
        UILabel *changeColorLabel = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height / 7)];
        changeColorLabel.font = [UIFont systemFontOfSize: 10 weight: UIFontWeightThin];
        changeColorLabel.text = @"Colors";
        changeColorLabel.textColor = [UIColor whiteColor];
        changeColorLabel.textAlignment = NSTextAlignmentCenter;
        changeColorLabel.backgroundColor = [UIColor blackColor];
        
        UIButton *redButton = [[UIButton alloc]initWithFrame: CGRectMake(0, frame.size.height / 7, frame.size.width, self.frame.size.height / 7)];
        redButton.backgroundColor = [UIColor ntrvlsRed];
        [redButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.redButton = redButton;

        UIButton *blueButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 2 * frame.size.height / 7, frame.size.width, self.frame.size.height / 7)];
        blueButton.backgroundColor = [UIColor ntrvlsBlue];
        [blueButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.blueButton = blueButton;

        UIButton *yellowButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 3 * frame.size.height / 7, frame.size.width, self.frame.size.height / 7)];
        yellowButton.backgroundColor = [UIColor ntrvlsYellow];
        [yellowButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents: UIControlEventTouchUpInside];
        self.yellowButton = yellowButton;

        UIButton *greenButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 4 * frame.size.height / 7, frame.size.width, frame.size.height / 7)];
        greenButton.backgroundColor = [UIColor ntrvlsGreen];
        [greenButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
         self.greenButton = greenButton;
        
        UIButton *greyButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 5 * frame.size.height / 7, frame.size.width, frame.size.height / 7)];
        greyButton.backgroundColor = [UIColor ntrvlsGrey];
        [greyButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.greyButton = greyButton;

        UIButton *orangeButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 6 * frame.size.height / 7, frame.size.width, frame.size.height / 7)];
        orangeButton.backgroundColor = [UIColor ntrvlsOrange];
        [orangeButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.orangeButton = orangeButton;
        
        [self.selectColorsView addSubview: changeColorLabel];
        [self.selectColorsView addSubview: self.greyButton];
        [self.selectColorsView addSubview: self.orangeButton];
        [self.selectColorsView addSubview: self.redButton];
        [self.selectColorsView addSubview: self.blueButton];
        [self.selectColorsView addSubview: self.yellowButton];
        [self.selectColorsView addSubview: self.greenButton];
        
        [self addSubview: self.colonLabel];
        [self addSubview: self.intervalDurationLabel];
        [self addSubview: self.minutesTextField];
        [self addSubview: self.secondsTextField];
        [self addSubview: self.descriptionTextView];
        [self addSubview: self.selectColorsView];
        [self addSubview: self.deleteButton];
        [self addSubview: self.selectColorButton];
        

    }
    return self;
}

- (void)deleteButtonTapped:(UIButton *)sender {
    [self.delegate deleteButtonTapped: sender];
}

- (void)colorButtonTapped:(UIButton *)sender {
    
    if (sender == self.redButton) {
        self.backgroundColor = [UIColor ntrvlsRed];
        self.selectColorsView.hidden = YES;
        self.screenColor = @"red";
    }
    else if (sender == self.blueButton) {
        self.backgroundColor = [UIColor ntrvlsBlue];
        self.selectColorsView.hidden = YES;
        self.screenColor = @"blue";;
    }
    else if (sender == self.yellowButton) {
        self.backgroundColor = [UIColor ntrvlsYellow];
        self.selectColorsView.hidden = YES;
        self.screenColor = @"yellow";
    }
    else if (sender == self.greenButton) {
        self.backgroundColor = [UIColor ntrvlsGreen];
        self.selectColorsView.hidden = YES;
        self.screenColor = @"green";
    }
    else if (sender == self.greyButton) {
        self.backgroundColor = [UIColor ntrvlsGrey];
        self.selectColorsView.hidden = YES;
        self.screenColor = @"grey";
    }
    else if (sender == self.orangeButton) {
        self.backgroundColor = [UIColor ntrvlsOrange];
        self.selectColorsView.hidden = YES;
        self.screenColor = @"orange";
    }
    self.deleteButton.hidden = NO;
    self.deleteButton.enabled = YES;
    self.selectColorButton.hidden = NO;
    self.selectColorButton.enabled = YES;
}

- (void)selectColorButtonTapped:(UIButton *)sender {
    
    self.selectColorsView.hidden = NO;
    self.selectColorButton.hidden = YES;
    self.deleteButton.hidden = YES;
    self.deleteButton.enabled = NO;
}

- (void)hideSelectColorsViewAndButtons {
    
    self.selectColorsView.hidden = YES;
    self.deleteButton.hidden = YES;
    self.selectColorButton.hidden = YES;
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
//    
//    NSUInteger minutes = 0;
//    NSUInteger seconds = 0;
//    
//    if (secondsCount >= 60) {
//        minutes = secondsCount / 60;
//        seconds = secondsCount % 60;
//    }
//    else {
//        seconds = secondsCount;
//    }
//    
//    NSString *minutesString = [NSString stringWithFormat:@"%lu", minutes];
//    NSString *secondsString = @"";
//
//    
//    if (seconds < 10) {
//        secondsString = [NSString stringWithFormat:@"0%lu", seconds];
//    }
//    else {
//        secondsString = [NSString stringWithFormat:@"%lu", seconds];
//    }
//    
//    NSString *timeString = [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
//    
//    return timeString;
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
