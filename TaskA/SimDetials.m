//
//  SimDetials.m
//  TaskA
//
//  Created by Zahur Ghotlawala on 3/15/14.
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

#import "SimDetials.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#define KEY_CARRIER_NAME @"CARRIER_NAME"
#define KEY_COUNTRY_CODE @"COUNTRY_CODE"
#define KEY_NETWORK_CODE @"NETWORK_CODE"
#define KEY_ISO_CODE @"ISO_CODE"
@implementation SimDetials
-(id)init{

    self=[super init];
    if (self) {
        

    }
    return self;
}

-(void)checkForChangeInSimInformation{
    CTTelephonyNetworkInfo *myNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *myCarrier = [myNetworkInfo subscriberCellularProvider];
    
//Check for sim is available or not
    if ([myCarrier mobileCountryCode]==nil) {
        NSLog(@"Sim card is not available or device is out of range.");
        return;
    }
    
//Check for previous sim info
    stored_countryCode=[self getDefaultObjectForKey:KEY_COUNTRY_CODE];
    if (stored_countryCode ==nil) {
//New sim found
        [self setDefaultObject:[myCarrier carrierName] ForKey:KEY_CARRIER_NAME];
        [self setDefaultObject:[myCarrier mobileCountryCode] ForKey:KEY_COUNTRY_CODE];
        [self setDefaultObject:[myCarrier mobileNetworkCode] ForKey:KEY_NETWORK_CODE];
        [self setDefaultObject:[myCarrier isoCountryCode] ForKey:KEY_ISO_CODE];
        NSLog(@"Sim information stored successfully");
        return;
    }else{
//Compare old and current sim information
        stored_carrierName=[self getDefaultObjectForKey:KEY_CARRIER_NAME];
        stored_isoCode=[self getDefaultObjectForKey:KEY_ISO_CODE];
        stored_networkCode=[self getDefaultObjectForKey:KEY_NETWORK_CODE];
    
    }
    BOOL changeFound=TRUE;
    if ([stored_carrierName compare:[myCarrier carrierName] options:NSCaseInsensitiveSearch]==NSOrderedSame) {
        if ([stored_countryCode compare:[myCarrier mobileCountryCode] options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            if ([stored_isoCode compare:[myCarrier isoCountryCode] options:
                 NSCaseInsensitiveSearch]==NSOrderedSame) {
                if ([stored_networkCode compare:[myCarrier mobileNetworkCode] options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                    changeFound=FALSE;
                }

            }
        }
        
    }
    
    if (changeFound) {
        NSLog(@"----New Sim Info Found----");
        [self setDefaultObject:[myCarrier carrierName] ForKey:KEY_CARRIER_NAME];
        [self setDefaultObject:[myCarrier mobileCountryCode] ForKey:KEY_COUNTRY_CODE];
        [self setDefaultObject:[myCarrier mobileNetworkCode] ForKey:KEY_NETWORK_CODE];
        [self setDefaultObject:[myCarrier isoCountryCode] ForKey:KEY_ISO_CODE];
        NSLog(@"%@",[myCarrier description]);
    }else{
        NSLog(@"No change in sim information");
    }

}
-(NSString *)getDefaultObjectForKey:(NSString *)key{
    NSString *retVal=nil;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    retVal = [prefs stringForKey:key];
    return retVal;
}

-(void)setDefaultObject:(id)object ForKey:(id)key{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:object forKey:key];
    [prefs synchronize];
}
@end
