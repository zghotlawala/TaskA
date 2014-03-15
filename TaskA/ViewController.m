//
//  ViewController.m
//  TaskA
//
//  Created by Zahur Ghotlawala on 3/14/14.
//  Created by Zahur Ghotlawala on 3/14/14.
//  The MIT License (MIT)
//  Copyright (c) 2014 Zahur Ghotlawala
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "ViewController.h"
#define EARTH_RADIUS 6378.138
#define REGION_SIZE 10
#import "AFNetworking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    [self getCurrentLocation:nil];
    
}

- (IBAction)getCurrentLocation:(id)sender {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	HUD.delegate = self;
    [HUD setLabelText:@"Finding your location"];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (IBAction)videoPressesd:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    NSDate *dateNow =[NSDate date];
    NSDateFormatter *formatterNew = [[NSDateFormatter alloc] init];
    [formatterNew setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    timeStamp= [formatterNew stringFromDate:dateNow];
    
}

-(void)uploadVideo{
    
    NSData *videoData = [NSData dataWithContentsOfURL:self.movieURL];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.xxx.com"]];
    NSDictionary *parameters=@{@"timeStamp": timeStamp,@"GeoLocation":currentLocation};
    
    NSString *videoFileName=[NSString stringWithFormat:@"taskVideo_%@.mov",timeStamp];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/videoupload.php" parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                    {
                                        [formData appendPartWithFileData:videoData name:@"file" fileName:videoFileName mimeType:@"video/quicktime"];
                                    }];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.delegate=self;
    HUD.labelText = @"Uploading";
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        HUD.progress=(totalBytesWritten/totalBytesExpectedToWrite)*100;
        
        
    }];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {NSLog(@"Video Uploaded Successfully");
        [self.movieController stop];
        [self.movieController.view removeFromSuperview];
        self.movieController = nil;
        [HUD setLabelText:@"Video Uploaded Successfully"];
        [HUD hide:TRUE afterDelay:1.f];
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {NSLog(@"Error : %@",  operation.responseString);
                                          [self.movieController stop];
                                          [self.movieController.view removeFromSuperview];
                                          self.movieController = nil;
                                          [HUD setLabelText:@"Opps! Something went wrong"];
                                          [HUD hide:TRUE afterDelay:1.f];
                                      }];
    
    
    [operation start];
    
}
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
    HUD = nil;
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError: %@", error);
    [_btnVideo setEnabled:FALSE];
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"didUpdateToLocation: %@", newLocation);
        [HUD setLabelText:@"Location Found"];
        [HUD hide:TRUE afterDelay:1.0f];
        [locationManager stopUpdatingLocation];
        CLLocationCoordinate2D validLocation=CLLocationCoordinate2DMake(29.32371397,+48.01801155);
        //CLLocationCoordinate2D validLocation=CLLocationCoordinate2DMake(37.331705,-122.030237);
        float distance=[self GetDistance:currentLocation.coordinate.latitude long1:currentLocation.coordinate.longitude la2:validLocation.latitude long2:validLocation.longitude];
        if (distance>REGION_SIZE) {
            [_btnVideo setEnabled:FALSE];
        }else{
            [_btnVideo setEnabled:TRUE];
        }
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    
    self.movieController = [[MPMoviePlayerController alloc] init];
    [self.movieController setContentURL:self.movieURL];
    
    [self.movieController.view setFrame:_movieBaseView.bounds];
    
    [self.movieBaseView addSubview:self.movieController.view];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.movieController];
    
    [self.movieController play];
    
}
#pragma mark Distance calcualtion handlers
-(double)GetDistance:(double)lat1 long1:(double)lng1 la2:(double)lat2 long2:(double)lng2 {
    double radLat1 = [self rad:lat1];
    double radLat2 = [self rad:lat2];
    double a = radLat1 - radLat2;
    double b = [self rad:lng1] -[self rad:lng2];
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 10000) / 10000;
    return s;
}

-(double)rad:(double)d
{
    return d *3.14159265 / 180.0;
}

#pragma mark ImagePicker delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.movieURL = info[UIImagePickerControllerMediaURL];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark Movie Playback Handler
- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Confirmation!" message:@"Would you like to send this video at our server" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

#pragma mark UIAlertView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self uploadVideo];
    }else{
        [self.movieController stop];
        [self.movieController.view removeFromSuperview];
        self.movieController = nil;
    }
}


@end
