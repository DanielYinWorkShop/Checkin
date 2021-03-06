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
#import "AFHTTPSessionManager+RetryPolicy.h"
#import "yoyoAFHTTPSessionManager.h"
#import "myDataManager.h"
#import "myConstant.h"

@interface TicketViewController ()

@end

@implementation TicketViewController {
    NSArray *checkinsArray;
    NSArray *customFieldsArray;
    NSUserDefaults *defaults;
    __weak IBOutlet UILabel *lblIDStatic;
    __weak IBOutlet UILabel *lblPurchased;
    __weak IBOutlet UILabel *lblCheckins;
    __weak IBOutlet UINavigationItem *navItem;
}
@synthesize btnCheckin, tblCheckins, lblDate, lblHolderName, lblID, ticketData, imgStatusIcon, lblStatusText, lblStatusTitle, ticketNo, buyerEmail, ticketDate, workShopVenue, workShopName, workShopDate, workShopHour, buyerNumber, ticketStatus;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    //navItem.title = [defaults objectForKey:@"APP_TITLE"];
    
    //btnCheckin.layer.cornerRadius = 4;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    lblHolderName.text = ticketData[@"name"];
    lblID.text = ticketData[@"checksum"];
    lblDate.text = ticketData[@"payment_date"];
    lblPurchased.text = [defaults objectForKey:@"PURCHASED"];
    lblIDStatic.text = [defaults objectForKey:@"ID"];
    lblCheckins.text = [defaults objectForKey:@"CHECKINS"];
    //[btnCheckin setTitle:[defaults objectForKey:@"CHECK_IN"] forState:UIControlStateNormal];
    
    customFieldsArray = [[NSArray alloc] initWithArray:ticketData[@"custom_fields"]];
    self.viewOverlay.layer.cornerRadius = 5;
    
    ticketNo.text = @"";
    buyerEmail.text = @"";
    ticketDate.text = @"";
    workShopVenue.text = @"";
    workShopName.text = @"";
    workShopDate.text = @"";
    workShopHour.text = @"";
    buyerNumber.text = @"";
    ticketStatus.text = @"";
    btnCheckin.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_success"];
        lblStatusTitle.text = @"掃描成功";//[defaults objectForKey:@"SUCCESS"];
        lblStatusText.text = [defaults objectForKey: @"SUCCESS_MESSAGE"];
    } else {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_scanned"];
        lblStatusTitle.text = @"掃描錯誤";//[defaults objectForKey:@"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
    }
    
    [self.viewOverlayWrapper setHidden:NO];
}

- (IBAction)checkin:(id)sender {
    
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/check_in/%@?ct_json", [defaults stringForKey:@"baseUrl"], ticketData[@"checksum"]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [yoyoAFHTTPSessionManager sharedManager];//[AFHTTPSessionManager manager];
    
    [manager GET:API_SERVERTIME parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseServerTimeObject) {
        
        if(responseServerTimeObject[@"server_datetime"] != nil){
            [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSLog(@"CHECKIN RESPONSE %@", responseObject);
                
                //[self ticketCheckins];
                if ([responseObject[@"status"] isEqualToNumber:@0]) {
                    [self showOverlayWithStatus:NO];
                    ticketStatus.text = @"- 未使用 -";
                    btnCheckin.hidden = NO;
                    
                } else {
     
                    if(![defaults objectForKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]]){
                        [defaults setInteger:1 forKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]];
                        
                    }else{
                        NSInteger TicketsCheckIn = [[defaults objectForKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]] integerValue];
                        TicketsCheckIn += 1;
                        [defaults setInteger:TicketsCheckIn forKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]];
                        
                    }
                    
                    [self showOverlayWithStatus:YES];
                    ticketStatus.text = @"- 已使用 -";
                    btnCheckin.hidden = YES;
                    
                }
                
            } failure:^(NSURLSessionTask *task, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showOverlayWithStatus:NO];
            } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401, @403]];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showOverlayWithStatus:NO];
    } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401, @403]];
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
        
        if ([tableView respondsToSelector:@selector(layoutMargins)]) {
            tableView.layoutMargins = UIEdgeInsetsZero;
        }
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        return cell;
    } else {
        NSString *cellIdentifier = @"customFieldCell";
        TicketCustomFieldsTableViewCell *ticketCell = (TicketCustomFieldsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        ticketCell.lblKey.text = [customFieldsArray[indexPath.row] objectAtIndex:0];
        ticketCell.lblValue.text = [customFieldsArray[indexPath.row] objectAtIndex:1];
        
        
        if ([tableView respondsToSelector:@selector(layoutMargins)]) {
            tableView.layoutMargins = UIEdgeInsetsZero;
        }
        if ([ticketCell respondsToSelector:@selector(layoutMargins)]) {
            ticketCell.layoutMargins = UIEdgeInsetsZero;
        }
        
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
    NSLog(@"Ticket View URL: %@", requestedUrl);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [yoyoAFHTTPSessionManager sharedManager];//[AFHTTPSessionManager manager];
    [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        checkinsArray = [[NSArray alloc] initWithArray:responseObject];
        [tblCheckins reloadData];
        
        if(checkinsArray.count > 0 && [checkinsArray[checkinsArray.count-1][@"data"][@"status"] isEqualToString:@"Pass"]) {
            ticketStatus.text = @"- 已使用 -";
            btnCheckin.hidden = YES;
        }else if(checkinsArray.count > 0 && [checkinsArray[checkinsArray.count-1][@"data"][@"status"] isEqualToString:@"Fail"]) {
            ticketStatus.text = @"- 已使用 -";
            btnCheckin.hidden = YES;
        }else{
            ticketStatus.text = @"- 未使用 -";
            btnCheckin.hidden = NO;
        }
        
        ticketNo.text = [defaults objectForKey:@"ticketNo"];
        buyerEmail.text = [defaults objectForKey:@"buyerEmail"];
        ticketDate.text = [defaults objectForKey:@"ticketDate"];
        workShopVenue.text = [defaults objectForKey:@"eventLocation"];
        workShopName.text = [defaults objectForKey:@"eventName"];
        
        NSArray *datetime =[[NSString stringWithFormat:@"%@", [defaults objectForKey:@"ticketTime"]] componentsSeparatedByString:@" "];
        if([datetime count] > 3) {
            workShopHour.text = [NSString stringWithFormat:@"%@ - %@", datetime[1], datetime[3]];
            workShopDate.text = datetime[0];//[defaults objectForKey:@"eventDateTime"];
        
        }else{
            workShopHour.text = [defaults objectForKey:@"ticketTime"];
            workShopDate.text = [defaults objectForKey:@"ticketTime"];
        
        }
        
        buyerNumber.text = @"1";
        
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults objectForKey:@"ERROR_LOADING_DATA"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401, @403]];
}

@end
