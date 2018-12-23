function mosekoutput(info)

fprintf(1,'\n=============== Mosek termination measures ================\n');

fprintf(1,'Primal:\n');
fprintf(1,' Objective values: %.4e\n', info.MSK_DINF_SOL_ITR_PRIMAL_OBJ);
fprintf(1,' Equality constraint infeasibility: %.2e\n',info.MSK_DINF_SOL_ITR_MAX_PEQI);
fprintf(1,' Bound constraint infeasibility: %.2e\n',info.MSK_DINF_SOL_ITR_MAX_PBI);
fprintf(1,' Cone constraint infeasibility: %.2e\n',info.MSK_DINF_SOL_ITR_MAX_PCNI);

fprintf(1,'Dual:\n');
fprintf(1,' Objective values: %.4e\n', info.MSK_DINF_SOL_ITR_DUAL_OBJ);
fprintf(1,' Equality constraint infeasibility: %.2e\n',info.MSK_DINF_SOL_ITR_MAX_DEQI);
fprintf(1,' Bound constraint infeasibility: %.2e\n',info.MSK_DINF_SOL_ITR_MAX_DBI);
fprintf(1,' Cone constraint infeasibility: %.2e\n',info.MSK_DINF_SOL_ITR_MAX_DCNI);

gap = info.MSK_DINF_SOL_ITR_PRIMAL_OBJ-info.MSK_DINF_SOL_ITR_DUAL_OBJ;
fprintf(1,'Duality:\n');
fprintf(1,' Gap: %.4e\n', gap);
fprintf(1,' Significant digits: %.2e\n', gap/(1+abs(info.MSK_DINF_SOL_ITR_DUAL_OBJ)));
