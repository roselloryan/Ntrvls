//
//  NtrvlsMainViewController.m
//  Ntrvls


#import "NtrvlsMainViewController.h"
#import "TimerPrepVC.h"

CGFloat const iPhone4sHeight = 480.0f;
static CGFloat const topConstraintConstantFor4s = 0.0f;
static CGFloat const bottomConstraintConstantFor4s = -20.0f;

@interface NtrvlsMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *workoutsArray;

@end


@implementation NtrvlsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    
    
    // adjust constraints for tiny 4s screen
    if (self.view.frame.size.height == iPhone4sHeight) {
        self.tableViewTopConstraint.constant = topConstraintConstantFor4s;
        self.tableViewBottomConstraint.constant = bottomConstraintConstantFor4s;
        // makes shorter row heights for 4s
        self.tableView.rowHeight = self.tableView.frame.size.height / 9;
    }
    else {
        self.tableView.rowHeight = self.tableView.frame.size.height / 8;
    }
    
    self.workoutsArray = @[@"TABATA Intervals", @"40 / 20's", @"50 / 50's", @"15 Second Sprints", @"Over/Unders"];

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.workoutsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workoutCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.workoutsArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"timerPrepSegue"]) {
        TimerPrepVC *destinationVC = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        destinationVC.workoutTitle = self.workoutsArray[selectedIndexPath.row];
    }
    
}


@end
