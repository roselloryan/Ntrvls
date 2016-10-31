
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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending: NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    self.workoutsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (self.workoutsArray == nil) {
        
        // Handle the error.
        NSLog(@"Error in fetch request: %@ \n%@ \n %@", error, error.description, error.localizedDescription);
    }
    else {
        // NSLog(@"workouts fetched");
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
    
    NtrvlWorkout *newWorkout = [NSEntityDescription insertNewObjectForEntityForName: @"NtrvlWorkout" inManagedObjectContext: sharedDataStore.managedObjectContext];
    newWorkout.workoutTitle = kWorkoutCopyName;
    newWorkout.creationDate = [NSDate timeIntervalSinceReferenceDate];
    newWorkout.workoutType = ntrvlWorkout.workoutType;
    newWorkout.totalTime = ntrvlWorkout.totalTime;
    
    
    for (NSUInteger i = 0; i < ntrvlWorkout.interval.count; i++) {
        
        Ntrvl *newNtrvl = [NSEntityDescription insertNewObjectForEntityForName: @"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
        newNtrvl.intervalDuration = ntrvlWorkout.interval[i].intervalDuration;
        newNtrvl.screenColor = ntrvlWorkout.interval[i].screenColor;
        newNtrvl.intervalDescription = ntrvlWorkout.interval[i].intervalDescription;
        newNtrvl.workout = newWorkout;
        newNtrvl.positionNumberInWorkout = i;
    }
    [sharedDataStore saveContext];
    return newWorkout;
}

- (void)saveCopyAsNewWorkoutWithTitle:(NSString *)workoutTitle {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NSFetchRequest *copyFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = kWorkoutCopyName;
    copyFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: copyFetch error: &error];

    if (!fetchArray) {
        // Handle the error.
        NSLog(@"Error in fetch request: %@ \n%@ \n %@", error, error.description, error.localizedDescription);
    }
    else {
        NtrvlWorkout *copyWorkout = fetchArray[0];
        copyWorkout.workoutTitle = workoutTitle;
        copyWorkout.totalTime = [self totalTimeForWorkout: copyWorkout];

        [sharedDataStore saveContext];
        [sharedDataStore fetchWorkouts];
    }
}

- (void)deleteWorkoutWithTitle:(NSString *)title {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NSFetchRequest *workoutTitleFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    workoutTitleFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", title];
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: workoutTitleFetch error: &error];
    
    if (fetchArray) {
        // NSLog(@"fetchArray: %@", fetchArray);
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

- (void)overwriteWorkoutWithTitle:(NSString *)title {
    [self deleteWorkoutWithTitle: title];
    [self saveCopyAsNewWorkoutWithTitle: title];
    
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

    NSFetchRequest *workoutFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = ntrvlWorkout.workoutTitle;
    workoutFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: workoutFetch error: &error];
    
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
    
    // -1   adds the new interval to end of workout, but before the last cool down interval
    newNtrvl.positionNumberInWorkout = ntrvlWorkout.interval.count - 1;
    
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

    NSFetchRequest *workoutFetch = [NSFetchRequest fetchRequestWithEntityName: @"NtrvlWorkout"];
    NSString *copyString = ntrvlWorkout.workoutTitle;
    workoutFetch.predicate = [NSPredicate predicateWithFormat: @"workoutTitle == %@", copyString];
    NSError *error;
    NSArray *fetchArray = [sharedDataStore.managedObjectContext executeFetchRequest: workoutFetch error: &error];
    
    if (fetchArray) {
        
        NtrvlWorkout *workoutToEdit = fetchArray[0];
        
        for (Ntrvl *interval in workoutToEdit.interval) {
            
            if (interval.positionNumberInWorkout == ntrvl.positionNumberInWorkout) {
                [sharedDataStore.managedObjectContext deleteObject: interval];
                
            }
            else if (interval.positionNumberInWorkout > ntrvl.positionNumberInWorkout) {
                NSLog(@"interval.positionNumberInWorkout: %lld", interval.positionNumberInWorkout);
                interval.positionNumberInWorkout --;
            }
        }
    }
    else {
        NSLog(@"FETCH ERROR ?????????????????????????????????????????????");
    }
    [sharedDataStore saveContext];
    [sharedDataStore fetchWorkouts];
}


- (void)workoutDescriptionStringForNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout withCompletionBlock:(void(^)(BOOL complete, NSString *workoutDescriptionString))completionBlock {
    
    NSMutableString *workoutDescriptionString = [[NSMutableString alloc]init];
    
    for (Ntrvl *interval in ntrvlWorkout.interval) {
        
        if (interval == ntrvlWorkout.interval.firstObject || interval == ntrvlWorkout.interval.lastObject) {
            // skip warm up and cool down intervals
        }
        else {
            NSString *individualIntervalString = [NSString stringWithFormat: @"%@ for %@\n", interval.intervalDescription, [self timeStringFromSecondsCount:interval.intervalDuration]];
            NSString *escapedIndividualIntervalString = [individualIntervalString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
        
            [workoutDescriptionString appendString: escapedIndividualIntervalString];
        }
    }
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
            getReadyInterval.screenColor = @"grey";
            getReadyInterval.intervalDescription = @"Get Ready";
            getReadyInterval.workout = tabata;
            getReadyInterval.positionNumberInWorkout = i;
        }
        else if (i == 9) {
            Ntrvl *coolDownInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            coolDownInterval.intervalDuration = 120;
            coolDownInterval.screenColor = @"grey";
            coolDownInterval.intervalDescription = @"Cool Down";
            coolDownInterval.workout = tabata;
            coolDownInterval.positionNumberInWorkout = i;
        }
        else if (i % 2 != 0) {
            Ntrvl *firstInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            firstInterval.intervalDuration = 20;
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
    [sharedDataStore saveContext];
    
    completionBlock(YES);
}

- (void)createNewWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NtrvlWorkout *newWorkout = [NSEntityDescription insertNewObjectForEntityForName:@"NtrvlWorkout" inManagedObjectContext: sharedDataStore.managedObjectContext];
    newWorkout.workoutTitle = @"New Workout";
    newWorkout.creationDate = [NSDate timeIntervalSinceReferenceDate];
    
    for (NSUInteger i = 0; i < 2; i++) {
        
        if (i == 0) {
            Ntrvl *getReadyInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            getReadyInterval.intervalDuration = 10;
            getReadyInterval.screenColor = @"grey";
            getReadyInterval.intervalDescription = @"Get Ready";
            getReadyInterval.workout = newWorkout;
            getReadyInterval.positionNumberInWorkout = i;
        }
        else if (i == 1) {
            Ntrvl *coolDownInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            coolDownInterval.intervalDuration = 120;
            coolDownInterval.screenColor = @"grey";
            coolDownInterval.intervalDescription = @"Cool Down";
            coolDownInterval.workout = newWorkout;
            coolDownInterval.positionNumberInWorkout = i;
        }
    }
    newWorkout.totalTime = [self totalTimeForWorkout: newWorkout];
    [sharedDataStore saveContext];
    
    completionBlock(YES);
}

- (void)createOverUndersWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NtrvlWorkout *overUndersWorkout = [NSEntityDescription insertNewObjectForEntityForName:@"NtrvlWorkout" inManagedObjectContext: sharedDataStore.managedObjectContext];
    overUndersWorkout.workoutTitle = @"Over/Unders";
    overUndersWorkout.creationDate = [NSDate timeIntervalSinceReferenceDate];
    
    for (NSUInteger i = 0; i < 21; i++) {
        
        if (i == 0) {
            Ntrvl *getReadyInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            getReadyInterval.intervalDuration = 10;
            getReadyInterval.screenColor = @"grey";
            getReadyInterval.intervalDescription = @"Get Ready";
            getReadyInterval.workout = overUndersWorkout;
            getReadyInterval.positionNumberInWorkout = i;
        }
        else if (i == 5 || i == 10 || i == 15 || i == 20) {
            Ntrvl *overInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            overInterval.intervalDuration = 5 * 60;
            overInterval.screenColor = @"blue";
            overInterval.intervalDescription = @"Long Break";
            overInterval.workout = overUndersWorkout;
            overInterval.positionNumberInWorkout = i;
        }
        else if (i == 20) {
            Ntrvl *coolDownInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            coolDownInterval.intervalDuration = 120;
            coolDownInterval.screenColor = @"grey";
            coolDownInterval.intervalDescription = @"Cool Down";
            coolDownInterval.workout = overUndersWorkout;
            coolDownInterval.positionNumberInWorkout = i;
        }
        else if (i == 1 || i == 3 || i == 6 || i == 8 || i == 11 || i == 13 || i == 16 || i == 18) {
            Ntrvl *underInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            underInterval.intervalDuration = 4 * 60;
            underInterval.screenColor = @"green";
            underInterval.intervalDescription = @"Under";
            underInterval.workout = overUndersWorkout;
            underInterval.positionNumberInWorkout = i;
        }
        else {
            Ntrvl *overInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            overInterval.intervalDuration = 60;
            overInterval.screenColor = @"orange";
            overInterval.intervalDescription = @"Over";
            overInterval.workout = overUndersWorkout;
            overInterval.positionNumberInWorkout = i;
        }
 
    }
    overUndersWorkout.totalTime = [self totalTimeForWorkout: overUndersWorkout];
    [sharedDataStore saveContext];
    
    completionBlock(YES);
}

- (void)createDemoWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock {
    
    NtrvlsDataStore *sharedDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    NtrvlWorkout *demoWorkout = [NSEntityDescription insertNewObjectForEntityForName:@"NtrvlWorkout" inManagedObjectContext: sharedDataStore.managedObjectContext];
    demoWorkout.workoutTitle = @"Ntrvls Demo";
    demoWorkout.creationDate = [NSDate timeIntervalSinceReferenceDate];
    
    for (NSUInteger i = 0; i < 2; i++) {
        
        if (i == 0) {
            Ntrvl *getReadyInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            getReadyInterval.intervalDuration = 5;
            getReadyInterval.screenColor = @"grey";
            getReadyInterval.intervalDescription = @"Get Ready";
            getReadyInterval.workout = demoWorkout;
            getReadyInterval.positionNumberInWorkout = i;
        }
        else if (i == 1) {
            Ntrvl *coolDownInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: sharedDataStore.managedObjectContext];
            coolDownInterval.intervalDuration = 5;
            coolDownInterval.screenColor = @"grey";
            coolDownInterval.intervalDescription = @"Cool Down";
            coolDownInterval.workout = demoWorkout;
            coolDownInterval.positionNumberInWorkout = i;
        }
    }
    demoWorkout.totalTime = [self totalTimeForWorkout: demoWorkout];
    [sharedDataStore saveContext];
    
    completionBlock(YES);
}

#pragma mark - Total time calculation method

- (NSInteger)totalTimeForWorkout:(NtrvlWorkout *)ntrvlWorkout {
    // skip 10 second pepare interval
    NSInteger timeSum = 0;
    for (NSUInteger i = 1; i < ntrvlWorkout.interval.count; i++) {
        timeSum += ntrvlWorkout.interval[i].intervalDuration;
    }
    return timeSum;
}

# pragma mark - String method


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
    
    if (minutes < 10) {
        minutesString = [NSString stringWithFormat: @"0%lu", minutes];
    }
    else {
        minutesString = [NSString stringWithFormat: @"%lu", minutes];
    }
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat: @"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat: @"%lu", seconds];
    }
    
    NSString *timeString = [[NSString alloc]init];
    if (hours == 0) {
        timeString = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    }
    else {
        timeString = [NSString stringWithFormat: @"%@:%@:%@", hoursString, minutesString, secondsString];
    }
    
    return timeString;
}

@end
