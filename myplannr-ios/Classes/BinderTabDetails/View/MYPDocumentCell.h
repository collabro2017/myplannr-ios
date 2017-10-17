//
//  MYPDocumentCell.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPEditableCollectionViewCell.h"
#import "MYPCheckbox.h"

@interface MYPDocumentCell : MYPEditableCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *editingModeView;
@property (weak, nonatomic) IBOutlet MYPCheckbox *checkbox;

@end
