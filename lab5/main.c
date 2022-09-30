//#include <stdio.h>
//#include <stdlib.h>
#include <time.h>
//#include <math.h>
#include "process_img.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image/stb_image_write.h"

int main(int argc, char *argv[])
{
    if (argc != 4) {
        printf("Usage: %s input_image output1_image output2_image\n", argv[0]);
        return 1;
    }

    const char *input = argv[1];
    const char *output = argv[2];
    const char *output_asm = argv[3];

    double angle = 45;
    //printf("Angle: ");
    //scanf("%lf", &angle);

    double radians = angle / 180.0 * PI;
    double sin_angle = sin(radians);
    double cos_angle = cos(radians);

    int height, width, channels;
    unsigned char *img = stbi_load(input, &width, &height, &channels, 0);
    //unsigned char *img = get_image(input, &height, &width, &channels);
    if (!img) {
        printf("Error in loading the image...\n");
        return 1;
    }

    int new_height = round(abs(height * cos_angle) + abs(width * sin_angle)) + 1;
    int new_width = round(abs(width * cos_angle) + abs(height * sin_angle)) + 1;

    int new_img_size = new_width * new_height * channels;
    unsigned char *new_img = (unsigned char *)malloc(new_img_size);

    //rotate_image(radians, img, new_img, height, width, channels, new_height, new_width);

    rotate_asm(img, new_img, width, height, new_width, new_height, sin_angle, cos_angle);
    printf("2 h %d w %d\n", new_height, new_width);

    printf("new h %d w %d\n", new_height, new_width);

    int what = stbi_write_jpg(output_asm, new_width, new_height, channels, new_img, 100);
    printf("%d\n", what);
    //write_image("new_image.jpg", new_img, new_height, new_width, channels);


    //stbi_image_free(img);
    //delete_image(img);
    free(new_img);

    return 0;
}
