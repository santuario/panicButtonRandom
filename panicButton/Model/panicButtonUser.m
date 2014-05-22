//
//  panicButtonUser.m
//  panicButton
//
//  Created by 3π on 3/12/14.
//  Copyright (c) 2014 3π. All rights reserved.
//

#import "panicButtonUser.h"

@interface panicButtonUser(){
    SystemSoundID mBeep;
    AVAudioPlayer *audioPlayer;
}

@end

@implementation panicButtonUser

@synthesize countdownTimer, remainingTicks;



#pragma mark -
#pragma mark Lazy Instantiation Methods
#pragma mark -

// Lazy instantiation of Contacts Array
-(NSMutableArray *) contacts{
    if(!_contacts) _contacts = [[NSMutableArray alloc] initWithObjects:@"Rafiki",@"Arthur",@"Robert", nil]; // FIX ME
    return _contacts;
}


#pragma mark -
#pragma mark Singleton Methods/Users/santuario/Documents/iOS/Random/panicButton/panicButton/Model/panicButtonUser.h
#pragma mark -



+(id)sharedPanicButtonUser{
    static panicButtonUser *sharedMyPanicButtonUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedMyPanicButtonUser = [[self alloc] init];
    });
    
    return sharedMyPanicButtonUser;
}

-(id)init{
    
    if(self = [super init]){
        //[self checkIfUserIsRegistered];
    }
    
    return self;
}

-(instancetype)initWithUserID:(NSUInteger)usrID{
    
    self = [super init];
    
    if(self){
        //[self checkIfUserIsRegistered];
    }
    
    return self;
}


-(void)dealloc{
    
}


#pragma mark -
#pragma mark Panic Button USER Methods
#pragma mark -

-(BOOL)checkIfUserIsRegistered{
    
    NSLog(@"panicButtonUser :: checkIfUserIsRegistered");
    
    BOOL isRegistered = NO;
    
    NSFileManager *filemgr;
    NSString *dataFile;
    NSString *docsDir;
    NSArray *dirPaths;
    
    filemgr = [NSFileManager defaultManager];
    
    // Identify the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the data file
    dataFile = [docsDir stringByAppendingPathComponent: @"userFile.txt"];
    
    // Check if the file already exists
    if ([filemgr fileExistsAtPath: dataFile])
    {
        // Read file contents and display in textBox
        NSData *databuffer;
        databuffer = [filemgr contentsAtPath: dataFile];
        
        NSString *datastring = [[NSString alloc] initWithData: databuffer encoding:NSASCIIStringEncoding];
        
        NSLog(@"%@",datastring);
        isRegistered = YES;
        
    }
    
    return isRegistered;
}

-(void)registerNewUser{
    NSLog(@"panicButtonUser :: registerNewUser");
    
    NSString *someText = @"{'userID':0,'name':'','email':'','phone':0}";
    
    NSError *error = nil;
    
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:@"userFile.txt"];
    
    BOOL succeeded = [someText writeToFile:path atomically:YES
                                  encoding:NSUTF8StringEncoding error:nil];
    
    if (succeeded) {
        NSLog(@"Success at: %@",path);
    } else {
        NSLog(@"Failed to store. Error: %@",error);
    }
    
    
    
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}



#pragma mark -
#pragma mark Timer Methods
#pragma mark -



-(void)initTimerWithDuration:(NSTimeInterval)timeInterval{
    
    
    //int hours = (int)(timeInterval/3600.0f);
    //int minutes = ((int)timeInterval - (hours * 3600))/60;
    
    
    //NSLog(@"PANIC BUTTON TIME = %f ::: %d  | %d", timeInterval, hours, minutes);
    
    
    
    
    if (countdownTimer)
        return;
    
    remainingTicks = timeInterval;
    [self updateTimeout];
    
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: YES];
    
}


-(void)handleTimerTick
{

    remainingTicks--;
    [self updateTimeout];
    
    if (remainingTicks <= 0) {
        [countdownTimer invalidate];
        countdownTimer = nil;
        [self playAlarmSound];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinalizeCountdownTimer object:[NSString stringWithFormat:@"00:00"]];

    }
    
    
    
}

-(void)updateTimeout{
    
   // NSLog(@"INIT TIMER :: updateTimeout :: %d", remainingTicks);
    int hours = (int)(remainingTicks/3600.0f);
    int minutes = ((int)remainingTicks - (hours * 3600))/60;
    
    
    NSLog(@"PANIC BUTTON TIME = %d ::: %d  | %d", remainingTicks, hours, minutes);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCountdownTimer object:[NSString stringWithFormat:@"%d",remainingTicks]];

}


-(void)killCountdown{
    
    [countdownTimer invalidate];
    countdownTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinalizeCountdownTimer object:[NSString stringWithFormat:@"00:00"]];
}

-(void)playAlarmSound{
    
    [self playSoundFXnamed:@"alarm.mp3" Loop: YES];
    /*
    
    // Create the sound ID
    NSString* path = [[NSBundle mainBundle]
                      pathForResource:@"beep" ofType:@"aiff"];
    NSURL* url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &mBeep);
    
    // Play the sound
    AudioServicesPlaySystemSound(mBeep);
     */

}

-(void)stopAlarmSoud{
    
    
    // Dispose of the sound
    //AudioServicesDisposeSystemSoundID(mBeep);
    
    [audioPlayer stop];
}

-(BOOL) playSoundFXnamed: (NSString*) vSFXName Loop: (BOOL) vLoop
{
    NSError *error;
    
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSString* bundleDirectory = (NSString*)[bundle bundlePath];
    
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:vSFXName]];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if(vLoop)
        audioPlayer.numberOfLoops = -1;
    else
        audioPlayer.numberOfLoops = 0;
    
    BOOL success = YES;
    
    if (audioPlayer == nil)
    {
        success = NO;
    }
    else
    {
        success = [audioPlayer play];
    }
    return success;
}



#pragma mark -
#pragma mark Bluetooth Methods
#pragma mark -

-(void)initBluettothConnection{
    
}



@end
