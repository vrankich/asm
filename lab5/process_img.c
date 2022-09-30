#include "process_img.h"

unsigned char *get_image(const char *name, int *height, int *width, int *channels)
{
//	unsigned char *img = stbi_load(name, width, height, channels, 0);
//
//	if (!img) {
//		printf("Error in loading the image...\n");
//		exit(1);
//	}
//
//    printf("w %d h %d ch %d\n", *width, *height, *channels);

    return NULL;
}

void rotate_image(double angle, unsigned char *img, unsigned char *new_img, int height, int width, int channels, int new_height, int new_width)
{
	double sin_angle = sin(angle);
	double cos_angle = cos(angle);

    int x_center = round(((height + 1) / 2) - 1);
	int y_center = round(((width + 1) / 2) - 1);
    int x_new_center = round(((new_height + 1) / 2) - 1);
    int y_new_center = round(((new_width + 1) / 2) - 1);

    int x, y, x_rotate, y_rotate;
    int coord, new_coord;
    for (int i = 0; i < new_height; i++) {
        for (int j = 0; j < new_width * channels; j +=3) {
            //x = new_height - 1 - i - x_new_center;
            //y = new_width - 1 - (j / 3) - y_new_center;
            x = x_new_center - i;
            y = y_new_center - j / 3;
            x_rotate = round(x * cos_angle - y * sin_angle) + x_center;
            y_rotate = round(x * sin_angle + y * cos_angle) + y_center;

			if ((x_rotate >= 0) && (x_rotate < height) && (y_rotate >= 0) && (y_rotate < width) ) {

			    coord = x_rotate * width * channels + y_rotate * channels;
                new_coord = x * new_width * channels + y * channels;
                new_img[new_coord] = img[coord];
				new_img[new_coord + 1] = img[coord + 1];
				new_img[new_coord + 2] = img[coord + 2];
            }
        }

    }



//	int xt, yt;
//    long coord, coord_rotate;
//	for (int x = 0; x < new_height; ++x) {
//		xt = x - x_center;
//
//		for (int y = 0; y < new_width * channels; y += channels) {
//			yt = (y / channels) - y_center;
//
//			long x_rotate = lround(xt * cos_angle - yt * sin_angle) + x_center;
//            long y_rotate = lround(xt * sin_angle + yt * cos_angle) + y_center;
//
//			if ((coord < new_width*new_height*channels) && (x_rotate >= 0) && (x_rotate < height) && (y_rotate >= 0) && (y_rotate < width) ) {
//			    coord = (xt + new_height / 2) * new_width * channels + (yt + new_width / 2) * channels;
//
//
//
//                coord_rotate = x_rotate * width * channels + y_rotate * channels;
//                new_img[coord] = img[coord_rotate];
//				new_img[coord + 1] = img[coord_rotate + 1];
//				new_img[coord + 2] = img[coord_rotate + 2];
//			}
//		}
//	}
}

void write_image(const char *name, unsigned char *img, int height, int width, int channels)
{
    int quality = width * channels;

//	int what = stbi_write_jpg(name, width, height, channels, img, quality);
//	int what = stbi_write_jpg(name, width, height, channels, img, 100);
//	printf("%d\n", what);
    //stbi_image_free(old_img);
    //free(img);
}

void delete_image(unsigned char *img)
{
  //  stbi_image_free(img);
}
