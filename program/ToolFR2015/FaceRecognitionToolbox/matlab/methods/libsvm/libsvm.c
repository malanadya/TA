#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "svm.h"

#include "mex.h"
#include "svm_model_matlab.h"

#if MX_API_VER < 0x07030000
typedef int mwIndex;
#endif 

#define CMD_LEN 2048
#define Malloc(type,n) (type *)malloc((n)*sizeof(type))

#define OPT_SET_DATA                    1
#define OPT_TRAIN                       2
#define OPT_CLEAR_DATA                  3
#define OPT_CLEAR_MODEL                 4
#define OPT_EXPORT_MODEL                5
#define OPT_PREDICT                     6
#define OPT_CLEAR                       7
#define OPT_SAVE                        8
#define OPT_LOAD                        9

// svm arguments
struct svm_parameter param;		// set by parse_command_line
struct svm_problem prob;		// set by read_problem
struct svm_model *model;
struct svm_node *x_space;
int cross_validation;
int nr_fold;
int nr_feat;
bool first = false;
bool verbose = false;
bool gotData = false;
bool gotModel = false;
bool isLoaded = false;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///   LIBSVM TRAIN CODE
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

double do_cross_validation()
{
	int i;
	int total_correct = 0;
	double total_error = 0;
	double sumv = 0, sumy = 0, sumvv = 0, sumyy = 0, sumvy = 0;
	double *target = Malloc(double,prob.l);
	double retval = 0.0;

	svm_cross_validation(&prob,&param,nr_fold,target);
	if(param.svm_type == EPSILON_SVR ||
	   param.svm_type == NU_SVR)
	{
		for(i=0;i<prob.l;i++)
		{
			double y = prob.y[i];
			double v = target[i];
			total_error += (v-y)*(v-y);
			sumv += v;
			sumy += y;
			sumvv += v*v;
			sumyy += y*y;
			sumvy += v*y;
		}
		mexPrintf("Cross Validation Mean squared error = %g\n",total_error/prob.l);
		mexPrintf("Cross Validation Squared correlation coefficient = %g\n",
			((prob.l*sumvy-sumv*sumy)*(prob.l*sumvy-sumv*sumy))/
			((prob.l*sumvv-sumv*sumv)*(prob.l*sumyy-sumy*sumy))
			);
		retval = total_error/prob.l;
	}
	else
	{
		for(i=0;i<prob.l;i++)
			if(target[i] == prob.y[i])
				++total_correct;
		mexPrintf("Cross Validation Accuracy = %g%%\n",100.0*total_correct/prob.l);
		retval = 100.0*total_correct/prob.l;
	}
	free(target);
	return retval;
}

// nrhs should be 3
int parse_command_line(int nrhs, const mxArray *prhs[], char *model_file_name)
{
	int i, argc = 1;
	char cmd[CMD_LEN];
	char *argv[CMD_LEN/2];

	// default values
	param.svm_type = C_SVC;
	param.kernel_type = RBF;
	param.degree = 3;
	param.gamma = 0;	// 1/k
	param.coef0 = 0;
	param.nu = 0.5;
	param.cache_size = 100;
	param.C = 1;
	param.eps = 1e-3;
	param.p = 0.1;
	param.shrinking = 1;
	param.probability = 0;
	param.nr_weight = 0;
	param.weight_label = NULL;
	param.weight = NULL;
	cross_validation = 0;

	if(nrhs <= 1)
		return 1;
	if(nrhs == 2)
		return 0;

	// put options in argv[]
	mxGetString(prhs[2], cmd,  mxGetN(prhs[2]) + 1);
	if((argv[argc] = strtok(cmd, " ")) == NULL)
		return 0;
	while((argv[++argc] = strtok(NULL, " ")) != NULL)
		;

	// parse options
	for(i=1;i<argc;i++)
	{
		if(argv[i][0] != '-') break;
		if(++i>=argc)
			return 1;
		switch(argv[i-1][1])
		{
			case 's':
				param.svm_type = atoi(argv[i]);
				break;
			case 't':
				param.kernel_type = atoi(argv[i]);
				break;
			case 'd':
				param.degree = atoi(argv[i]);
				break;
			case 'g':
				param.gamma = atof(argv[i]);
				break;
			case 'r':
				param.coef0 = atof(argv[i]);
				break;
			case 'n':
				param.nu = atof(argv[i]);
				break;
			case 'm':
				param.cache_size = atof(argv[i]);
				break;
			case 'c':
				param.C = atof(argv[i]);
				break;
			case 'e':
				param.eps = atof(argv[i]);
				break;
			case 'p':
				param.p = atof(argv[i]);
				break;
			case 'h':
				param.shrinking = atoi(argv[i]);
				break;
			case 'b':
				param.probability = atoi(argv[i]);
				break;
			case 'v':
				cross_validation = 1;
				nr_fold = atoi(argv[i]);
				if(nr_fold < 2)
				{
					mexPrintf("n-fold cross validation: n must >= 2\n");
					return 1;
				}
				break;
			case 'w':
				++param.nr_weight;
				param.weight_label = (int *)realloc(param.weight_label,sizeof(int)*param.nr_weight);
				param.weight = (double *)realloc(param.weight,sizeof(double)*param.nr_weight);
				param.weight_label[param.nr_weight-1] = atoi(&argv[i-1][2]);
				param.weight[param.nr_weight-1] = atof(argv[i]);
				break;
			default:
				mexPrintf("libsvm error: Unknown option\n");
				return 1;
		}
	}
	return 0;
}

// read in a problem (in svmlight format)
int read_problem_dense(const mxArray *label_vec, const mxArray *instance_mat)
{
	int i, j, k;
	int elements, max_index, sc;
	double *samples, *labels;

	labels = mxGetPr(label_vec);
	samples = mxGetPr(instance_mat);
	sc = mxGetN(instance_mat);

	elements = 0;
	// the number of instance
	prob.l = mxGetM(instance_mat);
	if(param.kernel_type == PRECOMPUTED)
		elements = prob.l * (sc + 1);
	else
	{
		for(i = 0; i < prob.l; i++)
		{
			for(k = 0; k < sc; k++)
				if(samples[k * prob.l + i] != 0)
					elements++;
			// count the '-1' element
			elements++;
		}
	}

	prob.y = Malloc(double,prob.l);
	prob.x = Malloc(struct svm_node *,prob.l);
	x_space = Malloc(struct svm_node, elements);

	max_index = sc;
	j = 0;
	for(i = 0; i < prob.l; i++)
	{
		prob.x[i] = &x_space[j];
		prob.y[i] = labels[i];

		for(k = 0; k < sc; k++)
		{
			if(param.kernel_type == PRECOMPUTED || samples[k * prob.l + i] != 0)
			{
				x_space[j].index = k + 1;
				x_space[j].value = samples[k * prob.l + i];
				j++;
			}
		}
		x_space[j++].index = -1;
	}

	if(param.gamma == 0)
		param.gamma = 1.0/max_index;

	if(param.kernel_type == PRECOMPUTED)
		for(i=0;i<prob.l;i++)
		{
			if((int)prob.x[i][0].value <= 0 || (int)prob.x[i][0].value > max_index)
			{
				mexPrintf("Wrong input format: sample_serial_number out of range\n");
				return -1;
			}
		}

	return 0;
}

int read_problem_sparse(const mxArray *label_vec, const mxArray *instance_mat)
{
	int i, j, k, low, high;
	mwIndex *ir, *jc;
	int elements, max_index, num_samples;
	double *samples, *labels;
	mxArray *instance_mat_tr; // transposed instance sparse matrix

	// transpose instance matrix
	{
		mxArray *prhs[1], *plhs[1];
		prhs[0] = mxDuplicateArray(instance_mat);
		if(mexCallMATLAB(1, plhs, 1, prhs, "transpose"))
		{
			mexPrintf("Error: cannot transpose training instance matrix\n");
			return -1;
		}
		instance_mat_tr = plhs[0];
		mxDestroyArray(prhs[0]);
	}

	// each column is one instance
	labels = mxGetPr(label_vec);
	samples = mxGetPr(instance_mat_tr);
	ir = mxGetIr(instance_mat_tr);
	jc = mxGetJc(instance_mat_tr);

	num_samples = mxGetNzmax(instance_mat_tr);

	// the number of instance
	prob.l = mxGetN(instance_mat_tr);
	elements = num_samples + prob.l;
	max_index = mxGetM(instance_mat_tr);

	prob.y = Malloc(double,prob.l);
	prob.x = Malloc(struct svm_node *,prob.l);
	x_space = Malloc(struct svm_node, elements);

	j = 0;
	for(i=0;i<prob.l;i++)
	{
		prob.x[i] = &x_space[j];
		prob.y[i] = labels[i];
		low = jc[i], high = jc[i+1];
		for(k=low;k<high;k++)
		{
			x_space[j].index = ir[k] + 1;
			x_space[j].value = samples[k];
			j++;
	 	}
		x_space[j++].index = -1;
	}

	if(param.gamma == 0)
		param.gamma = 1.0/max_index;

	return 0;
}

static void train_fake_answer(mxArray *plhs[])
{
	plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///   LIBSVM PREDICT CODE
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void read_sparse_instance(const mxArray *prhs, int index, struct svm_node *x)
{
	int i, j, low, high;
	mwIndex *ir, *jc;
	double *samples;

	ir = mxGetIr(prhs);
	jc = mxGetJc(prhs);
	samples = mxGetPr(prhs);

	// each column is one instance
	j = 0;
	low = jc[index], high = jc[index+1];
	for(i=low;i<high;i++)
	{
		x[j].index = ir[i] + 1;
		x[j].value = samples[i];
		j++;
 	}
	x[j].index = -1;
}

static void predict_fake_answer(mxArray *plhs[])
{
	plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
	plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

void predict(mxArray *plhs[], const mxArray *prhs[], struct svm_model *model, const int predict_probability)
{
	int label_vector_row_num, label_vector_col_num;
	int feature_number, testing_instance_number;
	int instance_index;
	double *ptr_instance, *ptr_label, *ptr_predict_label; 
	double *ptr_prob_estimates, *ptr_dec_values, *ptr;
	struct svm_node *x;
	mxArray *pplhs[1]; // transposed instance sparse matrix

	int correct = 0;
	int total = 0;
	double error = 0;
	double sumv = 0, sumy = 0, sumvv = 0, sumyy = 0, sumvy = 0;

	int svm_type=svm_get_svm_type(model);
	int nr_class=svm_get_nr_class(model);
	double *prob_estimates=NULL;

	// prhs[1] = testing instance matrix
	feature_number = mxGetN(prhs[1]);
	testing_instance_number = mxGetM(prhs[1]);
	label_vector_row_num = mxGetM(prhs[0]);
	label_vector_col_num = mxGetN(prhs[0]);

	if(label_vector_row_num!=testing_instance_number)
	{
		mexPrintf("# of labels (# of column in 1st argument) does not match # of instances (# of rows in 2nd argument).\n");
		predict_fake_answer(plhs);
		return;
	}
	if(label_vector_col_num!=1)
	{
		mexPrintf("label (1st argument) should be a vector (# of column is 1).\n");
		predict_fake_answer(plhs);
		return;
	}

	ptr_instance = mxGetPr(prhs[1]);
	ptr_label    = mxGetPr(prhs[0]);
	
	// transpose instance matrix
	if(mxIsSparse(prhs[1]))
	{
		if(model->param.kernel_type == PRECOMPUTED)
		{
			// precomputed kernel requires dense matrix, so we make one
			mxArray *rhs[1], *lhs[1];
			rhs[0] = mxDuplicateArray(prhs[1]);
			if(mexCallMATLAB(1, lhs, 1, rhs, "full"))
			{
				mexPrintf("Error: cannot full testing instance matrix\n");
				predict_fake_answer(plhs);
				return;
			}
			ptr_instance = mxGetPr(lhs[0]);
			mxDestroyArray(rhs[0]);
		}
		else
		{
			mxArray *pprhs[1];
			pprhs[0] = mxDuplicateArray(prhs[1]);
			if(mexCallMATLAB(1, pplhs, 1, pprhs, "transpose"))
			{
				mexPrintf("Error: cannot transpose testing instance matrix\n");
				predict_fake_answer(plhs);
				return;
			}
		}
	}

	if(predict_probability)
	{
		if(svm_type==NU_SVR || svm_type==EPSILON_SVR)
			mexPrintf("Prob. model for test data: target value = predicted value + z,\nz: Laplace distribution e^(-|z|/sigma)/(2sigma),sigma=%g\n",svm_get_svr_probability(model));
		else
			prob_estimates = (double *) malloc(nr_class*sizeof(double));
	}

	plhs[0] = mxCreateDoubleMatrix(testing_instance_number, 1, mxREAL);
	if(predict_probability)
	{
		// prob estimates are in plhs[2]
		if(svm_type==C_SVC || svm_type==NU_SVC)
			plhs[2] = mxCreateDoubleMatrix(testing_instance_number, nr_class, mxREAL);
		else
			plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
	}
	else
	{
		// decision values are in plhs[2]
		if(svm_type == ONE_CLASS ||
		   svm_type == EPSILON_SVR ||
		   svm_type == NU_SVR)
			plhs[2] = mxCreateDoubleMatrix(testing_instance_number, 1, mxREAL);
		else
			plhs[2] = mxCreateDoubleMatrix(testing_instance_number, nr_class*(nr_class-1)/2, mxREAL);
	}

	ptr_predict_label = mxGetPr(plhs[0]);
	ptr_prob_estimates = mxGetPr(plhs[2]);
	ptr_dec_values = mxGetPr(plhs[2]);
	x = (struct svm_node*)malloc((feature_number+1)*sizeof(struct svm_node) );
	for(instance_index=0;instance_index<testing_instance_number;instance_index++)
	{
		int i;
		double target,v;

		target = ptr_label[instance_index];

		if(mxIsSparse(prhs[1]) && model->param.kernel_type != PRECOMPUTED) // prhs[1]^T is still sparse
			read_sparse_instance(pplhs[0], instance_index, x);
		else
		{
			for(i=0;i<feature_number;i++)
			{
				x[i].index = i+1;
				x[i].value = ptr_instance[testing_instance_number*i+instance_index];
			}
			x[feature_number].index = -1;
		}

		if(predict_probability) 
		{
			if(svm_type==C_SVC || svm_type==NU_SVC)
			{
				v = svm_predict_probability(model, x, prob_estimates);
				ptr_predict_label[instance_index] = v;
				for(i=0;i<nr_class;i++)
					ptr_prob_estimates[instance_index + i * testing_instance_number] = prob_estimates[i];
			} else {
				v = svm_predict(model,x);
				ptr_predict_label[instance_index] = v;
			}
		}
		else
		{
			v = svm_predict(model,x);
			ptr_predict_label[instance_index] = v;

			if(svm_type == ONE_CLASS ||
			   svm_type == EPSILON_SVR ||
			   svm_type == NU_SVR)
			{
				double res;
				svm_predict_values(model, x, &res);
				ptr_dec_values[instance_index] = res;
			}
			else
			{
				double *dec_values = (double *) malloc(sizeof(double) * nr_class*(nr_class-1)/2);
				svm_predict_values(model, x, dec_values);
				for(i=0;i<(nr_class*(nr_class-1))/2;i++)
					ptr_dec_values[instance_index + i * testing_instance_number] = dec_values[i];
				free(dec_values);
			}
		}

		if(v == target)
			++correct;
		error += (v-target)*(v-target);
		sumv += v;
		sumy += target;
		sumvv += v*v;
		sumyy += target*target;
		sumvy += v*target;
		++total;
	}
	if(svm_type==NU_SVR || svm_type==EPSILON_SVR)
	{
		mexPrintf("Mean squared error = %g (regression)\n",error/total);
		mexPrintf("Squared correlation coefficient = %g (regression)\n",
			((total*sumvy-sumv*sumy)*(total*sumvy-sumv*sumy))/
			((total*sumvv-sumv*sumv)*(total*sumyy-sumy*sumy))
			);
	}
	else
		//mexPrintf("Accuracy = %g%% (%d/%d) (classification)\n",
		//	(double)correct/total*100,correct,total);

	// return accuracy, mean squared error, squared correlation coefficient
	plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);
	ptr = mxGetPr(plhs[1]);
	ptr[0] = (double)correct/total*100;
	ptr[1] = error/total;
	ptr[2] = ((total*sumvy-sumv*sumy)*(total*sumvy-sumv*sumy))/
				((total*sumvv-sumv*sumv)*(total*sumyy-sumy*sumy));

	free(x);
	if(prob_estimates != NULL)
		free(prob_estimates);
}

void predict_exit_with_help()
{
	mexPrintf(
	"Usage: [predicted_label, accuracy, decision_values/prob_estimates] = svmpredict(testing_label_vector, testing_instance_matrix, model, 'libsvm_options')\n"
	"libsvm_options:\n"
	"-b probability_estimates: whether to predict probability estimates, 0 or 1 (default 0); one-class SVM not supported yet\n"
	);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///   LIBSVM INTERFACE CODE
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void optClearData() 
{
	if (verbose) mexPrintf("Clearing data\n");

	if (!gotData)
	{
		mexPrintf("libsvm error (optClearData): Data not loaded\n");
		return;
	}

	free(prob.y);
	free(prob.x);
	free(x_space);
	svm_destroy_param(&param);
	prob.y = 0;
	prob.x = 0;
	x_space = 0;
	gotData = false;
}

void optSetData(int nrhs, const mxArray * * prhs, mxArray * * plhs, const char * error_msg) 
{
	if (verbose) mexPrintf("Setting data\n");
	// Translate the input Matrix to the format such that svmtrain.exe can recognize it
	if(nrhs > 0 && nrhs < 4)
	{
		int err;

		if (gotData)
			optClearData();

		if(parse_command_line(nrhs, prhs, NULL))
		{
			svm_destroy_param(&param);
			train_fake_answer(plhs);
			return;
		}

		if(mxIsSparse(prhs[1]))
		{
			if(param.kernel_type == PRECOMPUTED)
			{
				// precomputed kernel requires dense matrix, so we make one
				mxArray *rhs[1], *lhs[1];

				rhs[0] = mxDuplicateArray(prhs[1]);
				if(mexCallMATLAB(1, lhs, 1, rhs, "full"))
				{
					mexPrintf("libsvm error (optSetData): cannot generate a full training instance matrix\n");
					svm_destroy_param(&param);
					train_fake_answer(plhs);
					return;
				}
				err = read_problem_dense(prhs[0], lhs[0]);
				mxDestroyArray(lhs[0]);
				mxDestroyArray(rhs[0]);
			}
			else
				err = read_problem_sparse(prhs[0], prhs[1]);
		}
		else
			err = read_problem_dense(prhs[0], prhs[1]);

		// svmtrain's original code
		error_msg = svm_check_parameter(&prob, &param);
		gotData = true;

		if(err || error_msg)
		{
			if (error_msg != NULL)
				mexPrintf("libsvm error (optSetData): %s\n", error_msg);
			optClearData();
			train_fake_answer(plhs);
			return;
		}

		nr_feat = mxGetN(prhs[1]);
		gotData = true;
	}
	else
	{
		mexPrintf("libsvm error (optSetData): Invalid number of parameters %d\n", nrhs);
		train_fake_answer(plhs);
	}
}

void optDestroyModel() 
{
	if (verbose) mexPrintf("Destroying model\n");

	if (!gotModel)
	{
		mexPrintf("libsvm error (optDestroyModel): Model not loaded\n");
		return;
	}

	svm_destroy_model(model);
	model = 0;
	gotModel = false;
	isLoaded = false;
}

void optTrain(mxArray * * plhs) 
{
	const char *error_msg;

	if (verbose) mexPrintf("Training %d\n", nr_feat);

	if (!gotData)
	{
		mexPrintf("libsvm error (optTrain): Data not loaded\n");
		train_fake_answer(plhs);
		return;
	}
	
	if (gotModel)
		optDestroyModel();

	model = svm_train(&prob, &param);
	isLoaded = false;
	gotModel = true;
}

void optExportModel(const char * error_msg, mxArray * * plhs) 
{
	if (verbose) mexPrintf("Exporting model %d\n", nr_feat);

	if (!gotModel || (!gotData && !isLoaded))
	{
		mexPrintf("libsvm error (optExportModel): Model or data not loaded, both needed\n");
		train_fake_answer(plhs);
		return;
	}

	error_msg = model_to_matlab_structure(plhs, nr_feat, model);
	if(error_msg)
		mexPrintf("libsvm error (optExportModel): can't convert libsvm model to matrix structure: %s\n", error_msg);
}

void optPredict(int nrhs, mxArray * * plhs, const mxArray * * prhs, int *prob_estimate_flag, const char * error_msg) 
{
	if (verbose) mexPrintf("Predicting\n");
	if(nrhs > 3 || nrhs < 2)
	{
		predict_exit_with_help();
		predict_fake_answer(plhs);
		return;
	}

	// parse options
	if(nrhs==3)
	{
		int i, argc = 1;
		char cmd[CMD_LEN], *argv[CMD_LEN/2];

		// put options in argv[]
		mxGetString(prhs[2], cmd,  mxGetN(prhs[2]) + 1);
		if((argv[argc] = strtok(cmd, " ")) != NULL)
			while((argv[++argc] = strtok(NULL, " ")) != NULL)
				;

		for(i=1;i<argc;i++)
		{
			if(argv[i][0] != '-') break;
			if(++i>=argc)
			{
				predict_exit_with_help();
				predict_fake_answer(plhs);
				return;
			}
			switch(argv[i-1][1])
			{
			case 'b':
				*prob_estimate_flag = atoi(argv[i]);
				break;
			default:
				mexPrintf("libsvm error (optPredict): unknown option\n");
				predict_exit_with_help();
				predict_fake_answer(plhs);
				return;
			}
		}
	}

	// Already have model saved
	// model = matlab_matrix_to_model(prhs[2], &error_msg);
	if (model == NULL || !gotModel || (!gotData && !isLoaded))
	{
		mexPrintf("libsvm error (optPredict): can't read model or data, both needed\n");
		predict_fake_answer(plhs);
		return;
	}

	if(*prob_estimate_flag)
	{
		if(svm_check_probability_model(model)==0)
		{
			mexPrintf("Model does not support probabiliy estimates\n");
			predict_fake_answer(plhs);
			svm_destroy_model(model);
			return;
		}
	}
	else
	{
		if(svm_check_probability_model(model)!=0)
			printf("Model supports probability estimates, but disabled in predicton.\n");
	}

	predict(plhs, prhs, model, *prob_estimate_flag);
}

void optSave(int nrhs, const mxArray * * prhs) 
{
	char filename[256];
	if (verbose) mexPrintf("Saving model\n");

	if (!gotData || (!gotModel && !isLoaded))
	{
		mexPrintf("libsvm error (optSave): Must have model and data to save\n");
		return;
	}
	if (nrhs != 1)
	{
		mexPrintf("libsvm error (optSave): Filename expected!\n");
		return;
	}
	
	mxGetString(prhs[0], filename, (mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar)) + 1);
	if (svm_save_model(filename, model))
	{
		mexPrintf("libsvm error (optSave): Unable to save svm model %s!\n", filename);
	}
}

void optLoad(int nrhs, const mxArray * * prhs) 
{
	char filename[256];
	if (verbose) mexPrintf("Loading model\n");
	if (gotData)
	{
		optClearData();
	}
	if (gotModel)
	{
		optDestroyModel();
	}
	if (nrhs != 1)
	{
		mexPrintf("libsvm error (optLoad): Filename expected!\n");
		return;
	}

	mxGetString(prhs[0], filename, (mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar)) + 1);
	gotModel = false;
	model = svm_load_model(filename);
	if (model)
	{
		gotModel = true;
		isLoaded = true;
	}
	else
	{
		mexPrintf("libsvm error (optLoad): Unable to load svm model %s!\n", filename);
	}
}

// Interface function of matlab
// now assume prhs[0]: label prhs[1]: features
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	const char *error_msg;
	int prob_estimate_flag = 0;

	// fix random seed to have same results for each run
	// (for cross validation and probability estimation)
	srand(1);

	// Null stuff out
	if (first)
	{
		x_space = 0;
		prob.x = 0;
		prob.y = 0;
		first = false;
	}

	if (nrhs >= 1)
	{
		// Get the first option and then pretend it doesn't exist
		int option = (int)mxGetScalar(prhs[0]);
		nrhs--;
		prhs++;

		if (verbose) mexPrintf("libsvm option = %d\n", option);

		if (option == OPT_SET_DATA)
		{
			optSetData(nrhs, prhs, plhs, error_msg);
		}
		else if (option == OPT_TRAIN)
		{
			optTrain(plhs);
		}
		else if (option == OPT_CLEAR_DATA)
		{
			optClearData();
		}
		else if (option == OPT_CLEAR_MODEL)
		{
			optDestroyModel();
		}
		else if (option == OPT_EXPORT_MODEL)
		{
			optExportModel(error_msg, plhs);
		}
		else if (option == OPT_PREDICT)
		{
			optPredict(nrhs, plhs, prhs, &prob_estimate_flag, error_msg);
		}
		else if (option == OPT_CLEAR)
		{
			if (gotData)
				optClearData();
			if (gotModel)
				optDestroyModel();
		}
		else if (option == OPT_SAVE)
		{
			optSave(nrhs, prhs);
		}
		else if (option == OPT_LOAD)
		{
			optLoad(nrhs, prhs);
		}
		else
		{
			mexPrintf("libsvm error (mexFunction): Invalid option %d\n", option);
			train_fake_answer(plhs);
		}
	}
}
