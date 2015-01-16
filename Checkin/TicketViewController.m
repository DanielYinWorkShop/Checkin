//
//  TicketViewController.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/12/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "TicketViewController.h"
#import "TicketCustomFieldsTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@interface TicketViewController ()

@end

@implementation TicketViewController {
    NSArray *checkinsArray;
    NSArray *customFieldsArray;
    NSUserDefaults *defaults;
}
@synthesize btnCheckin, tblCheckins, lblDate, lblHolderName, lblID, ticketData, imgStatusIcon, lblStatusText, lblStatusTitle;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    btnCheckin.layer.cornerRadius = 4;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    lblHolderName.text = ticketData[@"name"];
    lblID.text = ticketData[@"checksum"];
    lblDate.text = ticketData[@"date"];
    
//TEST ONLY
//    customFieldsArray = @[
//                          @[@"Ticket Type:", @"VIP"],
//                          @[@"Buyer Name:", @"Hanke Beckett"],
//                          @[@"Buyer E-mail:", @"example@gmail.com"],
//                        ];
    
    customFieldsArray = [[NSArray alloc] initWithArray:ticketData[@"custom_fields"]];
    self.viewOverlay.layer.cornerRadius = 5;

    [self ticketCheckins];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)overlayClose:(id)sender
{
    [self.viewOverlayWrapper setHidden:YES];
}

- (void)showOverlayWithStatus:(BOOL)status
{
    if(status == YES) {
        imgStatusIcon.image = [UIImage imageNamed:@"success"];
        lblStatusTitle.text = @"SUCCESS";
        lblStatusText.text = @"TICKET WITH THIS CODE HAS BEEN CHECKED";
    } else {
        imgStatusIcon.image = [UIImage imageNamed:@"error"];
        lblStatusTitle.text = @"ERROR";
        lblStatusText.text = @"WRONG TICKET CODE";
    }
    [self.viewOverlayWrapper setHidden:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)checkin:(id)sender {
    
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/check_in/%@?ct_json", [defaults stringForKey:@"baseUrl"], ticketData[@"checksum"]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self ticketCheckins];
        [self showOverlayWithStatus:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self showOverlayWithStatus:NO];
    }];
}
- (IBAction)back:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblCheckins) {
        return [checkinsArray count];
    } else {
        return [customFieldsArray count];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblCheckins) {
        NSString *cellIdentifier = @"checkinsCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:13];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", checkinsArray[indexPath.row][@"data"][@"date_checked"], checkinsArray[indexPath.row][@"data"][@"status"]];
        return cell;
    } else {
        NSString *cellIdentifier = @"customFieldCell";
        TicketCustomFieldsTableViewCell *ticketCell = (TicketCustomFieldsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        ticketCell.lblKey.text = [customFieldsArray[indexPath.row] objectAtIndex:0];
        ticketCell.lblValue.text = [customFieldsArray[indexPath.row] objectAtIndex:1];
        
        return ticketCell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblCustomFields) {
        return 44;
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblCustomFields) {
        return 44;
    } else {
        return 30;
    }
}

#pragma mark - Network
-(void)ticketCheckins
{
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/ticket_checkins/%@?ct_json", [defaults stringForKey:@"baseUrl"], ticketData[@"checksum"]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        checkinsArray = [[NSArray alloc] initWithArray:responseObject];
        [tblCheckins reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"There is a problem in loading your data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }];
}

@end
