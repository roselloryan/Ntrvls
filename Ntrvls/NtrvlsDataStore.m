//
//  NtrvlsDataStore.m
//  Ntrvls


#import "NtrvlsDataStore.h"

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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"workoutTitle" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    self.workoutsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (self.workoutsArray == nil) {
        
        // Handle the error.
        NSLog(@"Error in fetch request: %@ \n%@ \n %@", error, error.description, error.localizedDescription);
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

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


//-(instancetype)init
//{
//    self = [super init];
//    if(self) {
//        [self fetchShoppingCartItems];
//    }
//    
//    return self;
//}
//
//-(void)fetchShoppingCartItems
//{
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ShoppingCartItem"];
//    self.shoppingCartItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//}

@end
