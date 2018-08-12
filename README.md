# UIColorInvert
an app can inver picture color RGB.一个简单的iOS小程序，用于反转图片的颜色，并将颜色反转后的图片保存到相册。
like this:
![image](https://github.com/giveMeHug/UIColorInvert/blob/master/UIColorInvert/IMG_1559.PNG)
> 原理

一个RGB的颜色值，如RGB(0.2, 0.1, 0.5)，它的反色是RGB(0.8, 0.9, 0.5)。反色是与原色叠加可以变为白色的颜色，即用白色RGB：(1.0，1.0，1.0)减去原色的颜色。比如说红色RGB：1.0，0，0的反色是青色（0，1.0，1.0）。在OPENGL ES中为1。

> 代码如下

```
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
```
