typedef struct {
	float* x;	/* input x nd array*/
	float* y;	/* input x array*/
	float* C;	/* regularization parameter */
	char kernel[10]; /* kernel function */
	float* alphas; /* lagrange multiplier vector */
	float bias; /* bias term */
	float error; /* error cache */
	float* obj; /* record of objective function value */
	int m;  /* size of training set */
}SMOModel;
