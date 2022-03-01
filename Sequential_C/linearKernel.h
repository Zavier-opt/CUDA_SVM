void linearKernel(float *x, float *y, float b, float *res) {
	/* x is a*n; y is 1*n; b is a scalar; res is a*1 */
	int a = sizeof(x) / sizeof(float);
	int n = sizeof(x[0]) / sizeof(float);
	for (int i = 0; i < a; i++) {
		for (int j = 0; j < n; j++) {
			res[i] += x[i][j] * y[j];
		}
		res[i] += b;
	}
}