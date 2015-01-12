//
//  LoginViewController.h
//  Checkin
//
//  Created by Borislav Jagodic on 1/12/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUrl;
@property (weak, nonatomic) IBOutlet UITextField *txtApiKey;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldCollection;

@end
