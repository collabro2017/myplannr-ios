//
//  MYPDocumentCell.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/10/2016.
//
//

#import "MYPDocumentCell.h"
#import "MYPConstants.h"

static CGFloat const kCornerRadius = 2.0f;

@implementation MYPDocumentCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.editing = NO; // disabled by default
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = kCornerRadius;
    self.contentView.layer.borderColor = [UIColor myp_colorWithHexInt:kCardBorderColor].CGColor;
    self.contentView.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected {
    if (self.editing) {
        [super setSelected:selected];
        self.checkbox.checked = selected;
    } else {
        [super setSelected:NO];
    }
}

#pragma mark - Public methods & properties

- (void)setEditing:(BOOL)editing {
    [super setEditing:editing];
    
    self.editingModeView.hidden = !editing;
    self.checkbox.hidden = !editing;
    
    if (!editing) {
        self.checkbox.checked = NO;
    }
}

@end
