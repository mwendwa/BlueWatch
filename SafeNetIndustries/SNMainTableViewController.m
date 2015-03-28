//
//  SNMainTableViewController.m
//  drivingwhileteen
//
//  Created by Eugene Alute Mwendwa on 9/22/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNMainTableViewController.h"
#import "SWRevealViewController.h"
#import "SNParentProfile.h"
#import "SNTeenProfile.h"
#import "CBAutoScrollLabel.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#define PARENT_1 @"Parent1"
#define PARENT_2 @"Parent2"
#define APP_TITLE @"SafeNet"
#define RECORDING_TEXT @"Recording...Recording...Recording..."
#define SPEECH_RATE  0.10
#define SPEECH_MPX  1.0
#define SPEECH_DELAY 0.25
#define DISTANCE_FILTER 50
#define AUDIO_FILE @"SafeNetMemo.m4a"

@interface SNMainTableViewController () <AVSpeechSynthesizerDelegate, AVAudioRecorderDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSDate *timeofDay;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSArray *locationAddress;
@property (nonatomic, strong) SNParentProfile *parent1;
@property (nonatomic, strong) SNParentProfile *parent2;
@property (nonatomic, strong) SNTeenProfile *teen;
@property (nonatomic, strong) NSMutableArray *speechArray;
@property (nonatomic, strong) AVSpeechSynthesizer *synth;
@property (nonatomic, strong) AVSpeechUtterance *utter;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic) BOOL isRecording;

@end

@implementation SNMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text = APP_TITLE;
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:30.0];
    tlabel.textColor = [UIColor grayColor];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    tlabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = tlabel;
    
    // emboss so that the label looks OK
    [tlabel setShadowColor:[UIColor darkGrayColor]];
    [tlabel setShadowOffset:CGSizeMake(0, -0.5)];
    self.navigationItem.titleView = tlabel;
    
    _parent1 = [SNParentProfile savedParent:PARENT_1];
    _parent2 = [SNParentProfile savedParent:PARENT_2];
    _teen = [SNTeenProfile savedTeen];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    _menuItems = @[@"pullover", @"window", @"engine", @"domelight", @"smartphone",  @"hands", @"speak", @"obey", @"consent", @"badge"];
    
    // record button
    [self setRecording:NO];
    
    // Initialize the audio stuff
    NSError *audioSessionError = nil;
    
    // Set the new dated audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               AUDIO_FILE,
                               nil];
    NSURL *soundFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio stuff
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    // Initiate and prepare the recorder
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSetting error:&audioSessionError];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;
    
    if (audioSessionError)
    {
        NSLog(@"error: %@", [audioSessionError localizedDescription]);
    } else {
        [_audioRecorder prepareToRecord];
    }
    
    // Speech stuff
    _synth = [[AVSpeechSynthesizer alloc] init];
    [_synth setDelegate: self];
    _speechArray = [[NSMutableArray alloc] init];
    
    // set the location
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (nil == self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = DISTANCE_FILTER;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        
        // reverse geocode location
        if (!self.geocoder)
            self.geocoder = [[CLGeocoder alloc] init];
        
        [self.geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray* placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (nil == error && [placemarks count] > 0) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[placemarks count]];
                for (CLPlacemark *placemark in placemarks) {
                    [tempArray addObject:[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@\n",
                                          placemark.subThoroughfare, placemark.thoroughfare,
                                          placemark.postalCode, placemark.locality,
                                          placemark.administrativeArea,
                                          placemark.country]];
                }
                _locationAddress = [tempArray copy];
                _teen.address = [tempArray copy];
                [_teen save];
                NSLog(@"%@ is currently at %@",_teen.name, _teen.address);
            }
            else {
                _locationAddress = nil;
                NSLog(@"Error: %@", error.debugDescription);
            }
        }];
    }
    
    NSLog(@"[%@ viewDidLoad]",self);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [_speechArray addObject:cell.textLabel.text];
    [self speakNext:cell.textLabel.text];
    
    return cell;
}

#pragma mark - Location manager delegate methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, save location.
        _teen.location = location;
        [_teen save];
        
        NSLog(@"Saved teen location at: %@", _teen.location);
    }
    NSLog(@"%@", [locations lastObject]);
}

#pragma mark - Speech

- (void)speechSynthesizer:(AVSpeechSynthesizer *)avsSynthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if ([_synth isEqual:avsSynthesizer] && [utterance isEqual:_utter])
        [self speakNext];
}

- (void) speakNext
{
    if (_speechArray.count > 0)
    {
        NSError *setCategoryErr = nil;
        NSError *activationErr  = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
        [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
        
        NSString *speechStr = [_speechArray objectAtIndex:0];
        [_speechArray removeObjectAtIndex:0];
        _utter = [[AVSpeechUtterance alloc] initWithString:speechStr];
        _utter.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        _utter.rate = SPEECH_RATE;
        _utter.pitchMultiplier = SPEECH_MPX;
        _utter.postUtteranceDelay = SPEECH_DELAY;

        [_synth speakUtterance:_utter];
        [_synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
         NSLog(@"Uttered the phrase: %@", speechStr);
    }
}

- (void) speakNext:(NSString *)phrase
{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    _utter = [[AVSpeechUtterance alloc] initWithString:phrase];
    _utter.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    _utter.rate = SPEECH_RATE;
    _utter.pitchMultiplier = SPEECH_MPX;
    _utter.postUtteranceDelay = SPEECH_DELAY;
        
    [_synth speakUtterance:_utter];
        
    NSLog(@"Uttered the phrase: %@", phrase);
}

#pragma mark - AVAudioRecorder

- (void)setRecording:(BOOL)recording {
    _isRecording = recording;
    UIBarButtonItem *barButton = nil;
    
    if (recording) {
        barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Stop-50"] style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(barButtonPressed:)];
    } else {
        barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Record-red-50"] style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(barButtonPressed:)];
    }
    
    self.navigationItem.rightBarButtonItem = barButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:176.0f/255.0f green:37.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    
    if (!recording) {
        //[_selectedTextField resignFirstResponder];
    }
    
}

- (void)barButtonPressed:(UIBarButtonItem *)button {
    
    [self setRecording:!_isRecording];
    
    if (!_isRecording) {
        UILabel *tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
        tlabel.text = APP_TITLE;
        tlabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:30.0];
        tlabel.textColor = [UIColor grayColor];
        tlabel.backgroundColor = [UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth = YES;
        tlabel.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = tlabel;
        
        [self stopRecording];
    }
    else {
        CBAutoScrollLabel *tlabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
        //UILabel *tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
        tlabel.text = RECORDING_TEXT;
        tlabel.pauseInterval = 3.f;
        tlabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
        tlabel.textColor = [UIColor colorWithRed:176.0f/255.0f green:37.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
        tlabel.backgroundColor = [UIColor clearColor];
        tlabel.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = tlabel;
        [tlabel observeApplicationNotifications];

        [self startRecording];
    }
}

- (void)startRecording
{
    NSLog (@"Start Recording");
    if (!_audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [_synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        // Start recording
        [_audioRecorder record];
    }
}

- (void)stopRecording
{
    NSLog (@"Stop Recording");
    [_audioRecorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    
}

@end

