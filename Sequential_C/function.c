#include<stdio.h>
#include<math.h>
#include"head.h"
#include<stdlib.h>

float normSquare(float* x, float* y, int col) {
	float sum = 0.0;
	for (int i = 0; i < col; i++) {
		sum += pow((x[i] - y[i]), 2);
	}
	return sum;
}

void gaussianKernel(float** x, float** y, float sigma, float** res, int rowX, int colX, int rowY, int colY) {
	/* x is rowX*colX; y is rowY*colY;  res is rowX*rowY; colX=colY */
	for (int i = 0; i < rowX; i++) {
		for (int j = 0; j < rowY; j++) {
			res[i][j] = exp(-normSquare(x[i], y[j], colX) / (2 * pow(sigma, 2)));
		}
	}
}

float addVector(float* x, float* y, int col, float b) {
	float sum = 0.0;
	for (int i = 0; i < col; i++) {
		sum += x[i] * y[i];
	}
	return sum + b;
}

void linearKernel(float** x, float** y, float b, float** res, int rowX, int colX, int rowY, int colY) {
	/* x is rowX*colX; y is rowY*colY;  res is rowX*rowY; colX=colY */
	for (int i = 0; i < rowX; i++) {
		for (int j = 0; j < rowY; j++) {
			res[i][j] = addVector(x[i], y[j], colX, b);
		}
	}
}

/***************************************************************************************************************/
/* test function*/
void testKernel() {
	int rowX = 3;
	int colX = 2;

	int rowY = 3;
	int colY = 2;

	float** x = (float**)malloc(rowX * sizeof(float*));
	for (int i = 0; i < rowX; i++) {
		x[i] = (float*)malloc(colX * sizeof(float));
	}
	float xTemp[3][2] = { {1.0,2.0},{3.0,4.0} ,{5.0,6.0} };
	for (int i = 0; i < rowX; i++) {
		for (int j = 0; j < colX; j++) {
			x[i][j] = xTemp[i][j];
		}
	}

	float** y = (float**)malloc(rowY * sizeof(float*));
	for (int i = 0; i < rowY; i++) {
		y[i] = (float*)malloc(colY * sizeof(float));
	}
	float yTemp[3][2] = { {1.0,2.0},{3.0,4.0} ,{5.0,6.0} };
	for (int i = 0; i < rowY; i++) {
		for (int j = 0; j < colY; j++) {
			y[i][j] = yTemp[i][j];
		}
	}

	float** res = (float**)malloc(rowX * sizeof(float*));
	for (int i = 0; i < rowX; i++) {
		res[i] = (float*)malloc(rowY * sizeof(float));
	}

	float sigma = 2.0;
	float b = 2.0;

	linearKernel(x, y, b, res, rowX, colX, rowY, colY);
	/*gaussianKernel(x, y, sigma, res, rowX, colX, rowY, colY);*/

	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			printf("%f ", res[i][j]);
		}
	}
}
