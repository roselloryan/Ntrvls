//
//  NtrvlsDataStore.h
//  Ntrvls


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NtrvlsDataStore : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *workoutsArray;

+ (instancetype)sharedNtrvlsDataStore;

- (void)saveContext;

- (void)fetchWorkouts;

@end
