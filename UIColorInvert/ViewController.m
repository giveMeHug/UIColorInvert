//
//  ViewController.m
//  UIColorInvert
//
//  Created by xuelin on 2018/7/26.
//  Copyright © 2018年 upchina. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *oImagView;
@property (nonatomic, strong) UIImageView *verImagView;
@property (nonatomic, strong) UIButton *selecBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // UI
    UIImage *originalImage = [UIImage imageNamed:@"g"];
    UIImageView *oImagView = [[UIImageView alloc] initWithImage:originalImage];
    oImagView.contentMode = UIViewContentModeScaleAspectFill;
    oImagView.clipsToBounds = YES;
    oImagView.frame = CGRectMake(0, 80, self.view.frame.size.width, 200);
    [self.view addSubview:oImagView];
    self.oImagView = oImagView;
    
    UIImage *invertImage = [self inverColorImage:originalImage.copy];
    UIImageView *verImagView = [[UIImageView alloc] initWithImage:invertImage];
    verImagView.contentMode = UIViewContentModeScaleAspectFill;
    verImagView.clipsToBounds = YES;
    verImagView.frame = CGRectMake(0, 290, self.view.frame.size.width, 200);
    [self.view addSubview:verImagView];
    
    [verImagView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savePhoto)]];
    verImagView.userInteractionEnabled = YES;
    self.verImagView = verImagView;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 500, 80, 80)];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.7 alpha:1.0];
    [button setTitle:@"相册" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.selecBtn = button;
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.frame.size.width - 100, 20)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    label.textAlignment = NSTextAlignmentRight;
    label.text = @"点击反色图片可保存";
    [button addSubview:label];
}

// 相册相关
- (void)selectPhoto {
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)savePhoto {
    UIImageWriteToSavedPhotosAlbum(self.verImagView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (!error) {
        NSLog(@"save success");
        [self.selecBtn setTitle:@"保存成功" forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.selecBtn setTitle:@"相册" forState:UIControlStateNormal];
        });
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.oImagView.image = image;
    self.verImagView.image = [self inverColorImage:image.copy];
}

// ColorInver
- (UIImage *)inverColorImage:(UIImage *)image {
    CGImageRef cgimage = image.CGImage;
    size_t width = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    // 取图片首地址
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char));
    size_t bitsPerComponent = 8; // r g b a 每个component bits数目
    size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
    // 创建rgb颜色空间
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);

    for (size_t i = 0; i < height; i++) {
        for (size_t j = 0; j < width; j++) {
            size_t pixelIndex = i * width * 4 + j * 4;
            unsigned char red = data[pixelIndex];
            unsigned char green = data[pixelIndex + 1];
            unsigned char blue = data[pixelIndex + 2];
            // 修改颜色
            data[pixelIndex] = 255 - red;
            data[pixelIndex + 1] = 255 - green;
            data[pixelIndex + 2] = 255 - blue;

        }
    }
    cgimage = CGBitmapContextCreateImage(context);
    return [UIImage imageWithCGImage:cgimage];
}


@end
