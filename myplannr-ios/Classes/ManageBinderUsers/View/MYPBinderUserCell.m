//
//  MYPBinderUserCell.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 07/10/2016.
//
//

#import "MYPBinderUserCell.h"
#import "MYPConstants.h"

static CGFloat const kChecboxLeadingMargin = 16.0f;

@implementation MYPBinderUserCell

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.contentCardView layoutIfNeeded];
    if (editing) {
        self.checkboxWidthConstraint.constant = kCheckbkoxViewSize;
        self.checkboxLeadingConstraint.constant = kChecboxLeadingMargin;
    } else {
        self.checkboxWidthConstraint.constant = 0.0f;
        self.checkboxLeadingConstraint.constant = 0.0f;
        
        // Reset checkbox
        self.checkbox.checked = NO;
    }

    [UIView animateWithDuration:0.25f animations:^{
        [self.contentCardView layoutIfNeeded];
    }];
}

#pragma mark - Public Methods & Properties

- (BOOL)isChecked {
    if (!self.isEditing) {
        return NO;
    }
    
    return self.checkbox.isChecked;
}

- (UIView *)cardView {
    return self.contentCardView;
}

- (void)handleCardViewTapGesture {
    [super handleCardViewTapGesture];
    
    if (!self.isEditing) {
        return;
    }
    
    BOOL checked = self.checkbox.isChecked;
    self.checkbox.checked = !checked;
    
    if ([self.checkedStateDelegate respondsToSelector:@selector(binderUserCell:didChangeCheckedState:)]) {
        [self.checkedStateDelegate binderUserCell:self
                            didChangeCheckedState:!checked];
    }
}

@end
