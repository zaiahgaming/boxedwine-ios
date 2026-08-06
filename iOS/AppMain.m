#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GameHubViewController.h"

static void SetupGameAudioSession(void) {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    [session setCategory:AVAudioSessionCategoryPlayback
                    mode:AVAudioSessionModeGameChat
                 options:AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    
    [session setPreferredIOBufferDuration:0.005 error:&error];
    [session setActive:YES error:&error];
}

@interface BoxedwineAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation BoxedwineAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SetupGameAudioSession();
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GameHubMainViewController *gameHubVC = [[GameHubMainViewController alloc] init];
    self.window.rootViewController = gameHubVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BoxedwineAppDelegate class]));
    }
}
