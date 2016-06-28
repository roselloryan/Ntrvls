//
//  TimerPrepVC.m
//  Ntrvls


#import "TimerPrepVC.h"
#import "TimerPlayVC.h"


@interface TimerPrepVC ()

@property (weak, nonatomic) IBOutlet UILabel *workoutTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation TimerPrepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workoutTitleLabel.text = self.workoutTitle;
    
    // Do You want the nav bar controls or custom button layout
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO];
    
}


- (IBAction)startButtonTapped:(UIButton *)sender {
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"TimerPlaySegue"]) {
        NSLog(@"Segueing to player VC!");
        
        TimerPlayVC *destinationVC = segue.destinationViewController;
        destinationVC.workoutTitle = self.workoutTitle;
    }
}


@end
