//
//  BSPhotoVC.m
//  BSFrameworks_Example
//
//  Created by 叶一枫 on 2020/6/4.
//  Copyright © 2020 blackstar_lang@163.com. All rights reserved.
//

#import "BSPhotoVC.h"
#import <Masonry.h>
#import <UIView+BSView.h>

#import <BSPhotoManagerController.h>
#import "BSPhotoProtocal.h"
#import "BSPhotoPreviewController.h"
#import "BSPhotoPreviewVideoVC.h"
#import "BSCameraController.h"

#import "TZImagePickerController.h"


@interface BSPhotoVC ()<BSPhotoProtocal,TZImagePickerControllerDelegate>

@property (nonatomic ,strong) UIButton *cameraBtn;
@property (nonatomic ,strong) UIButton *cameraBtn1;

@property (nonatomic ,strong) UIImageView *imageView;

@property (nonatomic ,strong) AVPlayer *player;

@property (nonatomic ,strong) NSMutableArray *mutArr;

@end



@implementation BSPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initSubViews];
    [self masonryLayout];
}

-(void)initSubViews{

    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.cameraBtn];
    [self.view addSubview:self.cameraBtn1];
    [self.view addSubview:self.imageView];
}


-(void)masonryLayout{

    [self.cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(150);
        make.left.offset(80);
        make.right.offset(-80);
        make.height.mas_equalTo(45);
    }];
    
    [self.cameraBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraBtn.mas_bottom).offset(50);
        make.left.offset(80);
        make.right.offset(-80);
        make.height.mas_equalTo(45);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraBtn1.mas_bottom).offset(50);
        make.left.offset(80);
        make.right.offset(-80);
        make.bottom.offset(-80);
    }];

}



#pragma mark - action 交互事件


-(void)cameraBtnClick{
    
    /// 整个图片选择控件测试，包含预览 + 相机
    BSPhotoManagerController *managerVC = [[BSPhotoManagerController alloc]init];
    managerVC.BSDelegate = self;
    managerVC.modalPresentationStyle = 0;
    managerVC.mainColor = [UIColor darkTextColor];
    managerVC.preBarAlpha = 0.7;
    managerVC.currentSelectedCount = 0;
    managerVC.allowSelectMaxCount = 9;
    managerVC.supCamera = YES;
    managerVC.autoPush = YES;
    managerVC.saveToAlbum = YES;
    managerVC.mediaType = 0;
    [self presentViewController:managerVC animated:YES completion:nil];


    
    
    
//    /// 图片预览测试
//    BSPhotoPreviewController *controller = [[BSPhotoPreviewController alloc]init];
//    NSArray *arr = @[[UIImage imageNamed:@"photo_camera_icon"],[UIImage imageNamed:@"preview_video_play"]];
//
//    [controller setPreviewPhotos:[NSMutableArray arrayWithArray:arr] previewType:PREVIEWTYPE_IMAGE defaultIndex:0];
//    controller.modalPresentationStyle = 0;
//    [self presentViewController:controller animated:YES completion:nil];
//
//
//
//    /// 视频预览本地视频测试
//    BSPhotoPreviewVideoVC *vc = [[BSPhotoPreviewVideoVC alloc]init];
//    vc.barStyle = UIStatusBarStyleLightContent;
//    vc.mainColor = [UIColor blackColor];
//    vc.preNaviAlpha = 0.7;
//
//    NSString *test = [[NSBundle mainBundle]pathForResource:@"test" ofType:@".mp4"];
//    NSString *test1 = [[NSBundle mainBundle]pathForResource:@"test1" ofType:@".mp4"];
//
//    NSArray *arr1 = @[test,test1];
//
//    [vc setPreviewVideos:[NSMutableArray arrayWithArray:arr1] defaultIndex:0 videoType:VIDEOTYPE_PATH];
//
//
//    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
//    navi.modalPresentationStyle = 0;
//    [self presentViewController:navi animated:YES completion:nil];

    
    
    
    
    
    /// 相机单独使用测试，可以添加水印
//    UIImageView *waterMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 100, 40, 40)];
//    waterMarkView.image = [UIImage imageNamed:@""];
    
//    BSCameraController *camera = [[BSCameraController alloc]init];
//    camera.modalPresentationStyle = 0;
//    camera.delegate = self;
//    camera.saveToAlbum = YES;
//    camera.mediaType = 2;
//    camera.waterMarkView = waterMarkView;
//    [self presentViewController:camera animated:YES completion:nil];
    
}



-(void)cameraBtnClick1{

    TZImagePickerController *managerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
    managerVC.modalPresentationStyle = 0;
    [self presentViewController:managerVC animated:YES completion:nil];
}


#pragma mark - systemDelegate

-(void)BSPhotoManagerDidFinishedSelectImage:(NSArray<UIImage *> *)images{

    self.imageView.image = images.firstObject;
    NSLog(@"UIImage 类型 图片回调");
}

-(void)BSPhotoManagerDidFinishedSelectImageData:(NSArray<NSData *> *)imageDataArr{

    NSLog(@"NSData 类型 图片回调，选择的图片个数 ： %ld",imageDataArr.count);
    NSData *data = imageDataArr.firstObject;
    
    self.imageView.image = [UIImage imageWithData:data];
}


- (void)BSPhotoManagerDidFinishedSelectVideoWithAVAsset:(AVAsset *)avAsset{
    
    NSLog(@"相册获取到视频地址：%@",avAsset);
}

-(void)BSPhotoCameraDidFinishedSelectVideoWithAVAsset:(AVAsset *)avAsset{
    
    NSLog(@"相机 == 获取到视频地址：%@",avAsset);
    
    UIView *pre = [[UIView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 400)];
    [self.view addSubview:pre];
        
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:avAsset];
    self.player = [AVPlayer playerWithPlayerItem:item];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 400);
    layer.backgroundColor = [UIColor redColor].CGColor;
    NSLog(@"\n%@",item);
    
    [pre.layer addSublayer:layer];
    
    [self.player play];
}


-(void)photoCameraTakeBtnClicked{
    NSLog(@"点击了拍照");
    
}


-(void)photoCameraNextBtnClickedWithImage:(UIImage *)image{
    NSLog(@"拍照点击了下一步： %@",image);
}


-(void)photoCameraNextBtnClickedWithVideoPath:(NSString *)videoPath{
    NSLog(@"视频点击了下一步： %@",videoPath);
}



#pragma mark - init 属性初始化


-(UIButton *)cameraBtn{
    if (!_cameraBtn) {
        _cameraBtn = [[UIButton alloc]init];
        _cameraBtn.backgroundColor = [UIColor blueColor];
        [_cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
}


-(UIButton *)cameraBtn1{
    if (!_cameraBtn1) {
        _cameraBtn1 = [[UIButton alloc]init];
        _cameraBtn1.backgroundColor = [UIColor blueColor];
        [_cameraBtn1 setTitle:@"三方" forState:UIControlStateNormal];
        [_cameraBtn1 addTarget:self action:@selector(cameraBtnClick1) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn1;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end
