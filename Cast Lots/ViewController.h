//
//  ViewController.h
//  Cast Lots
//
//  Created by Andy Uyeda on 6/13/17.
//  Copyright © 2017 Andy Uyeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)added:(id)sender;
- (IBAction)removed:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)trash:(id)sender;
- (IBAction)compose:(id)sender;

@end

