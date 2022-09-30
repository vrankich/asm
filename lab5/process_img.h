#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define PI 3.14159265358979323846

unsigned char *get_image(const char *name, int *width, int *height, int *channels);
void rotate_image(double angle, unsigned char *img, unsigned char *new_img, int height, int width, int channels, int new_height, int new_width);
//void rotate_image_asm(double angle, unsigned char *img, unsigned char *new_img, int height, int width, int channels, int new_height, int new_width);
void rotate_asm(unsigned char *img, unsigned char *new_img, int width, int, int , int, double, double);
void write_image(const char *name, unsigned char *img, int height, int width, int channels);
void delete_image(unsigned char *img);

void pls_work_asm(double radians, unsigned char *img, unsigned char * new_img, int height, int width);

