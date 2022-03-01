#include<math.h>

void gaussianKernel(float *x, float *y, float sigma, float *res) {
	/* x is a*n; y is 1*n; b is a scalar; res is a*1 */
	int a = sizeof(x) / sizeof(float);
	int n = sizeof(x[0]) / sizeof(float);
	for (int i = 0; i < a; i++) {
		res[i] = exp(norm(x[i], y)/(2*pow(sigma,2));
	}
}

float norm(float *x, float *y) {
	float sum = 0.0;
	int len = sizeof(x) / sizeof(float);
	for (int i = 0; i < len; i++) {
		sum += pow((x[i] - y[i]), 2);
	}
	return sqrt(sum);
}