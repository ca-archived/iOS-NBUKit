//
//  RBVolumeButtons.m
//  VolumeSnap
//
//  Created by Randall Brown on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RBVolumeButtons.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RBVolumeButtons()
-(void)initializeVolumeButtonStealer;
-(void)volumeDown;
-(void)volumeUp;
-(void)startStealingVolumeButtonEvents;
-(void)stopStealingVolumeButtonEvents;

@property BOOL isStealingVolumeButtons;
@property BOOL stoppedStealingBecauseOfBackground;
@property (retain) UIView *volumeView;

@end

@implementation RBVolumeButtons

@synthesize upBlock;
@synthesize downBlock;
@synthesize launchVolume;
@synthesize isStealingVolumeButtons = _isStealingVolumeButtons;
@synthesize stoppedStealingBecauseOfBackground = _stoppedStealingBecauseOfBackground;
@synthesize volumeView = _volumeView;

void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             );
void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             ){
   const float *volumePointer = inData;
   float volume = *volumePointer;

   
   if( volume > [(RBVolumeButtons*)inClientData launchVolume] )
   {
      [(RBVolumeButtons*)inClientData volumeUp];
   }
   else if( volume < [(RBVolumeButtons*)inClientData launchVolume] )
   {
      [(RBVolumeButtons*)inClientData volumeDown];
   }

}

-(void)volumeDown
{
   AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
   
   [[MPMusicPlayerController applicationMusicPlayer] setVolume:launchVolume];
   
   [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.1];
   
   
   if( self.downBlock )
   {
      self.downBlock();
   }
}

-(void)volumeUp
{
   AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
   
   [[MPMusicPlayerController applicationMusicPlayer] setVolume:launchVolume];
   
   [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.1];
   

      if( self.upBlock )
      {
         self.upBlock();
      }

}

-(id)init
{
   self = [super init];
   if( self )
   {
      self.isStealingVolumeButtons = NO;
      self.stoppedStealingBecauseOfBackground = NO;
   }
   return self;
}

-(void)startStealingVolumeButtonEvents
{
   NSAssert([[NSThread currentThread] isMainThread], @"This must be called from the main thread");
   
   if(self.isStealingVolumeButtons) {
      return;
   }
   
   AudioSessionInitialize(NULL, NULL, NULL, NULL);
   AudioSessionSetActive(YES);
   
   launchVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
   hadToLowerVolume = launchVolume == 1.0;
   hadToRaiseVolume = launchVolume == 0.0;
   if( hadToLowerVolume )
   {
      [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.95];
      launchVolume = 0.95;
   }
   
   if( hadToRaiseVolume )
   {
      [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.05];
      launchVolume = 0.05;
   }
   
   CGRect frame = CGRectMake(0, -100, 10, 0);
   self.volumeView = [[[MPVolumeView alloc] initWithFrame:frame] autorelease];
   [self.volumeView sizeToFit];
   [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.volumeView];
   
   [self initializeVolumeButtonStealer];
   
   __block RBVolumeButtons *volumeStealer = self;
   [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
      if(volumeStealer.isStealingVolumeButtons)
      {
         [volumeStealer stopStealingVolumeButtonEvents];
         volumeStealer.stoppedStealingBecauseOfBackground = YES;
      }
      
   }];
   
   
   [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
      if(volumeStealer.stoppedStealingBecauseOfBackground)
      {
         [volumeStealer startStealingVolumeButtonEvents];
         volumeStealer.stoppedStealingBecauseOfBackground = NO;
      }
   }];
   
   
   [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
      if(volumeStealer.stoppedStealingBecauseOfBackground)
      {
         [volumeStealer startStealingVolumeButtonEvents];
         volumeStealer.stoppedStealingBecauseOfBackground = NO;
      }
   }];
   
   self.isStealingVolumeButtons = YES;
}

-(void)stopStealingVolumeButtonEvents
{
   NSAssert([[NSThread currentThread] isMainThread], @"This must be called from the main thread");
   
   if(!self.isStealingVolumeButtons)
   {
      return;
   }
   
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
   
   if( hadToLowerVolume )
   {
      [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
   }
   
   if( hadToRaiseVolume )
   {
      [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
   }
   
   [self.volumeView removeFromSuperview];
   self.volumeView = nil;
   
   AudioSessionSetActive(NO);
   
   self.isStealingVolumeButtons = NO;
}

-(void)dealloc
{
   [self stopStealingVolumeButtonEvents];
   self.upBlock = nil;
   self.downBlock = nil;
   [super dealloc];
}

-(void)initializeVolumeButtonStealer
{
   AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
}

@end
