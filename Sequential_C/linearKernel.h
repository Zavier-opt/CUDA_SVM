void linearKernel(float* x, float* y, float b, float* res) {
	/* x is a*n; y is b*n; b is a scalar; res is a*b */
	int a = sizeof(x) / sizeof(float);
	int n = sizeof(x[0]) / sizeof(float);
	int b = sizeof(y) / sizeof(float);
	for (int i = 0; i < a; i++) {
		for (int j = 0; i < b; j++) {
			for (int k = 0; k < n; k++) {
				res[i][j] += x[i][k] * y[j][k];
			}
			res[i][j] += b;
		}
	}
}