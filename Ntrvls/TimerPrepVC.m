
#import "TimerPrepVC.h"
#import "TimerPlayVC.h"
#import "NtrvlsDataStore.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsAPIClient.h"
#import "JNKeychainWrapper.h"
#import "CustomNtrvlView.h"
#import "IntervalLabel.h"
#include "Ntrvl.h"



@interface TimerPrepVC () <UIGestureRecognizerDelegate, UITextFieldDelegate, DeleteButtonProtocol>

@property (weak, nonatomic) IBOutlet UILabel *workoutTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *addIntervalButton;

@property (weak, nonatomic)  UITextView *descriptionTextView;
@property (weak, nonatomic)  UITextField *minutesTextField;
@property (weak, nonatomic)  UITextField *secondsTextField;
@property (strong, nonatomic) NSString *screenColorOfDeselectedNtrvlView;

@property (weak, nonatomic)  UITextField *alertTextField;

@property (assign, nonatomic) BOOL workoutWasEdited;

@end


@implementation TimerPrepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workoutTitleLabel.text = self.selectedWorkout.workoutTitle;
    
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
    
    self.workoutWasEdited = NO;
    
    
    // make a copy of loaded workout in dataStore then set selectedWorout to copy
    NSLog(@"Workout title before: %@", self.selectedWorkout.workoutTitle);
    
    self.selectedWorkout = [[NtrvlsDataStore sharedNtrvlsDataStore] copyNtrvlWorkout: self.selectedWorkout];

    NSLog(@"Workout title after: %@", self.selectedWorkout.workoutTitle);
    NSLog(@"view did load type: %@", self.selectedWorkout.workoutType);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc]initWithTitle:@"<menu" style:UIBarButtonItemStyleDone target:self action:@selector(showSaveAlert)];
    [menuButton setTitleTextAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin]} forState: UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    if (self.selectedWorkout.workoutType) {
        UIBarButtonItem *workoutTypeButton =[[UIBarButtonItem alloc]initWithTitle: self.selectedWorkout.workoutType style:UIBarButtonItemStyleDone target: self action:@selector(presentWorkoutTypeAlertController)];
        [workoutTypeButton setTitleTextAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin]} forState: UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = workoutTypeButton;
    }
    else {
        UIBarButtonItem *workoutTypeButton =[[UIBarButtonItem alloc]initWithTitle: @"" style: UIBarButtonItemStyleDone target: self action:@selector(presentWorkoutTypeAlertController)];
        [workoutTypeButton setTitleTextAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin]} forState: UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = workoutTypeButton;
        [self presentWorkoutTypeAlertController];
    }
    
    // TODO: how should this really be done?
    if (self.contentView.subviews.count < 1) {
        [self addIntervalLabelCellsToContentView];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // keychain tests
//    NSLog(@"Running generic Keychain test");
//    [self testKeychain:@"genericTestValue" forKey:@"genericTestKey" andAccessGroup:nil];
//    [self testKeychain:@"1234567" forKey:@"access_token" andAccessGroup:nil];
}


#pragma mark - Text Field Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if (textField == self.minutesTextField || textField == self.secondsTextField) {
        
        // TODO: deselect appropriate customNtrvlView
        // TODO: decrease size of text field?
        // But the description field is NOT a text field and the min and sec fields only use numbers keypad...
        // maybe use description textFiled instead of UITextView
    }
    else if (textField == self.alertTextField) {

        if (![[NtrvlsDataStore sharedNtrvlsDataStore] alreadySavedWorkoutWithTitle: self.alertTextField.text]) {
            
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveNewWorkoutWithTitle: self.alertTextField.text];
            [self dismissViewControllerAnimated: NO completion: nil];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else {
            
            [self presentTitleAlreadySavedAlert];
        }
    }
    return YES;
}

#pragma mark - Buttons


- (IBAction)shareOnStravaButtonTapped:(UIButton *)sender {
    
    [NtrvlsAPIClient loginIntoStravaWithSuccessBlock:^(BOOL success) {
        
        if (success){
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessDenied) name: @"deniedAccess" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessAllowed) name: @"allowedAccess" object:nil];
        }
        else {
            NSLog(@"NO CONNECTION :(   :(    :(    :(");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self presentNoInternetAlert];
            });
        }
    }];
}


- (IBAction)startButtonTapped:(UIButton *)sender {
    
    // just segues right now
}

- (IBAction)addIntervalButtonTapped:(UIButton *)sender {

    
    [self addNewCustomNtrvlViewToContentView];
    [[NtrvlsDataStore sharedNtrvlsDataStore] addNewNtrvlToWorkout:self.selectedWorkout];
}

- (void)deleteButtonTapped:(UIButton *)sender {
    
    CustomNtrvlView *deletedView = ((CustomNtrvlView *) sender.superview);
    
    [self deselectNtrvlView: deletedView];
    [self deleteNrtvlView: deletedView];
    self.workoutWasEdited = YES;
}


# pragma mark - customNtrvlViews methods

- (void)addNewCustomNtrvlViewToContentView {
    
    NSUInteger labelWidth = self.view.frame.size.width / 4;
    NSUInteger labelHeight = self.view.frame.size.height / 5;
    NSUInteger xCoordonate = self.contentView.frame.size.width - labelWidth;
    NSUInteger yCoordinate = 0.25 * labelHeight;
    
    CustomNtrvlView *newIntervalView = [[CustomNtrvlView alloc]initWithFrame:CGRectMake(xCoordonate, yCoordinate, labelWidth, labelHeight) intervalDescription:@"NEW Ntrvl" andDuration: 0];
    newIntervalView.positionInWorkout = self.selectedWorkout.interval.count - 1;
    newIntervalView.backgroundColor = [UIColor ntrvlsYellow];
    newIntervalView.screenColor = @"yellow";
    newIntervalView.delegate = self;
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width + labelWidth, self.contentView.frame.size.height);
    
    self.contentViewWidth.constant = self.contentViewWidth.constant + labelWidth;
    
    // move cooldown cell to right & increment position in workout number
    for (CustomNtrvlView *customView in self.contentView.subviews) {
        
        if (customView.positionInWorkout == self.contentView.subviews.count - 1) {
            customView.frame = CGRectMake(customView.frame.origin.x + labelWidth, customView.frame.origin.y, customView.frame.size.width, customView.frame.size.height);
            customView.positionInWorkout ++;
        }
    }
    [self.contentView addSubview: newIntervalView];
    [self addGestureRecognizerToView: newIntervalView];
    [self selectNtrvlView: newIntervalView];
}

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
        intervalView.secondsTextField.delegate = self;
        intervalView.minutesTextField.delegate = self;
        intervalView.positionInWorkout = interval.positionNumberInWorkout;
        intervalView.screenColor = interval.screenColor;
        
        if (i == 0) {
            intervalView.backgroundColor = [UIColor ntrvlsYellow];
        }
        else if (i == self.selectedWorkout.interval.count - 1) {
            intervalView.backgroundColor = [UIColor ntrvlsGrey];
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


- (void)customNtrvlViewTappedFromGestureRecognizer:(UITapGestureRecognizer *)gestureRecongnizer {

    if (gestureRecongnizer.state == UIGestureRecognizerStateEnded) {
        if ([gestureRecongnizer.view isKindOfClass: [CustomNtrvlView class]]) {
            
            CustomNtrvlView *selectedNtrvlView = (CustomNtrvlView *)gestureRecongnizer.view;
            
            if (selectedNtrvlView.isSelected == NO) {

                [self deselectOtherSelectedCustomNtrvlViews];
                [self.contentView bringSubviewToFront: gestureRecongnizer.view];
                [self selectNtrvlView: selectedNtrvlView];
            }
            
            else {
                [self deselectNtrvlView: selectedNtrvlView];
            
                NSLog(@"position in workout: %lld", selectedNtrvlView.positionInWorkout);
                
                [self copyInfoToNtrvlModelFromCustomNtrvlView:selectedNtrvlView];
            }
        }
    }
}


- (void)stravaAccessAllowed {
    
    NSLog(@"Strava Access allowed");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    
    // TODO: build variables for name, type, date, time, elapsed time, and description.
    [[NtrvlsDataStore sharedNtrvlsDataStore] workoutDescriptionStringForNtrvlWorkout: self.selectedWorkout withCompletionBlock:^(BOOL complete, NSString *workoutDescriptionString) {
    
        if (complete) {
            NSString *startDate = [self stringForCurrentTimeAndDateIOS8601Format];
            
            // TODO: Title and save wokout if posting to strava
            NSString *titleString = [NSString stringWithFormat:@"Ntrvls Workout - %@", self.workoutTitleLabel.text];
            NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname: escapedTitleString type: self.selectedWorkout.workoutType startDateLocal: startDate elapsedTime: self.selectedWorkout.totalTime description: workoutDescriptionString withCompletionBlock:^(BOOL success) {
        
                if (success){
                    
                    [self presentSuccessfulStravaUploadAlert];
                    
                    NSLog(@"Posted Ntrvls Workout!!!");
                }
                else {
                    NSLog(@"Posting failed :(");
                }
            }];
        }
    }];
}

- (void)stravaAccessDenied {
    
    NSLog(@"!!!!!!!!Strava Access Denied!!!!!!!!");
    [self presentNoInternetAlert];
    
//    UIAlertController *noInternetAlertController = [UIAlertController alertControllerWithTitle: @"Strava couldn't login" message: @"Maybe try again?" preferredStyle: UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        // TODO: Make sure this saves workout
//    }];
//    [noInternetAlertController addAction:okAction];
    
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
    
    selectedView.isSelected = YES;
    
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
    selectedView.selectColorButton.hidden = NO;
    
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
    
    deselectedView.isSelected = NO;
    
    self.screenColorOfDeselectedNtrvlView = deselectedView.screenColor;
    
    deselectedView.intervalDurationLabel.text = [deselectedView timeStringFromSecondsCount: [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue]];
    
    deselectedView.descriptionTextView.userInteractionEnabled = NO;
    deselectedView.minutesTextField.userInteractionEnabled = NO;
    deselectedView.secondsTextField.userInteractionEnabled = NO;
    
    deselectedView.intervalDurationLabel.hidden = NO;
    deselectedView.minutesTextField.hidden = YES;
    deselectedView.secondsTextField.hidden = YES;
    deselectedView.deleteButton.hidden = YES;
    deselectedView.selectColorButton.hidden = YES;
    
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget: self action:@selector(customNtrvlViewTappedFromGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.view.userInteractionEnabled = YES;
    
    [view addGestureRecognizer: tapGestureRecognizer];
}


- (void)deselectOtherSelectedCustomNtrvlViews {

    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass: [CustomNtrvlView class]]) {
            if (((CustomNtrvlView *)subview).isSelected) {
                [self copyInfoToNtrvlModelFromCustomNtrvlView:((CustomNtrvlView *)subview)];
                ((CustomNtrvlView *)subview).isSelected = NO;
                [self deselectNtrvlView: ((CustomNtrvlView *)subview)];
            }
        }
    }
}

- (void)deleteNrtvlView:(CustomNtrvlView *)deletedNtrvlView {
    
    for (CustomNtrvlView *ntrvlView in self.contentView.subviews) {
        
        if (ntrvlView.positionInWorkout > deletedNtrvlView.positionInWorkout) {
            [UIView animateWithDuration: 0.2 animations:^{
                ntrvlView.frame = CGRectMake(ntrvlView.frame.origin.x - deletedNtrvlView.frame.size.width, ntrvlView.frame.origin.y, ntrvlView.frame.size.width, ntrvlView.frame.size.height);
            }];
            ntrvlView.positionInWorkout --;
        }
    }
    [deletedNtrvlView removeFromSuperview];
    
    // contract contentView width
    self.contentViewWidth.constant =  self.contentViewWidth.constant - deletedNtrvlView.frame.size.width;

    [[NtrvlsDataStore sharedNtrvlsDataStore] deleteNtrvl: self.selectedWorkout.interval[deletedNtrvlView.positionInWorkout] fromNtrvlWorkout: self.selectedWorkout];
    
}


- (void)copyInfoToNtrvlModelFromCustomNtrvlView:(CustomNtrvlView *)customNtrvlView {
    
    if (![self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDescription isEqualToString:self.descriptionTextView.text]) {
        
        self.workoutWasEdited = YES;
        self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDescription = self.descriptionTextView.text;
    }
    
    if (self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDuration != [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue]) {

        self.workoutWasEdited = YES;
        self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDuration = [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue];
    }
    if (![self.selectedWorkout.interval[customNtrvlView.positionInWorkout].screenColor isEqualToString: self.screenColorOfDeselectedNtrvlView]) {
        
        NSLog(@"======================== Noticed a change in screen color ==========================");
        self.workoutWasEdited = YES;
        self.selectedWorkout.interval[customNtrvlView.positionInWorkout].screenColor = self.screenColorOfDeselectedNtrvlView;
    }

    NSLog(@"self.workoutWasEdited: %d", self.workoutWasEdited);
    
    // log out interval descriptions because debugger not po properties
//    for (Ntrvl *interval in self.selectedWorkout.interval) {
//        NSLog(@"postion in workout: %lld\ndescription: %@\nduration: %lld", interval.positionNumberInWorkout, interval.intervalDescription, interval.intervalDuration);
//    }
    
}

#pragma mark - String methods

- (NSString *)stringForCurrentTimeAndDateIOS8601Format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *now = [NSDate date];
    NSString *timeDateISO8601String = [dateFormatter stringFromDate:now];
    return timeDateISO8601String;
}


#pragma mark - Keychain test method

- (void)testKeychain:(NSString *)value forKey:(NSString *)key andAccessGroup:(NSString *)group {
    
    NSString *forGroupLog = (group ? [NSString stringWithFormat:@" for access group '%@'", group] : @"");
    
    if ([JNKeychainWrapper saveValue:value forKey:key forAccessGroup:group]) {
        NSLog(@"Correctly saved value '%@' for key '%@'%@", value, key, forGroupLog);
    }
    else {
        NSLog(@"Failed to save!%@", forGroupLog);
    }
    
    NSLog(@"Value for key '%@' is: '%@'%@", key, [JNKeychainWrapper loadValueForKey:key forAccessGroup:group], forGroupLog);
    
    if ([JNKeychainWrapper deleteValueForKey:key forAccessGroup:group]) {
        NSLog(@"Deleted value for key '%@'. Value is: '%@'%@", key, [JNKeychainWrapper loadValueForKey:key forAccessGroup:group], forGroupLog);
    }
    else {
        NSLog(@"Failed to delete!%@", forGroupLog);
    }
}


#pragma mark - Alert Controllers

- (void)showSaveAlert {
    
    [self deselectOtherSelectedCustomNtrvlViews];
    
    if (self.workoutWasEdited == YES) {
        UIAlertController *saveAlertController = [UIAlertController alertControllerWithTitle:@"Hey!" message:@"Do you want to save this workout?" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"YES tapped");
            [self showTextInputAlert];
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style: UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"NO tapped");
            
            [[NtrvlsDataStore sharedNtrvlsDataStore] deleteWorkoutWithTitle: @"RARCopy"];
            self.selectedWorkout = nil;
            
            [self.navigationController popViewControllerAnimated: YES];
        }];
        
        [saveAlertController addAction: noAction];
        [saveAlertController addAction: yesAction];
        [self presentViewController: saveAlertController animated: YES completion:^{
                 // anything?
        }];
    }
    else {
        [[NtrvlsDataStore sharedNtrvlsDataStore] deleteWorkoutWithTitle: @"RARCopy"];
        
        [self.navigationController popViewControllerAnimated: YES];
    }
}

-(void)showTextInputAlert {
    
    UIAlertController *textInputAlertController = [UIAlertController alertControllerWithTitle: @"Title your workout" message:@"" preferredStyle: UIAlertControllerStyleAlert];
    
    [textInputAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"workout title";
        self.alertTextField = textField;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"Ok tapped");
        if (![[NtrvlsDataStore sharedNtrvlsDataStore] alreadySavedWorkoutWithTitle: self.alertTextField.text]) {
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveNewWorkoutWithTitle: self.alertTextField.text];
            [self dismissViewControllerAnimated: NO completion: nil];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else {
            // TODO: display choice another title alert
            NSLog(@"Already saved that title");
            [self presentTitleAlreadySavedAlert];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // default behavior?
        NSLog(@"Cancel tapped");
    }];
    
    [textInputAlertController addAction: cancelAction];
    [textInputAlertController addAction: okAction];
    [self presentViewController: textInputAlertController animated: YES completion:^{
        // anything else?
    }];
}

- (void)presentTitleAlreadySavedAlert {
    
    UIAlertController *titleAlreadySaveAlertController = [UIAlertController alertControllerWithTitle: @"Title already saved" message: @"Choose a different title" preferredStyle: UIAlertControllerStyleAlert];
    [titleAlreadySaveAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"workout title";
        self.alertTextField = textField;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"Ok tapped");
        if (![[NtrvlsDataStore sharedNtrvlsDataStore] alreadySavedWorkoutWithTitle: self.alertTextField.text]) {
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveNewWorkoutWithTitle: self.alertTextField.text];
            [self dismissViewControllerAnimated: NO completion: nil];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else {
            // TODO: display choice another title alert
            NSLog(@"Already saved that title");
            [self presentTitleAlreadySavedAlert];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // default behavior?
        NSLog(@"Cancel tapped");
    }];
    
    [titleAlreadySaveAlertController addAction: cancelAction];
    [titleAlreadySaveAlertController addAction: okAction];
    [self presentViewController: titleAlreadySaveAlertController animated: YES completion:^{
        // anything else?
    }];
}

- (void)presentWorkoutTypeAlertController {
    
    // TODO: decide what to do with top right button type:
    UIAlertController *workoutTypeAlertController = [UIAlertController alertControllerWithTitle:@"Choose activity" message: nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *runAction = [UIAlertAction actionWithTitle:@"Run" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Run"]){
            self.workoutWasEdited = YES;
            self.navigationItem.rightBarButtonItem.title = @"Type:Run";
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Run" forNtrvlWorkout: self.selectedWorkout];
        }
        NSLog(@"%@", self.selectedWorkout.workoutType);
    }];
    
    UIAlertAction *rideAction = [UIAlertAction actionWithTitle:@"Ride" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Ride"]){
            self.workoutWasEdited = YES;
            self.navigationItem.rightBarButtonItem.title = @"Ride";
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Ride" forNtrvlWorkout: self.selectedWorkout];
        }
        NSLog(@"%@", self.selectedWorkout.workoutType);
    }];
    UIAlertAction *rowAction = [UIAlertAction actionWithTitle:@"Row" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Row"]){
            self.workoutWasEdited = YES;
            self.navigationItem.rightBarButtonItem.title = @"Row";
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Row" forNtrvlWorkout: self.selectedWorkout];
        }
        NSLog(@"%@", self.selectedWorkout.workoutType);
    }];
    UIAlertAction *walkAction = [UIAlertAction actionWithTitle:@"Walk" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        if (![self.selectedWorkout.workoutType isEqualToString:@"Walk"]){
            self.workoutWasEdited = YES;
            self.navigationItem.rightBarButtonItem.title = @"Walk";
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Walk" forNtrvlWorkout: self.selectedWorkout];
        }
        NSLog(@"%@", self.selectedWorkout.workoutType);
    }];
    UIAlertAction *swimAction = [UIAlertAction actionWithTitle:@"Swim" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Swim"]){
            self.workoutWasEdited = YES;
            self.navigationItem.rightBarButtonItem.title = @"Swim";
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Swim" forNtrvlWorkout: self.selectedWorkout];
        }
        NSLog(@"%@", self.selectedWorkout.workoutType);
    }];
    
    [workoutTypeAlertController addAction: runAction];
    [workoutTypeAlertController addAction: rideAction];
    [workoutTypeAlertController addAction: rowAction];
    [workoutTypeAlertController addAction: walkAction];
    [workoutTypeAlertController addAction: swimAction];
    
    [self presentViewController: workoutTypeAlertController animated: YES completion:nil];
}

- (void)presentNoInternetAlert {
    UIAlertController *noInternetAlertController = [UIAlertController alertControllerWithTitle: @"The internet can not be reached" message: @"Save workout and upload when connection is better" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *acceptDefeatAction = [UIAlertAction actionWithTitle:@"Accept your defeat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // anything else?
    }];
    
    [noInternetAlertController addAction: acceptDefeatAction];
    [self presentViewController: noInternetAlertController animated: NO completion:^{
        // TODO: What now that internet is unavailable
    }];
    
}

- (void)presentSuccessfulStravaUploadAlert {
    // TODO: add successful activity post alert!
    UIAlertController *successfulStravaPostAlertController = [UIAlertController alertControllerWithTitle:@"Success!" message: @"Workout posted to Strava" preferredStyle: UIAlertControllerStyleAlert];
    
    [self presentViewController: successfulStravaPostAlertController animated: YES completion:^{
        
        // delay one second then dismiss success alert
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated: YES completion: nil];
        });
    }];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"TimerPlaySegue"]) {
        
        TimerPlayVC *destinationVC = segue.destinationViewController;
        destinationVC.selectedWorkout = self.selectedWorkout;
        
        // since editing a copy of workout, pass forward current title
        destinationVC.workoutTitle = self.workoutTitleLabel.text;
    }
}

@end
