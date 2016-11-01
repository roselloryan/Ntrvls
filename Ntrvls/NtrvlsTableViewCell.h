
#import <UIKit/UIKit.h>

@interface NtrvlsTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *detailLabel;


-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder;

@end
