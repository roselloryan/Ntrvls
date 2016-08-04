//
//  TimerPrepVC.m
//  Ntrvls


#import "TimerPrepVC.h"
#import "TimerPlayVC.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsAPIClient.h"
#import "JNKeychainWrapper.h"
#import "CustomNtrvlView.h"
#import "IntervalLabel.h"

@interface TimerPrepVC () <UIGestureRecognizerDelegate, UITextFieldDelegate, DeleteButtonProtocol>

@property (weak, nonatomic) IBOutlet UILabel *workoutTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic)  UITextView *descriptionTextView;
@property (weak, nonatomic)  UITextField *minutesTextField;
@property (weak, nonatomic)  UITextField *secondsTextField;
@property (weak, nonatomic) IBOutlet UIButton *addIntervalButton;


@end

@implementation TimerPrepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workoutTitleLabel.text = self.selectedWorkout.workoutTitle;
    
    
    // Do You want the nav bar controls or custom button layout
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO];
    
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.borderColor = [UIColor ntrvlsGreen].CGColor;
    self.startButton.layer.cornerRadius = 5.0f;
    self.startButton.layer.masksToBounds = YES;
    
    [self.startButton addTarget:self action:@selector(dimBorder) forControlEvents:UIControlEventTouchDown];
    [self.startButton addTarget:self action:@selector(brightenBorder) forControlEvents:UIControlEventTouchCancel |UIControlEventTouchUpInside | UIControlEventTouchDragOutside];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addIntervalLabelCellsToContentView];
    

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // keychain tests
//    NSLog(@"Running generic Keychain test");
//    [self testKeychain:@"genericTestValue" forKey:@"genericTestKey" andAccessGroup:nil];
//    [self testKeychain:@"1234567" forKey:@"access_token" andAccessGroup:nil];
}

#pragma mark - Buttons


- (IBAction)shareOnStravaButtonTapped:(UIButton *)sender {
    
    [NtrvlsAPIClient loginIntoStrava];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessDenied) name: @"deniedAccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessAllowed) name: @"allowedAccess" object:nil];
}


- (IBAction)startButtonTapped:(UIButton *)sender {
    
    // just segues right now
}



- (IBAction)addIntervalButtonTapped:(UIButton *)sender {
    
    NSUInteger labelWidth = self.view.frame.size.width / 4;
    NSUInteger labelHeight = self.view.frame.size.height / 5;
    NSUInteger xCoordonate = self.contentView.frame.size.width;
    NSUInteger yCoordinate = 0.25 * labelHeight;
    
    CustomNtrvlView *newIntervalView = [[CustomNtrvlView alloc]initWithFrame:CGRectMake(xCoordonate, yCoordinate, labelWidth, labelHeight) intervalDescription:@"NEW Ntrvl" andDuration:100];
    newIntervalView.backgroundColor = [UIColor ntrvlsYellow];
    newIntervalView.delegate = self;
    
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width + labelWidth, self.contentView.frame.size.height);
    
    self.contentViewWidth.constant = self.contentViewWidth.constant + labelWidth;
    
    [self.contentView addSubview: newIntervalView];
    
    [self addGestureRecognizerToView: newIntervalView];
    [self selectNtrvlView: newIntervalView];
    
}

- (void)deleteButtonTapped:(UIButton *)sender {
    
    CustomNtrvlView *deletedView = ((CustomNtrvlView *) sender.superview);
    
    [self deselectNtrvlView: deletedView];
    [self deleteNrtvlView: deletedView];
}


# pragma mark - HARD CODED NTRVLS METHOD

- (void)addIntervalLabelCellsToContentView {
    
    NSUInteger labelWidth = self.view.frame.size.width / 4;
    NSUInteger labelHeight = self.view.frame.size.height / 5;
    
    self.contentViewWidth.constant = labelWidth * self.selectedWorkout.interval.count;
    
    for (NSInteger i = 0; i < self.selectedWorkout.interval.count; i ++) {
        
        Ntrvl *interval = self.selectedWorkout.interval[i];
        
        NSUInteger xCoordinte = i * labelWidth;
        NSUInteger yCoordinte = 0.25 * labelHeight;

        CustomNtrvlView *intervalView = [[CustomNtrvlView alloc]initWithFrame:CGRectMake(xCoordinte, yCoordinte, labelWidth, labelHeight) intervalDescription: interval.intervalDescription andDuration: interval.intervalDuration];
        intervalView.delegate = self;
        intervalView.positionInWorkout = interval.positionNumberInWorkout;
        
        NSLog(@"intervalView.positionInWorkout: %lld", intervalView.positionInWorkout);

        
        if (i == 0) {
            intervalView.backgroundColor = [UIColor ntrvlsYellow];
        }
        
        else {
            [self addGestureRecognizerToView:intervalView];
            
            if ([interval.screenColor isEqualToString: @"yellow"]) {
                intervalView.backgroundColor = [UIColor ntrvlsYellow];
            }
            else if ([interval.screenColor isEqualToString:@"blue"]) {
                intervalView.backgroundColor = [UIColor ntrvlsBlue];
            }
            else if ([interval.screenColor isEqualToString:@"green"]) {
                intervalView.backgroundColor = [UIColor ntrvlsGreen];
            }
            else if ([interval.screenColor isEqualToString:@"grey"]) {
                intervalView.backgroundColor = [UIColor ntrvlsGrey];
            }
            else {
                intervalView.backgroundColor = [UIColor ntrvlsRed];
            }
        }
        
        [self.contentView addSubview:intervalView];
    }
}


// TODO: Add editing save from textFields
- (void)getBiggerFromGestureRecognizer:(UITapGestureRecognizer *)gestureRecongnizer {

    if (gestureRecongnizer.state == UIGestureRecognizerStateEnded) {
        
        if ([gestureRecongnizer.view isKindOfClass: [CustomNtrvlView class]]) {
            
            CustomNtrvlView *selectedNtrvlView = (CustomNtrvlView *)gestureRecongnizer.view;
            
            if (selectedNtrvlView.isSelected == NO) {
                
                selectedNtrvlView.isSelected = YES;
                [self.contentView bringSubviewToFront: gestureRecongnizer.view];
                [self selectNtrvlView: selectedNtrvlView];
                
            }
            
            else {
                
                selectedNtrvlView.isSelected = NO;
                [self deselectNtrvlView: selectedNtrvlView];
                
                // save text fields Ntrvl models
                NSLog(@"position in workout: %lld", selectedNtrvlView.positionInWorkout);
                
                self.selectedWorkout.interval[selectedNtrvlView.positionInWorkout + 1].intervalDescription = self.descriptionTextView.text;
                
                // make sure only numbers in min and sec text fields
//                NSCharacterSet *numbersCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
//                NSString *minString = self.minutesTextField.text;
//                NSString *secString = self.secondsTextField.text;
//
//                NSLog(@"minString: %lu", [minString integerValue]);
//                NSLog(@"secString: %lu", [secString integerValue]);
                
//                self.selectedWorkout.interval[selectedNtrvlView.positionInWorkout + 1].intervalDuration = [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue];
            }
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}


- (void)stravaAccessAllowed {
    
    NSLog(@"Strava Access allowed");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    
    [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname:@"TABATA" type:@"run" startDateLocal:@"2013-11-23T10:02:13Z" elapsedTime:600 description:@"8x20secFullspeed" withCompletionBlock:^(BOOL success) {
        
        if (success){
            NSLog(@"Posted Ntrvls Workout!!!");
        }
        else {
            NSLog(@"Posting failed :(");
        }
    }];
}

- (void)stravaAccessDenied {
    
    NSLog(@"!!!!!!!!Strava Access Denied!!!!!!!!");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
}

#pragma mark - border methods for start button

- (void)dimBorder {
    
    self.startButton.layer.borderColor = [[UIColor ntrvlsGreen] colorWithAlphaComponent:0.2].CGColor;
}

- (void)brightenBorder {
    
    self.startButton.layer.borderColor = [[UIColor ntrvlsGreen] colorWithAlphaComponent:0.85].CGColor;
}

#pragma mark - cell methods

- (void)selectNtrvlView:(CustomNtrvlView *)selectedView {
    
    self.descriptionTextView = selectedView.descriptionTextView;
    self.minutesTextField = selectedView.minutesTextField;
    self.secondsTextField = selectedView.secondsTextField;
    
    selectedView.descriptionTextView.userInteractionEnabled = YES;
    selectedView.descriptionTextView.editable = YES;
    
    selectedView.descriptionTextView.textColor = [UIColor whiteColor];
    selectedView.minutesTextField.textColor = [UIColor whiteColor];
    selectedView.secondsTextField.textColor = [UIColor whiteColor];
    
    selectedView.intervalDurationLabel.hidden = YES;
    selectedView.minutesTextField.hidden = NO;
    selectedView.secondsTextField.hidden = NO;
    selectedView.deleteButton.hidden = NO;
    
    selectedView.minutesTextField.userInteractionEnabled = YES;
    selectedView.secondsTextField.userInteractionEnabled = YES;
    
    selectedView.descriptionTextView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    selectedView.minutesTextField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    selectedView.secondsTextField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    
    [selectedView.descriptionTextView becomeFirstResponder];
    [selectedView bringSubviewToFront: selectedView.deleteButton];
    
    
    [UIView animateWithDuration: 0.2 animations:^{
        
        selectedView.transform = CGAffineTransformMakeScale(2.5, 2.5);
        
    } completion:^(BOOL finished) {
        // anything else?
    }];
}


- (void)deselectNtrvlView:(CustomNtrvlView *)deselectedView {
    
    deselectedView.descriptionTextView.userInteractionEnabled = NO;
    deselectedView.minutesTextField.userInteractionEnabled = NO;
    deselectedView.secondsTextField.userInteractionEnabled = NO;
    
    deselectedView.intervalDurationLabel.hidden = NO;
    deselectedView.minutesTextField.hidden = YES;
    deselectedView.secondsTextField.hidden = YES;
    deselectedView.deleteButton.hidden = YES;
    
    deselectedView.descriptionTextView.textColor = [UIColor darkTextColor];
    
    deselectedView.descriptionTextView.backgroundColor = [UIColor clearColor];
    deselectedView.minutesTextField.backgroundColor = [UIColor clearColor];
    deselectedView.secondsTextField.backgroundColor = [UIColor clearColor];
    
    [deselectedView.descriptionTextView resignFirstResponder];
    [deselectedView.minutesTextField resignFirstResponder];
    [deselectedView.secondsTextField resignFirstResponder];
    
    [UITextField animateWithDuration: 0.3 animations:^{
        
        NSLog(@"\ndesc: %@\n min: %@\n sec: %@\n", self.descriptionTextView.text, self.minutesTextField.text, self.secondsTextField.text);
        deselectedView.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:^(BOOL finished) {
        // anything else?
    }];
}

- (void)addGestureRecognizerToView:(UIView *)view {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget: self action:@selector(getBiggerFromGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.view.userInteractionEnabled = YES;
    
    [view addGestureRecognizer: tapGestureRecognizer];
}


- (void)deleteNrtvlView:(CustomNtrvlView *)deletedNtrvlView {
    
    for (CustomNtrvlView *ntrvlView in self.contentView.subviews) {
        
        if (deletedNtrvlView.positionInWorkout < ntrvlView.positionInWorkout) {
            
            [UIView animateWithDuration: 0.2 animations:^{
                ntrvlView.frame = CGRectMake(ntrvlView.frame.origin.x - deletedNtrvlView.frame.size.width, ntrvlView.frame.origin.y, ntrvlView.frame.size.width, ntrvlView.frame.size.height);
            }];
        }
    }
    [deletedNtrvlView removeFromSuperview];
    
    // contract contentView width
    self.contentViewWidth.constant =  self.contentViewWidth.constant - deletedNtrvlView.frame.size.width;
}

#pragma mark - Keychain test method

- (void)testKeychain:(NSString *)value forKey:(NSString *)key andAccessGroup:(NSString *)group
{
    NSString *forGroupLog = (group ? [NSString stringWithFormat:@" for access group '%@'", group] : @"");
    
    if ([JNKeychainWrapper saveValue:value forKey:key forAccessGroup:group]) {
        NSLog(@"Correctly saved value '%@' for key '%@'%@", value, key, forGroupLog);
    } else {
        NSLog(@"Failed to save!%@", forGroupLog);
    }
    
    NSLog(@"Value for key '%@' is: '%@'%@", key, [JNKeychainWrapper loadValueForKey:key forAccessGroup:group], forGroupLog);
    
    if ([JNKeychainWrapper deleteValueForKey:key forAccessGroup:group]) {
        NSLog(@"Deleted value for key '%@'. Value is: '%@'%@", key, [JNKeychainWrapper loadValueForKey:key forAccessGroup:group], forGroupLog);
    } else {
        NSLog(@"Failed to delete!%@", forGroupLog);
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"TimerPlaySegue"]) {
        NSLog(@"Segueing to player VC!");
        
        TimerPlayVC *destinationVC = segue.destinationViewController;
        destinationVC.selectedWorkout = self.selectedWorkout;
    }
}


@end
