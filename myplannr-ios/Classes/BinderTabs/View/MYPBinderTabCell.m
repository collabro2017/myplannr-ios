//
//  MYPBinderTabCell.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/10/2016.
//
//

#import "MYPBinderTabCell.h"

static CGFloat const kChecboxLeadingMargin = 16.0f;

@implementation MYPBinderTabCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor myp_colorWithHexInt:0xF1F1F1];
    
    self.cardView.clipsToBounds = NO;
    
    NSArray *existingButtons = self.rightUtilityButtons;
    NSMutableArray *rightButtons = [NSMutableArray arrayWithCapacity:existingButtons.count + 1];
    [rightButtons sw_addUtilityButtonWithColor:[UIColor myp_colorWithHexInt:(int)kUtilityButtonColor]
                                          icon:[UIImage imageNamed:@"EditCellButton"]];
    [rightButtons addObjectsFromArray:existingButtons];
    [self setRightUtilityButtons:rightButtons WithButtonWidth:kUtilityButtonWidth];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.contentCardView layoutIfNeeded];
    if (editing) {
        self.checkboxWidthConstraint.constant = kCheckbkoxViewSize;
        self.checkboxLeadingMarginConstraint.constant = kChecboxLeadingMargin;
    } else {
        self.checkboxWidthConstraint.constant = 0.0f;
        self.checkboxLeadingMarginConstraint.constant = 0.0f;
        
        // Reset checkbox
        self.checkbox.checked = NO;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.contentCardView layoutIfNeeded];
    }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (self.isEditing) {
        return;
    }
    
    UIColor *color = highlighted
        ? [UIColor myp_colorWithHexInt:(int)kHighlightedColorHex]
        : [UIColor whiteColor];
    self.contentCardView.backgroundColor = color;
}

#pragma mark - Public methods & Properties

- (UIView *)cardView {
    return self.contentCardView;
}

#pragma mark - Action Handlers

- (void)handleCardViewTapGesture {
    [super handleCardViewTapGesture];
    
    if (!self.isEditing) {
        BOOL isTapSupported = [self.binderTabDelegate respondsToSelector:@selector(binderTabCellDidTapCard:)];
        if (isTapSupported) {
            [self.binderTabDelegate binderTabCellDidTapCard:self];
        }
        return;
    }
    
    BOOL checked = self.checkbox.isChecked;
    self.checkbox.checked = !checked;
    
    if ([self.binderTabDelegate respondsToSelector:@selector(binderTabCell:didChangeCheckedState:)]) {
        [self.binderTabDelegate binderTabCell:self
                           didChangeCheckedState:!checked];
    }
}

@end
