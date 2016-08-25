//
//  YYScanViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/19.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "YYScanViewController.h"

//#import "ZXingObjC.h"
#import "YYMediaSDKEngine.h"


NSString *const kScanQRResultNotification = @"kYYScanQRResultNotification";


@interface YYScanViewController ()//<ZXCaptureDelegate>
{
    CGAffineTransform _captureSizeTransform;
    
    NSString *textResult;
}


//@property (nonatomic, strong) ZXCapture *capture;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIView *scanRectView;

@property (nonatomic, strong) UIVisualEffectView *blurView;


@end

@implementation YYScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:204/205 green:204/205 blue:204/205 alpha:0.7]];
    
//    [self.view.layer addSublayer:self.capture.layer];
//    [self.capture start];
//    [self.view addSubview:self.scanRectView];
//    [self applyOrientation];
//    [self addCloseViewBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
//    [self.capture stop];
}

//- (ZXCapture *)capture {
//    if (!_capture) {
//        _capture = [[ZXCapture alloc] init];
//        _capture.camera = 1;
//        _capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
//        _capture.delegate = self;
//    }
//    return _capture;
//}

- (UIView *)scanRectView {
    if (!_scanRectView) {
        CGRect frame = CGRectMake((self.view.bounds.size.width - 280) / 2, (self.view.bounds.size.height - 280) / 2, 280, 280);
        _scanRectView = [[UIView alloc]initWithFrame:frame];
        [_scanRectView setBackgroundColor:[UIColor clearColor]];
        [_scanRectView.layer setBorderColor:[UIColor greenColor].CGColor];
        [_scanRectView.layer setBorderWidth:2.0];
    }
    return _scanRectView;
}

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc]initWithFrame:self.view.bounds];
        [_blurView setBackgroundColor:[UIColor clearColor]];
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _blurView.effect = effect;
    }
    return _blurView;
}

- (void)closeBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addCloseViewBtn {
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(50, self.view.bounds.size.height - 70, SCREEN_WIDTH - 100, 44);
    [_closeBtn setFrame:frame];
    _closeBtn.layer.cornerRadius = 22;
    _closeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _closeBtn.layer.borderWidth = 0.5;
    _closeBtn.layer.masksToBounds = YES;
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Private
- (void)applyOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    float scanRectRotation;
    float captureRotation;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            captureRotation = 90;
            scanRectRotation = 180;
            break;
        case UIInterfaceOrientationLandscapeRight:
            captureRotation = 270;
            scanRectRotation = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            captureRotation = 180;
            scanRectRotation = 270;
            break;
        default:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
    }
    [self applyRectOfInterest:orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (captureRotation / 180 * M_PI));
    [self.capture setTransform:transform];
    [self.capture setRotation:scanRectRotation];
    self.capture.layer.frame = self.view.frame;
}

- (void)applyRectOfInterest:(UIInterfaceOrientation)orientation {
    CGFloat scaleVideo, scaleVideoX, scaleVideoY;
    CGFloat videoSizeX, videoSizeY;
    CGRect transformedVideoRect = self.scanRectView.frame;
    if([self.capture.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        videoSizeX = 1080;
        videoSizeY = 1920;
    } else {
        videoSizeX = 720;
        videoSizeY = 1280;
    }
    if(UIInterfaceOrientationIsPortrait(orientation)) {
        scaleVideoX = self.view.frame.size.width / videoSizeX;
        scaleVideoY = self.view.frame.size.height / videoSizeY;
        scaleVideo = MAX(scaleVideoX, scaleVideoY);
        if(scaleVideoX > scaleVideoY) {
            transformedVideoRect.origin.y += (scaleVideo * videoSizeY - self.view.frame.size.height) / 2;
        } else {
            transformedVideoRect.origin.x += (scaleVideo * videoSizeX - self.view.frame.size.width) / 2;
        }
    } else {
        scaleVideoX = self.view.frame.size.width / videoSizeY;
        scaleVideoY = self.view.frame.size.height / videoSizeX;
        scaleVideo = MAX(scaleVideoX, scaleVideoY);
        if(scaleVideoX > scaleVideoY) {
            transformedVideoRect.origin.y += (scaleVideo * videoSizeX - self.view.frame.size.height) / 2;
        } else {
            transformedVideoRect.origin.x += (scaleVideo * videoSizeY - self.view.frame.size.width) / 2;
        }
    }
    _captureSizeTransform = CGAffineTransformMakeScale(1/scaleVideo, 1/scaleVideo);
    self.capture.scanRect = CGRectApplyAffineTransform(transformedVideoRect, _captureSizeTransform);
}


#pragma mark - ZXCaptureDelegate

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
    [self.capture stop];
    
    AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, ^{
        
    });
    
    textResult = result.text;
    
    UIAlertView *resultAlert = [[UIAlertView alloc]initWithTitle:@"结果" message:textResult delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [resultAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (textResult) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kScanQRResultNotification object:textResult];
            [self sendQRresultRequest];
        }
    } else {
        [self.capture start];
    }
}

#pragma mark - Network

- (void)sendQRresultRequest {
    NSRange backRange = [textResult rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *auth = textResult;
    if (backRange.location < textResult.length) {
        auth = [textResult substringFromIndex:backRange.location + 1];
    }
    NSString *params = [NSString stringWithFormat:@"param=%@", auth];
    WEAKSELF
    [[YYMediaSDKEngine sharedInstance] socialAsyncRequest:@"POST" url:@"http://api.ioyouyun.com:80/login_by_code" params:params callbackId:0 timeout:10.0 completion:^(NSDictionary *json, NSError *error) {
        int status = [json[@"result"] intValue];
        if (status == 1) {
            [weakSelf closeBtnAction];
        }  else {
            [weakSelf showHUDErrorWithStatus:error.localizedDescription];
        }
    }];
}
*/
@end
