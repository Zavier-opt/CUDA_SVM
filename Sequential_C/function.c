#include<stdio.h>
#include<math.h>
#include"head.h"

float normSquare(float* x, float* y, int col) {
	float sum = 0.0;
	for (int i = 0; i < col; i++) {
		sum += pow((x[i] - y[i]), 2);
	}
	return sum;
}

void gaussianKernel(float** x, float* y, float sigma, float* res, int row, int col) {
	/* x is row*col; y is 1*col;  res is 1*row */
	for (int i = 0; i < row; i++) {
		res[i] = exp(-normSquare(x[i], y, col) / (2 * pow(sigma, 2)));
	}
}

void linearKernel(float** x, float* y, float b, float* res, int row, int col) {
	/* x is row*col; y is 1*col;  res is 1*row */

	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			res[i] += x[i][j] * y[j];
		}
		res[i] += b;
	}
}

/***************************************************************************************************************/
/* test function*/
void testKernel() {
	int row = 3;
	int col = 2;

	float** x = (float**)malloc(row * sizeof(float*));
	for (int i = 0; i < row; i++) {
		x[i] = (float*)malloc(col * sizeof(float));
	}
	float xTemp[3][2] = { {1.0,2.0},{3.0,4.0} ,{5.0,6.0} };
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			x[i][j] = xTemp[i][j];
		}
	}

	float y[2] = { 1,2 };

	float res[3];
	float sigma = 2.0;
	float b = 2.0;

	/*linearKernel(x, y, b, res, row, col);*/
	gaussianKernel(x, y, sigma, res, row, col);

	for (int i = 0; i < 3; i++) {
		printf("%f ", res[i]);
	}
}