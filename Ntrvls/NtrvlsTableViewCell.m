
#import "NtrvlsTableViewCell.h"

@implementation NtrvlsTableViewCell


-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
