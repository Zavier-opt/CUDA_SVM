#ifndef head
#define head

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


float normSquare(float* x, float* y, int col);
float addVector(float* x, float* y, int col, float b);
void gaussianKernel(float** x, float** y, float sigma, float** res, int rowX, int colX, int rowY, int colY);
void linearKernel(float** x, float** y, float b, float** res, int rowX, int colX, int rowY, int colY);

/*test function*/
void testKernel();


#endif
