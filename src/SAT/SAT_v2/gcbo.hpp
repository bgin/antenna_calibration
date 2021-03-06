//
// MATLAB Compiler: 3.0
// Date: Wed Jul 14 15:58:49 2004
// Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
// "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
// "array_indexing:on" "-O" "optimize_conditionals:on" "-p" "-W" "main" "-L"
// "Cpp" "-t" "-T" "link:exe" "-h" "libmmfile.mlib" "test2" 
//
#ifndef __gcbo_hpp
#define __gcbo_hpp 1

#include "libmatlb.hpp"

extern void InitializeModule_gcbo();
extern void TerminateModule_gcbo();
extern _mexLocalFunctionTable _local_function_table_gcbo;

extern mwArray Ngcbo(int nargout, mwArray * fig);
extern mwArray gcbo(mwArray * fig);
extern void Vgcbo();
#ifdef __cplusplus
extern "C"
#endif
void mlxGcbo(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#endif
