
#import "NtrvlsDataStore.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlWorkout+CoreDataProperties.h"
#import "Ntrvl+CoreDataProperties.h"

@implementation NtrvlsDataStore


+ (instancetype)sharedNtrvlsDataStore {
    static NtrvlsDataStore *_sharedNtrvlsDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedNtrvlsDataStore = [[NtrvlsDataStore alloc] init];
    });
    
    return _sharedNtrvlsDataStore;
}


# pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NtrvlModel.sqlite"];
    
    NSError *error = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NtrvlModel" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    if (coordinator != nil) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}


-(void)fetchWorkouts {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"NtrvlWorkout"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"workoutTitle" ascending: NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    self.workoutsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (self.workoutsArray == nil) {
        
        // Handle the error.
        NSLog(@"Error in fetch request: %@ \n%@ \n %@", error, error.description, error.localizedDescription);
    }
    else {
        NSLog(@"workouts fetched");
    }
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            // If this happens, we're pretty screwed. We don't have any model validations, so this means something is totally bonkers.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(instancetype)init
{
    self = [super init];
    if(self) {
        [self fetchWorkouts];
    }
    
    return self;
}

- (NtrvlWorkout *)copyNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NtrvlWorkout *newWorkout = [NSEntityDescription insertNewObjectForEntityForName:@"NtrvlWorkout" inManagedObjectContext: sharedDataStore.managedObjectContext];
    newWorkout.workoutTitle = @"RARCopy";
    newWorkout.creationDate = [NSDate timeIntervalSinceReferenceDate];
    newWorkout.workoutType = ntrvlWorkout.workoutType;
    newWorkout.totalTime = ntrvlWorkout.totalTime;
    
    
    for (NSUInteger i = 0; i < ntrvlWorkout.interval.count; i++) {
        
        Ntrvl *newNtrvl = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
        newNtrvl.intervalDuration = ntrvlWorkout.interval[i].intervalDuration;
        newNtrvl.screenColor = ntrvlWorkout.interval[i].screenColor;
        newNtrvl.intervalDescription = ntrvlWorkout.interval[i].intervalDescription;
        newNtrvl.workout = newWorkout;
        newNtrvl.positionNumberInWorkout = i;
    }
    [sharedDataStore saveContext];

    NSLog(@"Copied a workout");
    
    return newWorkout;
}

- (void)saveNewWorkoutWithTitle:(NSString *)workoutTitle {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NSFetchRequest *copyFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = @"RARCopy";
    copyFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: copyFetch error: &error];

    if (!fetchArray) {
        // Handle the error.
        NSLog(@"Error in fetch request: %@ \n%@ \n %@", error, error.description, error.localizedDescription);
    }
    else {
        NSLog(@"workouts fetched: %@", fetchArray);
        
        NtrvlWorkout *copyWorkout = fetchArray[0];
        copyWorkout.workoutTitle = workoutTitle;
        copyWorkout.totalTime = [self totalTimeForWorkout: copyWorkout];

        [sharedDataStore saveContext];
        [sharedDataStore fetchWorkouts];
    }
}

- (void)deleteWorkoutWithTitle:(NSString *)title {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NSFetchRequest *RARCopyFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = @"RARCopy";
    RARCopyFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: RARCopyFetch error: &error];
    
    if (fetchArray) {
        for (NSManagedObject *ntrvlWorkout in fetchArray) {
            [sharedDataStore.managedObjectContext deleteObject: ntrvlWorkout];
        }
    }
    else {
        NSLog(@"Fetch error: %@\n%@", error, error.localizedDescription);
    }
    
    [sharedDataStore saveContext];
    [sharedDataStore fetchWorkouts];
}

- (BOOL)alreadySavedWorkoutWithTitle:(NSString *)title {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NSFetchRequest *alreadySavedFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    alreadySavedFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", title];
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: alreadySavedFetch error: nil];
    
    if (fetchArray.count > 0) {
        return YES;
    }
    else {
        return NO;
    }
}


- (void)saveWorkoutType:(NSString *)workoutType forNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NSFetchRequest *RARCopyFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = @"RARCopy";
    RARCopyFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: RARCopyFetch error: &error];
    
    if (fetchArray) {
        NtrvlWorkout *fetchedWorkout = fetchArray[0];
        fetchedWorkout.workoutType = workoutType;
    }
    else {
        NSLog(@"Fetch error: %@\n%@", error, error.localizedDescription);
    }
    
    [sharedDataStore saveContext];
    [sharedDataStore fetchWorkouts];
}


- (void)addNewNtrvlToWorkout:(NtrvlWorkout *)ntrvlWorkout {
   
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    Ntrvl *newNtrvl = [NSEntityDescription insertNewObjectForEntityForName: @"Ntrvl" inManagedObjectContext:sharedDataStore.managedObjectContext];
    
    // -2 adds the new interval to end of workout, but before the last cool down interval
    newNtrvl.positionNumberInWorkout = ntrvlWorkout.interval.count - 2;
    
    //change postition number of cooldown interval
    Ntrvl *cooldownNtrvl = [ntrvlWorkout.interval lastObject];
    cooldownNtrvl.positionNumberInWorkout ++;
    
    // insert Ntrvl object at index in workout
    [ntrvlWorkout insertObject:newNtrvl inIntervalAtIndex:ntrvlWorkout.interval.count - 1];
    
    [sharedDataStore saveContext];
    [sharedDataStore fetchWorkouts];
}

- (void)deleteNtrvl:(Ntrvl *)ntrvl fromNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout {

    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];

    NSFetchRequest *RARCopyFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = @"RARCopy";
    RARCopyFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: RARCopyFetch error: &error];
    
    if (fetchArray) {
        
        NtrvlWorkout *workoutToEdit = fetchArray[0];
        
        for (Ntrvl *interval in workoutToEdit.interval) {
            
            NSLog(@"interval.positionNumberInWorkout: %lld\nntrvl.positionNumberInWorkout: %lld", interval.positionNumberInWorkout, ntrvl.positionNumberInWorkout);
            
            if (interval.positionNumberInWorkout == ntrvl.positionNumberInWorkout) {
                [sharedDataStore.managedObjectContext deleteObject: interval];
                
            }
            else if (interval.positionNumberInWorkout > ntrvl.positionNumberInWorkout) {
                interval.positionNumberInWorkout --;
            }
        }
    }
    else {
        NSLog(@"FETCH ERROR ???????????????????????????????????????????????");
    }
    [sharedDataStore saveContext];
    [sharedDataStore fetchWorkouts];
}


- (void)workoutDescriptionStringForNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout withCompletionBlock:(void(^)(BOOL complete, NSString *workoutDescriptionString))completionBlock {
    
    NSMutableString *workoutDescriptionString = [[NSMutableString alloc]init];
    
    for (Ntrvl *interval in ntrvlWorkout.interval) {
        
        // TODO: Clean this up
        if (interval == ntrvlWorkout.interval.firstObject || interval == ntrvlWorkout.interval.lastObject) {
//            // skip warm up and cool down intervals
//            NSString *titleString = [NSString stringWithFormat: @"Ntrvls Workout: %@\n", ntrvlWorkout.workoutTitle];
//            
//            NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
//            [workoutDescriptionString appendString: escapedTitleString];
        }
        
        else {
            NSString *individualIntervalString = [NSString stringWithFormat: @"%@ for %@\n", interval.intervalDescription, [self timeStringFromSecondsCount:interval.intervalDuration]];
            NSString *escapedIndividualIntervalString = [individualIntervalString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
        
            [workoutDescriptionString appendString: escapedIndividualIntervalString];
        }
    }
    
    NSLog(@"%@", workoutDescriptionString);
    completionBlock(YES, workoutDescriptionString);
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}


#pragma mark - preset workouts creation methods

- (void)createTabataWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NtrvlWorkout *tabata = [NSEntityDescription insertNewObjectForEntityForName:@"NtrvlWorkout" inManagedObjectContext: sharedDataStore.managedObjectContext];
    tabata.workoutTitle = @"TABATA";
    tabata.creationDate = [NSDate timeIntervalSinceReferenceDate];
    
    for (NSUInteger i = 0; i < 10; i++) {
            
        if (i == 0) {
            Ntrvl *getReadyInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            getReadyInterval.intervalDuration = 10;
            getReadyInterval.screenColor = @"yellow";
            getReadyInterval.intervalDescription = @"Get ready to start";
            getReadyInterval.workout = tabata;
            getReadyInterval.positionNumberInWorkout = i;
        }
        else if (i == 5) {
            Ntrvl *longBreakInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            longBreakInterval.intervalDuration = 10;
            longBreakInterval.screenColor = @"grey";
            longBreakInterval.intervalDescription = @"2 minute recovery";
            longBreakInterval.workout = tabata;
            longBreakInterval.positionNumberInWorkout = i;
        }
        else if (i == 9) {
            Ntrvl *recoverInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            recoverInterval.intervalDuration = 120;
            recoverInterval.screenColor = @"grey";
            recoverInterval.intervalDescription = @"Post-Workout cool down";
            recoverInterval.workout = tabata;
            recoverInterval.positionNumberInWorkout = i;
        }
        else if (i % 2 != 0) {
            Ntrvl *firstInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            firstInterval.intervalDuration = 15;
            firstInterval.screenColor = @"red";
            firstInterval.intervalDescription = @"Full Speed!";
            firstInterval.workout = tabata;
            firstInterval.positionNumberInWorkout = i;
        }
        else {
            Ntrvl *secondInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            secondInterval.intervalDuration = 10;
            secondInterval.screenColor = @"blue";
            secondInterval.intervalDescription = @"Complete rest";
            secondInterval.workout = tabata;
            secondInterval.positionNumberInWorkout = i;
        }
    }
    tabata.totalTime = [self totalTimeForWorkout: tabata];
    NSLog(@"In Data Store. Created TABATA: %@", tabata.interval);
        
    [sharedDataStore saveContext];
    
    completionBlock(YES);
}

         
# pragma mark - String method

- (NSInteger)totalTimeForWorkout:(NtrvlWorkout *)ntrvlWorkout {
    
    NSInteger timeSum = 0;
    for (Ntrvl *interval in ntrvlWorkout.interval) {
        timeSum += interval.intervalDuration;
    }
    return timeSum;
}

         
- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
    
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount > 60) {
        minutes = secondsCount / 60;
        seconds = secondsCount % 60;
    }
    else {
        seconds = secondsCount;
    }
    
    NSString *minutesString =  [NSString stringWithFormat: @"%lu", minutes];
    NSString *secondsString = @"";
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat: @"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat: @"%lu", seconds];
    }
    
    NSString *timeString = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    
    return timeString;
}

@end
