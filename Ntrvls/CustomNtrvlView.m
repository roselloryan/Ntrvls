
#import "CustomNtrvlView.h"
#import "UIColor+UIColorExtension.h"


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
        self.minutesTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.secondsTextField = [[UITextField alloc]initWithFrame:CGRectMake(self.minutesTextField.frame.size.width + 12, self.descriptionTextView.frame.size.height + 16, frame.size.width / 2 - 8, frame.size.height / 4)];
        self.secondsTextField.placeholder = @"sec";
        self.secondsTextField.textAlignment = NSTextAlignmentCenter;
        self.secondsTextField.text = [self.intervalDurationLabel.text componentsSeparatedByString:@":"][1];
        self.secondsTextField.userInteractionEnabled = NO;
        self.secondsTextField.hidden = YES;
        self.secondsTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.frame.size.height - self.frame.size.height / 12, self.frame.size.width / 7, self.frame.size.height / 12)];
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [deleteButton setTitle:@"X" forState:UIControlStateNormal];
        deleteButton.backgroundColor = [UIColor darkGrayColor];
        [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden = YES;
        self.deleteButton = deleteButton;
        
        UIButton *selectColorButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.width / 7, self.frame.size.height - self.frame.size.height / 12, self.frame.size.width / 7, self.frame.size.height / 12)];
        selectColorButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [selectColorButton setTitle:@"C" forState:UIControlStateNormal];
        selectColorButton.backgroundColor = [UIColor darkGrayColor];
        [selectColorButton addTarget:self action:@selector(selectColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        selectColorButton.hidden = YES;
        self.selectColorButton = selectColorButton;
        
        UIView *selectColorsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        selectColorsView.backgroundColor = [UIColor whiteColor];
        selectColorsView.hidden = YES;
        self.selectColorsView = selectColorsView;
        
        UILabel *changeColorLabel = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 6)];
        changeColorLabel.text = @"Colors";
        changeColorLabel.textAlignment = NSTextAlignmentCenter;
        changeColorLabel.backgroundColor = [UIColor grayColor];
        
        UIButton *redButton = [[UIButton alloc]initWithFrame: CGRectMake(0, self.frame.size.height / 6, self.frame.size.width, self.frame.size.height / 6)];
        [redButton setTitle:@"red" forState: UIControlStateNormal];
        redButton.backgroundColor = [UIColor ntrvlsRed];
//        [redButton addTarget: self action:@selector(redButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        [redButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.redButton = redButton;

        UIButton *blueButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 2 * self.frame.size.height / 6, self.frame.size.width, self.frame.size.height / 6)];
        [blueButton setTitle:@"blue" forState: UIControlStateNormal];
        blueButton.backgroundColor = [UIColor ntrvlsBlue];
//        [blueButton addTarget: self action:@selector(blueButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        [blueButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.blueButton = blueButton;

        UIButton *yellowButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 3 * self.frame.size.height / 6, self.frame.size.width, self.frame.size.height / 6)];
        [yellowButton setTitle:@"yellow" forState: UIControlStateNormal];
        yellowButton.backgroundColor = [UIColor ntrvlsYellow];
//        [yellowButton addTarget: self action:@selector(yellowButtonTapped: ) forControlEvents: UIControlEventTouchUpInside];
        [yellowButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents: UIControlEventTouchUpInside];
        self.yellowButton = yellowButton;

        UIButton *greenButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 4 * self.frame.size.height / 6, self.frame.size.width, self.frame.size.height / 6)];
        [greenButton setTitle:@"green" forState: UIControlStateNormal];
        greenButton.backgroundColor = [UIColor ntrvlsGreen];
//        [greenButton addTarget: self action:@selector(greenButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        [greenButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
         self.greenButton = greenButton;
        
        UIButton *greyButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 5 * self.frame.size.height / 6, self.frame.size.width, self.frame.size.height / 6)];
        [greyButton setTitle:@"grey" forState: UIControlStateNormal];
        greyButton.backgroundColor = [UIColor ntrvlsGrey];
//        [greyButton addTarget: self action:@selector(greyButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        [greyButton addTarget: self action:@selector(colorButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        self.greyButton = greyButton;
        
        
        [self addSubview: self.intervalDurationLabel];
        [self addSubview: self.minutesTextField];
        [self addSubview: self.secondsTextField];
        [self addSubview: self.descriptionTextView];
        [self addSubview: self.deleteButton];
        [self addSubview: self.selectColorButton];
        [self addSubview: self.selectColorsView];
        
        [self.selectColorsView addSubview: changeColorLabel];
        [self.selectColorsView addSubview: self.redButton];
        [self.selectColorsView addSubview: self.blueButton];
        [self.selectColorsView addSubview: self.yellowButton];
        [self.selectColorsView addSubview: self.greenButton];
        [self.selectColorsView addSubview: self.greyButton];
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
        self.screenColor = @"blue";
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
}

- (void)selectColorButtonTapped:(UIButton *)sender {
    NSLog(@"did we hear this?");
    // show color selection view or buttons?
    self.selectColorsView.hidden = NO;
}

- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
    
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount >= 60) {
        minutes = secondsCount / 60;
        seconds = secondsCount % 60;
    }
    else {
        seconds = secondsCount;
    }
    
    NSString *minutesString = [NSString stringWithFormat:@"%lu", minutes];
    NSString *secondsString = @"";

    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat:@"%lu", seconds];
    }
    
    NSString *timeString = [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
    
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
