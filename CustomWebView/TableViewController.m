//
//  TableViewController.m
//  CustomWebView
//
//  Created by AndyChen on 2017/8/15.
//  Copyright © 2017年 AndyChen. All rights reserved.
//

#import "TableViewController.h"
#import "OverlayButton.h"
#import "ViewController.h"
#import "Constant_m.h"
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0


@interface TableViewController ()<UIGestureRecognizerDelegate,UIViewControllerPreviewingDelegate>

@end
#else
@interface TableViewController ()<UIGestureRecognizerDelegate>

@end
#endif
@implementation TableViewController
{
    BOOL headerIsTouched;
//    UIView * headerView;
    OverlayButton *backButton;
    OverlayButton *doneButton;
    OverlayButton *randomButton;
//    UILabel *titleLabel;
    NSMutableArray *cellTitleArray;
    NSMutableArray *cellDescriptionArray;
    NSMutableArray *cellImageArray;
    NSMutableArray *cellHighImageArray;
    NSString *newNameWithTime;
}
- (void)setCellArrays
{
    if (cellTitleArray == nil)
    {
        cellTitleArray = [[NSMutableArray alloc] init];
    }
    if (cellDescriptionArray == nil)
    {
        cellDescriptionArray = [[NSMutableArray alloc] init];
    }
    if (cellImageArray == nil)
    {
        cellImageArray = [[NSMutableArray alloc] init];
    }
    if (cellHighImageArray == nil)
    {
        cellHighImageArray = [[NSMutableArray alloc] init];
    }
    [cellTitleArray removeAllObjects];
    [cellDescriptionArray removeAllObjects];
    [cellImageArray removeAllObjects];
    [cellHighImageArray removeAllObjects];
    for (int i = 0; i < _responseDataFormWeb.count; i++)
    {
        for (int j = 0; j < [[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] count]; j++)
        {
            // 設置 cell 的主標題
            [cellTitleArray addObject:[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"title"]];
            // 設置 cell 的次標題
            [cellDescriptionArray addObject:[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"description"]];
            // 設置 cell 的圖像
            NSURL *imageURL = [NSURL URLWithString:[[[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            if (!imageData)
            {
                imageData = UIImagePNGRepresentation([UIImage imageNamed:@"new_down.png"]);
            }
            [cellImageArray addObject:imageData];
            // 設置 High cell 的圖像
            NSURL *highImageURL = [NSURL URLWithString:[[[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"high"] objectForKey:@"url"]];
            NSData *highImageData = [NSData dataWithContentsOfURL:highImageURL];
            if (!highImageData)
            {
                highImageData = UIImagePNGRepresentation([UIImage imageNamed:@"new_down.png"]);
            }
            [cellHighImageArray addObject:highImageData];
        }
    }
}
- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSLog(@"Unicode 轉換");
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:NULL];
    //NSLog(@"Output = %@", returnStr);
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}
- (void)setResponseDataFormWeb:(NSMutableArray *)responseDataFormWeb
{
    _responseDataFormWeb = [responseDataFormWeb mutableCopy];
    [self setCellArrays];
    [self.tableView reloadData];
}
//设置Edit文本
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (self.editing)
    {
        self.editButtonItem.title = @"完成";
    } else
    {
        self.editButtonItem.title = @"編輯";
    }
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"long press on table view at section %ld", (long)indexPath.section);
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        
        [self.tableView setEditing:!self.tableView.editing animated:YES];
        backButton.alpha = !self.tableView.editing;
        randomButton.alpha = self.tableView.editing;
        doneButton.alpha = self.tableView.editing;
    } else
    {
        NSLog(@"gestureRecognizer.state = %@", [self returnStateOfLongpress:(long)gestureRecognizer.state]);
    }
}
- (NSString *)returnStateOfLongpress:(UIGestureRecognizerState)state
{
    NSString *stateString = @"";
    
    switch (state)
    {
        case UIGestureRecognizerStatePossible:
            stateString = @"UIGestureRecognizerStatePossible";
            break;
        case UIGestureRecognizerStateBegan:
            stateString = @"UIGestureRecognizerStateBegan";
            break;
        case UIGestureRecognizerStateChanged:
            stateString = @"UIGestureRecognizerStateChanged";
            break;
        case UIGestureRecognizerStateEnded:
            stateString = @"UIGestureRecognizerStateEnded";
            break;
        case UIGestureRecognizerStateCancelled:
            stateString = @"UIGestureRecognizerStateCancelled";
            break;
        case UIGestureRecognizerStateFailed:
            stateString = @"UIGestureRecognizerStateFailed";
            break;
    
        default:
            stateString = @"";
            break;
    }

    return stateString ;
}
- (void)labelTaprecognizer:(UITapGestureRecognizer*) recognizer
{
    NSLog(@"label 被按到了");
    CGPoint pp = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pp];
    NSLog(@"section :%li",(long)indexPath.section);
    [self.tableView setContentOffset:CGPointZero animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if (CURRENT_DEV_Version >=9.0)
    {
        if ([[self traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable)
        {
            NSLog(@"可以");
            [self registerForForceTouch];
        }    
    }
    
#endif

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self setHeaderViewWithSection:section];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [_responseDataFormWeb count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[[_responseDataFormWeb objectAtIndex:section] objectForKey:@"lists"] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"Header title");
    return [NSString stringWithFormat:@"%@",[self replaceUnicode:[[_responseDataFormWeb objectAtIndex:section] objectForKey:@"name"]]];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger numberOfRows = 0;
    for (int i = 0; i < indexPath.section; i ++)
    {
        numberOfRows += [tableView numberOfRowsInSection:i];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    cell.textLabel.text = [cellTitleArray objectAtIndex:indexPath.row+numberOfRows];

    cell.detailTextLabel.text = [cellDescriptionArray objectAtIndex:indexPath.row+numberOfRows];
    
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];

    cell.imageView.image = [UIImage imageWithData:[cellImageArray objectAtIndex:indexPath.row+numberOfRows]];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
//        [self.toDoItems removeObjectAtIndex: indexPath.row];
        //        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
        //                         withRowAnimation:UITableViewRowAnimationFade];
        
        NSMutableArray *theArray = [[NSMutableArray alloc] initWithArray:_responseDataFormWeb];
        
        [_responseDataFormWeb removeAllObjects];
        
      
        for (int i = 0; i<theArray.count ; i++)
        {
            
            NSMutableDictionary *innerDic = [[NSMutableDictionary alloc] initWithDictionary:[theArray objectAtIndex:i]];
            
            if (i == indexPath.section)
            {
                
                NSMutableArray *innerArray = [[NSMutableArray alloc] initWithArray:[innerDic objectForKey:@"lists"]];
                
                [innerArray removeObjectAtIndex:indexPath.row];
                [innerDic removeObjectForKey:@"lists"];
                [innerDic setObject:innerArray forKey:@"lists"];
                
            }
            [_responseDataFormWeb addObject:innerDic];
        }
        [self setCellArrays];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}
//开启向左滑动显示删除功能
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *testArray = [[NSMutableArray alloc] initWithArray:_responseDataFormWeb];

    NSInteger sourceNum = 0;
    NSInteger destinationNum = 0;
 
    for (int sourceCount = 0; sourceCount <[testArray count]; sourceCount ++)
    {
        if (sourceCount == sourceIndexPath.section)
        {
            sourceNum += sourceIndexPath.row;
            break;
        }else
        {
            sourceNum += [[testArray[sourceCount] objectForKey:@"lists"] count];
        }
    }
    for (int destinationCount = 0; destinationCount <[testArray count]; destinationCount ++)
    {
        if (destinationCount == destinationIndexPath.section)
        {
            destinationNum += destinationIndexPath.row;
            break;
        }else
        {
            destinationNum += [[testArray[destinationCount] objectForKey:@"lists"] count];
        }
    }
    NSLog(@"\nsourceNum :%ld \ndestinationNum :%ld",(long)sourceNum,(long)destinationNum);
    
    //移動項目
    NSMutableArray *editableArraySource = [[NSMutableArray alloc] initWithArray:[[_responseDataFormWeb objectAtIndex:sourceIndexPath.section]  objectForKey:@"lists"]];
    
    NSMutableArray *editableArrayDestination = [[NSMutableArray alloc] initWithArray:[[_responseDataFormWeb objectAtIndex:destinationIndexPath.section]  objectForKey:@"lists"]];
    
    NSDictionary *item = [[_responseDataFormWeb objectAtIndex:sourceIndexPath.section] objectForKey:@"lists"][sourceIndexPath.row];
    
    NSString *cellTitle = [cellTitleArray objectAtIndex:sourceNum];
    NSString *cellDescription = [cellDescriptionArray objectAtIndex:sourceNum];
    NSData *cellImage = [cellImageArray objectAtIndex:sourceNum];
    NSData *cellHighImage = [cellHighImageArray objectAtIndex:sourceNum];
    
    [editableArraySource removeObjectAtIndex:sourceIndexPath.row];
    [cellTitleArray removeObjectAtIndex:sourceNum];
    [cellDescriptionArray removeObjectAtIndex:sourceNum];
    [cellImageArray removeObjectAtIndex:sourceNum];
    [cellHighImageArray removeObjectAtIndex:sourceNum];
    if (destinationNum >[cellTitleArray count])
    {
        destinationNum -= 1;
    }
    [cellTitleArray insertObject:cellTitle atIndex:destinationNum];
    [cellDescriptionArray insertObject:cellDescription atIndex:destinationNum];
    [cellImageArray insertObject:cellImage atIndex:destinationNum];
    [cellHighImageArray insertObject:cellHighImage atIndex:destinationNum];
    
    
    
//    [cellTitleArray exchangeObjectAtIndex:sourceNum withObjectAtIndex:destinationNum];
//    [cellDescriptionArray exchangeObjectAtIndex:sourceNum withObjectAtIndex:destinationNum];
//    [cellImageArray exchangeObjectAtIndex:sourceNum withObjectAtIndex:destinationNum];
//    [cellHighImageArray exchangeObjectAtIndex:sourceNum withObjectAtIndex:destinationNum];
   
    if (sourceIndexPath.section == destinationIndexPath.section)
    {
        [editableArraySource insertObject:item atIndex:destinationIndexPath.row];
    }else
    {
        [editableArrayDestination insertObject:item atIndex:destinationIndexPath.row];
    }
    
//    cellTitleArray
//    cellDescriptionArray
//    cellImageArray
//    cellHighImageArray
    
    
    
    NSMutableDictionary *testArrysDicSource = [[NSMutableDictionary alloc] initWithDictionary:[testArray objectAtIndex:sourceIndexPath.section]];
    NSMutableDictionary *testArrysDicDestination = [[NSMutableDictionary alloc] initWithDictionary:[testArray objectAtIndex:destinationIndexPath.section]];
    
    [testArrysDicSource removeObjectForKey:@"lists"];
    [testArrysDicSource setObject:editableArraySource forKey:@"lists"];
    
    [testArrysDicDestination removeObjectForKey:@"lists"];
    [testArrysDicDestination setObject:editableArrayDestination forKey:@"lists"];

    [_responseDataFormWeb removeAllObjects];
    for (int i = 0 ; i < testArray.count; i ++)
    {
        if (i == sourceIndexPath.section)
        {
            [_responseDataFormWeb addObject:testArrysDicSource];
        }else if (i == destinationIndexPath.section)
        {
            [_responseDataFormWeb addObject:testArrysDicDestination];
        }
        else
        {
            [_responseDataFormWeb addObject:[testArray objectAtIndex:i]];
        }
    }
    
    NSLog(@"_responseDataFormWeb :%@",_responseDataFormWeb);
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIView *)setHeaderViewWithSection:(NSInteger)currentSection
{
    NSLog(@"創建 headerView");
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    
    NSLog(@"創建 titleLabel");
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:headerView.frame];
    
    titleLabel.text = [NSString stringWithFormat:@"歌單:%@",[self replaceUnicode:[[_responseDataFormWeb objectAtIndex:currentSection] objectForKey:@"name"]]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *taprecognizer = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(labelTaprecognizer:)];
    
    
    [headerView addGestureRecognizer:taprecognizer];
    [headerView addSubview:titleLabel];
    
    if (backButton == nil)
    {
        NSLog(@"創建 BackButton");
        backButton = [OverlayButton buttonWithType:UIButtonTypeRoundedRect];
        
        backButton.frame = CGRectMake(20, 5, self.view.frame.size.width*0.3, 20);

        
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [[backButton titleLabel] setFont:[UIFont systemFontOfSize:17]];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [backButton setupCornerRadius:10
                      WithBorderColor:[[UIColor blackColor] CGColor]
                      WithBorderWidth:1.0
                        MasksToBounds:YES];
        backButton.alpha = 1.0;
    }
    if (randomButton == nil)
    {
        NSLog(@"創建 BackButton");
        randomButton = [OverlayButton buttonWithType:UIButtonTypeRoundedRect];
        
        randomButton.frame = CGRectMake(20, 5, self.view.frame.size.width*0.3, 20);
        
        
        [randomButton setTitle:@"隨選" forState:UIControlStateNormal];
        [randomButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
    
        [randomButton setTitle:@"隨 選" forState:UIControlStateHighlighted];
        [randomButton setTitleColor:[UIColor lightGrayColor]
                           forState:UIControlStateHighlighted];// 設定正常情況的顏色
        [randomButton setTitleColor:[UIColor redColor]
                           forState:UIControlStateSelected|UIControlStateDisabled];
        
        
        [randomButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [[randomButton titleLabel] setFont:[UIFont systemFontOfSize:17]];
        [randomButton addTarget:self action:@selector(randomAction) forControlEvents:UIControlEventTouchUpInside];
        [randomButton setupCornerRadius:10
                      WithBorderColor:[[UIColor blackColor] CGColor]
                      WithBorderWidth:1.0
                        MasksToBounds:YES];
        randomButton.alpha = 0.0;
    }
    if (doneButton == nil)
    {
        NSLog(@"創建 doneButton");
        doneButton = [OverlayButton buttonWithType:UIButtonTypeRoundedRect];
        
        doneButton.frame = CGRectMake(self.view.frame.size.width-(self.view.frame.size.width/3), 5, self.view.frame.size.width*0.3, 20);
        
        
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [[doneButton titleLabel] setFont:[UIFont systemFontOfSize:17]];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setupCornerRadius:10
                      WithBorderColor:[[UIColor blackColor] CGColor]
                      WithBorderWidth:1.0
                        MasksToBounds:YES];
        doneButton.alpha = 0.0;
        
    }
    if (currentSection == 0)
    {
        [headerView addSubview:backButton];
        [headerView addSubview:randomButton];
        [headerView addSubview:doneButton];
    }
    return headerView;
}
- (void)setCookie
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"testCookie" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"someValue123456" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"www.example.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"www.example.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}
- (void)writeFileToDocu
{
    newNameWithTime = [NSString stringWithFormat:@"PL_%@",[self createNoewDateName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self localPathForResource:newNameWithTime ofType:@"txt"]];
//    NSString* documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    
//    NSString* foofile = [documentsPath stringByAppendingPathComponent:@"PlayList.txt"];
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    if (fileExists)
    {
        NSLog(@"\nFile Exist.");
        NSData *fileData = [NSData dataWithContentsOfFile:[self localPathForResource:newNameWithTime ofType:@"txt"]];
        NSLog(@"file :%@",[NSString stringWithUTF8String:[fileData bytes]]);
    }else
    {
        NSLog(@"\nFile Not Exist ,Write it OK");
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_responseDataFormWeb options:NSJSONWritingPrettyPrinted error:&error];
    NSString *fileContent = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *fileContent = [_responseDataFormWeb componentsJoinedByString: @"\n"];
    bool okay = [fileContent writeToURL:[NSURL fileURLWithPath:[self localPathForResource:newNameWithTime ofType:@"txt"]] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!okay)
    {
        NSLog(@"\nError writing to URL.");
        NSLog(@"Error occurred: %@", error);
    }else
    {
        NSLog(@"\nwrite file OK");
        [self startToUploadToIcloud];
    }
 
}
- (void)startToUploadToIcloud
{
    // Let's get the root directory for storing the file on iCloud Drive
    [self rootDirectoryForICloud:^(NSURL *ubiquityURL)
    {
        NSLog(@"1. ubiquityURL = %@", ubiquityURL);
        if (ubiquityURL) {
            
            // We also need the 'local' URL to the file we want to store
            NSURL *localURL = [NSURL fileURLWithPath:[self localPathForResource:newNameWithTime ofType:@"txt"]];
            NSLog(@"2. localURL = %@", localURL);
            
            // Now, append the local filename to the ubiquityURL
            ubiquityURL = [ubiquityURL URLByAppendingPathComponent:localURL.lastPathComponent];
            NSLog(@"3. ubiquityURL = %@", ubiquityURL);
            
            // And finish up the 'store' action
            NSError *error;
            if (![[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:localURL destinationURL:ubiquityURL error:&error]) {
                NSLog(@"Error occurred: %@", error);
            }
        }
        else {
            NSLog(@"Could not retrieve a ubiquityURL");
        }
    }];
}
- (void)rootDirectoryForICloud:(void (^)(NSURL *))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *rootDirectory = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
        
        if (rootDirectory) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:rootDirectory.path isDirectory:nil]) {
                NSLog(@"Create directory");
                [[NSFileManager defaultManager] createDirectoryAtURL:rootDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            completionHandler(rootDirectory);
        });
    });
}
- (NSString *)localPathForResource:(NSString *)resource ofType:(NSString *)type
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *resourcePath = [[documentsDirectory stringByAppendingPathComponent:resource] stringByAppendingPathExtension:type];
    return resourcePath;
}
- (NSString *)createNoewDateName
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmmss"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", dateString);
    return dateString;
}
#pragma mark Button Actions
- (void)doneAction
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    backButton.alpha = !self.tableView.editing;
    randomButton.alpha = self.tableView.editing;
    doneButton.alpha = self.tableView.editing;
//    [self setCellArrays];
//    [self.tableView reloadData];
}
- (void)backAction
{
    [UIView animateWithDuration:0.3 animations:^
     {
         [(ViewController *)self.presentingViewController setSongListArray:_responseDataFormWeb];
         [self writeFileToDocu];
     } completion:^(BOOL finished)
     {
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
}
- (void)randomAction
{
    NSMutableArray *theArray = [[NSMutableArray alloc] initWithArray:_responseDataFormWeb];
    [_responseDataFormWeb removeAllObjects];
    
    
    NSMutableArray *theCellTitleArray = [[NSMutableArray alloc] initWithArray:cellTitleArray];
    NSMutableArray *theCellDescriptionArray = [[NSMutableArray alloc] initWithArray:cellDescriptionArray];
    NSMutableArray *theCellImageArray = [[NSMutableArray alloc] initWithArray:cellImageArray];
    NSMutableArray *theCellHighImageArray = [[NSMutableArray alloc] initWithArray:cellHighImageArray];
    [cellTitleArray removeAllObjects];
    [cellDescriptionArray removeAllObjects];
    [cellImageArray removeAllObjects];
    [cellHighImageArray removeAllObjects];
    int addInt = 0;
    for (int i = 0; i<theArray.count ; i++)
    {
        NSMutableDictionary *innerDic = [[NSMutableDictionary alloc] initWithDictionary:[theArray objectAtIndex:i]];
        NSMutableArray *innerArray = [[NSMutableArray alloc] initWithArray:[innerDic objectForKey:@"lists"]];
        [innerDic removeObjectForKey:@"lists"];
        
        
        NSMutableArray *innerCellTitleArray = [[NSMutableArray alloc]
                                               initWithArray:[theCellTitleArray subarrayWithRange:NSMakeRange(addInt, innerArray.count)]];
        NSMutableArray *innerCellDescriptionArray = [[NSMutableArray alloc]
                                                     initWithArray:[theCellDescriptionArray subarrayWithRange:NSMakeRange(addInt, innerArray.count)]];
        NSMutableArray *innerCellImageArray = [[NSMutableArray alloc]
                                               initWithArray:[theCellImageArray subarrayWithRange:NSMakeRange(addInt, innerArray.count)]];
        NSMutableArray *innerCellHighImageArray = [[NSMutableArray alloc]
                                                   initWithArray:[theCellHighImageArray subarrayWithRange:NSMakeRange(addInt, innerArray.count)]];
        
        addInt += innerArray.count;
        
        
        for (NSInteger j = innerArray.count-1; j >= 0; --j)
        {
            int r = arc4random_uniform((int)innerArray.count);
            [innerArray exchangeObjectAtIndex:j withObjectAtIndex:r];
            
            [innerCellTitleArray exchangeObjectAtIndex:j withObjectAtIndex:r];
            [innerCellDescriptionArray exchangeObjectAtIndex:j withObjectAtIndex:r];
            [innerCellImageArray exchangeObjectAtIndex:j withObjectAtIndex:r];
            [innerCellHighImageArray exchangeObjectAtIndex:j withObjectAtIndex:r];
        }
        [innerDic setObject:innerArray forKey:@"lists"];
        [_responseDataFormWeb addObject:innerDic];
        cellTitleArray = [[cellTitleArray arrayByAddingObjectsFromArray:innerCellTitleArray] mutableCopy];
        cellDescriptionArray = [[cellDescriptionArray arrayByAddingObjectsFromArray:innerCellDescriptionArray] mutableCopy];
        cellImageArray = [[cellImageArray arrayByAddingObjectsFromArray:innerCellImageArray] mutableCopy];
        cellHighImageArray = [[cellHighImageArray arrayByAddingObjectsFromArray:innerCellHighImageArray] mutableCopy];
    }
//    [self setCellArrays];
    [self.tableView reloadData];
}
- (void)registerForForceTouch
{
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    NSLog(@"檢查");
    if (CURRENT_DEV_Version >= 9.0)
    {

        [self registerForPreviewingWithDelegate:self sourceView:self.view];
        
    }
#endif
}
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#pragma mark - peek手势
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    
    UIViewController *childVC = [[UIViewController alloc] init];
    childVC.preferredContentSize = CGSizeMake(self.view.frame.size.width*0.85,300.0);
    childVC.view.backgroundColor = [UIColor clearColor];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    NSLog(@"目前是第幾個歌單 :%ld",(long)indexPath.section);
    
    NSLog(@"看進去 :\n%@",[[[_responseDataFormWeb objectAtIndex:indexPath.section] objectForKey:@"lists"] objectAtIndex:indexPath.row]);
    NSLog(@"snippet :\n%@",[[[[_responseDataFormWeb objectAtIndex:indexPath.section] objectForKey:@"lists"] objectAtIndex:indexPath.row] objectForKey:@"snippet"]);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, childVC.view.frame.size.width-100, 50)];
    titleLabel.text = [[[[[_responseDataFormWeb objectAtIndex:indexPath.section] objectForKey:@"lists"] objectAtIndex:indexPath.row] objectForKey:@"snippet"] objectForKey:@"title"];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [childVC.view addSubview:titleLabel];
   
    NSInteger numberOfRows = 0;
    for (int i = 0; i < indexPath.section; i ++)
    {
        numberOfRows += [self.tableView numberOfRowsInSection:i];
        
    }
    UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLabel.frame), 150, 150)];
    imageview.image = [UIImage imageWithData:[cellHighImageArray objectAtIndex:indexPath.row+numberOfRows]];
    [childVC.view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageview.frame), childVC.view.frame.size.width-100, 50)];
    descriptionLabel.text = [[[[[_responseDataFormWeb objectAtIndex:indexPath.section] objectForKey:@"lists"] objectAtIndex:indexPath.row] objectForKey:@"snippet"] objectForKey:@"description"];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [childVC.view addSubview:descriptionLabel];
//    for (int i = 0; i < _responseDataFormWeb.count; i++)
//    {
//        for (int j = 0; j < [[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] count]; j++)
//        {
//            // 設置 cell 的主標題
//            [cellTitleArray addObject:[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"title"]];
//            // 設置 cell 的次標題
//            [cellDescriptionArray addObject:[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"description"]];
//            // 設置 cell 的圖像
//            NSURL *imageURL = [NSURL URLWithString:[[[[[[[_responseDataFormWeb objectAtIndex:i] objectForKey:@"lists"] objectAtIndex:j] objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"]];
//            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//            if (!imageData)
//            {
//                imageData = UIImagePNGRepresentation([UIImage imageNamed:@"new_down.png"]);
//            }
//            [cellImageArray addObject:imageData];
//        }
//    }
    
    
    if (indexPath == nil)
    {
        NSLog(@"long press on table view but not on a row");
         return nil;
    } else
    {
        NSLog(@"gestureRecognizer.state = good");
         return childVC;
    }
    

}

#pragma mark pop手势
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
//    [self showViewController:viewControllerToCommit sender:self];
}

#endif
@end
