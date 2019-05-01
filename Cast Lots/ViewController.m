//
//  ViewController.m
//  Cast Lots
//
//  Created by Andy Uyeda on 6/13/17.
//  Copyright © 2017 Andy Uyeda. All rights reserved.
//

#import <Contacts/Contacts.h>
#import "ViewController.h"
#import "SWRevealViewController.h"
#import "MoreViewController.h"
#import "ToastView.h"
#import "Lists.h"


#define SCROLL_SIZE 10000000

@interface ViewController ()

@property (nonatomic,strong) NSMutableArray *groupOfContacts;

@end

@implementation ViewController

NSMutableArray *pickerViewArray;
NSMutableArray *recentTitleArray;
NSMutableArray *buttonArray;
NSMutableArray *fieldArray;
NSString *currentTitle;
NSString *optionToChange;
NSTimer *timer;
int buttonMode = 0;

@synthesize pickerView, addButton, removeButton, segmentControl, scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandlerMethod:)];
    tapRecognizer.numberOfTapsRequired = 5;
    [self.view addGestureRecognizer:tapRecognizer];
    self.view.tag=2;
    
    pickerViewArray = [NSMutableArray array];
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setNavigationBarHidden:FALSE];
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    _infoButton.target = self;
    _infoButton.action = @selector(shake);
    self.revealViewController.delegate = self;
    self.navigationController.navigationBar.topItem.title = @"Cast Lots";
    self.navigationController.navigationBar.topItem.leftBarButtonItem = _barButton;
    self.navigationController.navigationBar.topItem.rightBarButtonItem = _infoButton;
    [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
    
    timer = [NSTimer timerWithTimeInterval:0.5
                                    target:self
                                  selector:@selector(update:)
                                  userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)update: (NSTimer*) timer {
    if([currentTitle length] > 0){
        self.navigationController.navigationBar.topItem.title = currentTitle;
    }
    else{
        self.navigationController.navigationBar.topItem.title = @"Cast Lots";
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *key = [prefs objectForKey:@"load"];
    if([key length] > 0){
        currentTitle = key;
        
        recentTitleArray = [[prefs objectForKey:@"recentTitles"] mutableCopy];
        if(recentTitleArray == nil){
            recentTitleArray = [NSMutableArray array];
        }
        [recentTitleArray removeObject:currentTitle];
        [recentTitleArray insertObject:currentTitle atIndex:0];
        
        pickerViewArray = [[prefs objectForKey:key] mutableCopy];
        [pickerView reloadAllComponents];
        [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
        [self populateScrollView];
        [prefs setObject:@"" forKey:@"load"];
        [prefs setObject:recentTitleArray forKey:@"recentTitles"];
        [prefs synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerViewArray count] > 0)
    {
        return SCROLL_SIZE;
    }
    else{
        return 0;
    }
}
-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        [tView setFont:[UIFont fontWithName:@"Georgia" size:23.0]];
        tView.textAlignment = NSTextAlignmentCenter;
        tView.textColor = [UIColor whiteColor];
    }
    // Fill the label text here
    tView.text = [pickerViewArray objectAtIndex:row % [pickerViewArray count]];
    return tView;
}


- (IBAction)added:(id)sender {
    buttonMode = 0;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Option"
                                                    message:[NSString stringWithFormat:@""]
                                                   delegate:self cancelButtonTitle:@"Add"
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert show];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonMode == 0){
        if([[[alert textFieldAtIndex:0] text] length] > 0){
            [pickerViewArray addObject:[[alert textFieldAtIndex:0] text]];
            //[pickerViewArray insertObject:[[alert textFieldAtIndex:0] text] atIndex:0];
        }
        [pickerView reloadAllComponents];
        [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
        
        [self populateScrollView];
    }
    else if (buttonMode == 1){
        if([[[alert textFieldAtIndex:0] text] length] > 0){
            [pickerViewArray removeObject:[[alert textFieldAtIndex:0] text]];
        }
        [pickerView reloadAllComponents];
        [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
        
        [self populateScrollView];
    }
    else if (buttonMode == 2){
        if([[[alert textFieldAtIndex:0] text] length] > 0){
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            recentTitleArray = [[prefs objectForKey:@"recentTitles"] mutableCopy];
            if(recentTitleArray == nil){
                recentTitleArray = [NSMutableArray array];
            }
            [recentTitleArray insertObject:[[alert textFieldAtIndex:0] text] atIndex:0];
            currentTitle = [[alert textFieldAtIndex:0] text];
            
            for(int i = [recentTitleArray count] -1; i >= 1; i--){
                if([[recentTitleArray objectAtIndex:i] isEqualToString:[[alert textFieldAtIndex:0] text]]|| [[recentTitleArray objectAtIndex:i] length] <= 0){
                    [recentTitleArray removeObjectAtIndex:i];
                }
            }
            
            
            [prefs setObject:recentTitleArray forKey:@"recentTitles"];
            [prefs setObject:pickerViewArray forKey:[[alert textFieldAtIndex:0] text]];
            [prefs synchronize];
        }
    }
    else if (buttonMode == 3){
        if(![[[alert textFieldAtIndex:0] text] isEqualToString:optionToChange]){
            [pickerViewArray insertObject:[[alert textFieldAtIndex:0] text] atIndex:[pickerViewArray indexOfObject:optionToChange]];
            
            [pickerViewArray removeObject:optionToChange];
        }
        
        [pickerView reloadAllComponents];
        [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:pickerViewArray forKey:currentTitle];
        [prefs synchronize];
        
        [self populateScrollView];
    }
}

- (IBAction)removed:(id)sender {
    buttonMode = 1;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Option"
                                                    message:[NSString stringWithFormat:@""]
                                                   delegate:self cancelButtonTitle:@"Remove"
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert show];
    
}

- (IBAction)save:(id)sender {
    buttonMode = 2;
    if([pickerViewArray count] > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Set a Title"
                                                        message:[NSString stringWithFormat:@""]
                                                       delegate:self cancelButtonTitle:@"Set"
                                              otherButtonTitles:nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
        [alert show];
    }
}

- (IBAction)segmentChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [pickerView setHidden:FALSE];
        [scrollView setHidden:TRUE];
    }
    else if(selectedSegment == 1) {
        [pickerView setHidden:TRUE];
        [scrollView setHidden:FALSE];
        [self populateScrollView];
    }
    
}

- (IBAction)trash:(id)sender {
    
    if([currentTitle length] > 0){
        
        UIAlertController * alert=[UIAlertController
                                   
                                   alertControllerWithTitle:@"Delete" message:@"Do you want to delete?"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     
                                 }];
        UIAlertAction* delete = [UIAlertAction
                                 actionWithTitle:@"Delete"
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction * action)
                                 {
                                     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                     recentTitleArray = [[prefs objectForKey:@"recentTitles"] mutableCopy];
                                     [recentTitleArray removeObject:currentTitle];
                                     [prefs removeObjectForKey:currentTitle];
                                     [prefs setObject:recentTitleArray forKey:@"recentTitles"];
                                     [prefs synchronize];
                                     currentTitle = @"";
                                     
                                     [self clearView];
                                     [pickerViewArray removeAllObjects];
                                     pickerViewArray = [NSMutableArray array];
                                     
                                     [pickerView reloadAllComponents];
                                     
                                 }];
        
        [alert addAction:cancel];
        [alert addAction:delete];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)compose:(id)sender {
    currentTitle = @"";
    [self clearView];
    [pickerViewArray removeAllObjects];
    pickerViewArray = [NSMutableArray array];
    
    [pickerView reloadAllComponents];
}

- (void)getAllContacts
{
    if([CNContactStore class])
    {
        CNContactStore *addressBook = [[CNContactStore alloc] init];
        NSArray *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey];
        
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        
        [addressBook enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
            [self.groupOfContacts addObject:[NSString stringWithFormat:@"%@%@%@", [contact givenName],@" ",[contact familyName]]];
        }];
    }
}


- (void)clearView{
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [fieldArray removeAllObjects];
    [buttonArray removeAllObjects];
    
    buttonArray = [NSMutableArray array];
    fieldArray = [NSMutableArray array];
}

- (void)populateScrollView {
    [self clearView];
    NSLog(@"%@", pickerViewArray);
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, ([pickerViewArray count] * 50) + 60);
    
    for(int i = 0; i < [pickerViewArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button addTarget:self
                   action:@selector(buttonSelected:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[pickerViewArray objectAtIndex:i] forState:UIControlStateNormal];
        CGSize size = [[pickerViewArray objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Georgia" size:23.0]}];
        button.frame = CGRectMake(20, 50 * i, size.width, 30);
        [button.titleLabel setFont:[UIFont fontWithName:@"Georgia" size:23.0]];
        
        
        
        CGRect someRect = CGRectMake(scrollView.contentSize.width - 40, 50 * i, 30, 30);
        UITextField* textField = [[UITextField alloc] initWithFrame:someRect];
        textField.backgroundColor = UIColor.whiteColor;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setPlaceholder:@"1"];
        [textField setFont:[UIFont fontWithName:@"Georgia" size:23.0] ];
        textField.delegate = self;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = UITextAlignmentCenter;
        
        [fieldArray addObject:textField];
        [buttonArray addObject:button];
        
        [scrollView addSubview:textField];
        [scrollView addSubview:button];
    }
    
}

- (IBAction)buttonSelected:(id)sender{
    optionToChange = [pickerViewArray objectAtIndex:[sender tag]];
    buttonMode = 3;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:optionToChange
                                                    message:[NSString stringWithFormat:@"Edit Option"]
                                                   delegate:self cancelButtonTitle:@"Change"
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:optionToChange];
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert show];
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES ];
    for(int i = 0; i < [fieldArray count]; i++){
        UITextField *textField = [fieldArray objectAtIndex:i];
        if([textField.text intValue] > 5){
            textField.text = @"5";
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([pickerViewArray count] > 0 && UIEventSubtypeMotionShake && [pickerView isHidden]) {
        
        int randomNumber = arc4random()%1000 + ([pickerViewArray count] * 50);
        NSLog(@"%d", randomNumber);
        
        for(int i = 0; i < [fieldArray count]; i++){
            UITextField *textField = [fieldArray objectAtIndex:i];
            if([textField.text intValue] > 5){
                textField.text = @"5";
            }
        }
        
        int index = 0;
        int sum = 0;
        
        while (sum < randomNumber){
            if(index >= [fieldArray count]){
                index = 0;
            }
            UITextField *textField = [fieldArray objectAtIndex:index];
            sum += [textField.text intValue];
            if([textField.text intValue] == 0){
                sum++;
            }
            index++;
        }
        
        index--;
        
        buttonMode = 4;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[pickerViewArray objectAtIndex:index]
                                                        message:@""
                                                       delegate:self cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"%@", [pickerViewArray objectAtIndex:index]);
        
    }
}

- (void)shake
{
    if ([pickerViewArray count] > 0 && UIEventSubtypeMotionShake) {
        
        int randomNumber = arc4random()%1000 + ([pickerViewArray count] * 50);
        NSLog(@"%d", randomNumber);
        
        for(int i = 0; i < [fieldArray count]; i++){
            UITextField *textField = [fieldArray objectAtIndex:i];
            if([textField.text intValue] > 5){
                textField.text = @"5";
            }
        }
        
        int index = 0;
        int sum = 0;
        
        while (sum < randomNumber){
            if(index >= [fieldArray count]){
                index = 0;
            }
            UITextField *textField = [fieldArray objectAtIndex:index];
            sum += [textField.text intValue];
            if([textField.text intValue] == 0){
                sum++;
            }
            index++;
        }
        
        index--;
        
        buttonMode = 4;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[pickerViewArray objectAtIndex:index]
                                                        message:@""
                                                       delegate:self cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"%@", [pickerViewArray objectAtIndex:index]);
        
    }
    
}

-(void)gestureHandlerMethod:(UITapGestureRecognizer*)sender
{
    if(sender.view.tag==2) {
        UIAlertController * alert=[UIAlertController
                                   
                                   alertControllerWithTitle:@"Code" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* load = [UIAlertAction
                               actionWithTitle:@"Load List"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   NSScanner *scanner = [NSScanner scannerWithString:[[[alert textFields] objectAtIndex:0] text]];
                                   BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
                                   NSLog(@"%@", [[[alert textFields] objectAtIndex:0] text]);
                                   if([[[[alert textFields] objectAtIndex:0] text] isEqualToString:@"bElovEd"]){
                                       [pickerViewArray removeAllObjects];
                                       [pickerViewArray addObjectsFromArray:MEMBERS];
                                       
                                       [pickerView reloadAllComponents];
                                       [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
                                       [self populateScrollView];
                                   }
                                   
                                   else if([[[[[alert textFields] objectAtIndex:0] text] lowercaseString] isEqualToString:@"gcg"]){
                                       [pickerViewArray removeAllObjects];
                                       [pickerViewArray addObjectsFromArray:GCGLEADERS];
                                       
                                       [pickerView reloadAllComponents];
                                       [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
                                       [self populateScrollView];
                                   }
                                   else if([[[[[alert textFields] objectAtIndex:0] text] lowercaseString] isEqualToString:@"elders"]){
                                       [pickerViewArray removeAllObjects];
                                       [pickerViewArray addObjectsFromArray:ELDERS];
                                       
                                       [pickerView reloadAllComponents];
                                       [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
                                       [self populateScrollView];
                                   }
                                   else if([[[[[alert textFields] objectAtIndex:0] text] lowercaseString] isEqualToString:@"contacts"]){
                                       [pickerViewArray removeAllObjects];
                                       [self checkPermissionForCNContacts];
                                       
                                   }
                                   else if(isNumeric){
                                       [pickerViewArray removeAllObjects];
                                       
                                       for(int i = 1; i <= [[[[alert textFields] objectAtIndex:0] text] integerValue]; i ++ ){
                                           [pickerViewArray addObject: [[NSNumber numberWithInt:i] stringValue]];
                                       }
                                       
                                       [pickerView reloadAllComponents];
                                       [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
                                       [self populateScrollView];
                                   }
                                   else{
                                       [ToastView showToastInParentView:self.view withText:@"Invalid Code" withDuaration:2.0f];
                                   }
                               }];
        [alert addTextFieldWithConfigurationHandler:nil];
        [alert addAction:load];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)checkPermissionForCNContacts
{
    switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts])
    {
        case CNAuthorizationStatusNotDetermined:
        {
            [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted == YES)
                    self.groupOfContacts = [@[] mutableCopy];
                [self getAllContacts];
                NSLog(@"%@", _groupOfContacts );
                
                [pickerViewArray addObjectsFromArray:_groupOfContacts];
                
                [pickerView reloadAllComponents];
                [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
                [self populateScrollView];
            }];
        }
            break;
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied:
            // Show custom alert
            break;
        case CNAuthorizationStatusAuthorized:
            self.groupOfContacts = [@[] mutableCopy];
            [self getAllContacts];
            NSLog(@"%@", _groupOfContacts );
            
            [pickerViewArray addObjectsFromArray:_groupOfContacts];
            
            [pickerView reloadAllComponents];
            [pickerView selectRow:SCROLL_SIZE / 2 inComponent:0 animated:NO];
            [self populateScrollView];
            break;
    }
}


@end
