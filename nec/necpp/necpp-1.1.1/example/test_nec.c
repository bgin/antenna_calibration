#include "nec.h"
#include <stdio.h>

/*
	Enter the following file into test_nec.c, and compile with
	gcc -o test_nec test_nec.c -L . -lnecpp -lm -lstdc++
*/
int main(int argc, char **argv)
{
	nec_context* nec;
	double gain;

	nec = nec_create();
	nec_wire(nec, 0, 36, 0, 0, 0, -0.042, 0.008, 0.017, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 21, -0.042, 0.008, 0.017, -0.048, 0.021, -0.005, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 70, -0.048, 0.021, -0.005, 0.039, 0.032, -0.017, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 70, -0.048, 0.021, -0.005, 0.035, 0.043, 0.014, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 50, -0.042, 0.008, 0.017, 0.017, -0.015, 0.014, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 66, 0.017, -0.015, 0.014, -0.027, 0.04, -0.031, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 85, -0.027, 0.04, -0.031, 0.046, -0.01, 0.028, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 47, 0.046, -0.01, 0.028, -0.013, -0.005, 0.031, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 70, 0.017, -0.015, 0.014, -0.048, -0.038, -0.04, 0.001, 1.0, 1.0);
	nec_wire(nec, 0, 77, -0.048, -0.038, -0.04, 0.049, -0.045, -0.04, 0.001, 1.0, 1.0);
	nec_geometry_complete(nec, 0, 0);

	nec_gn_card(nec, -1, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	nec_ld_card(nec, 5, 0, 0, 0,3.72e7, 0.0, 0.0);
	nec_pt_card(nec, -1, 0, 0, 0);
	nec_ex_card(nec, 1, 1, 1, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	nec_fr_card(nec, 0, 2, 2400.0, 100.0);
	nec_rp_card(nec, 0, 1, 1, 500, 90.0, 90.0, 0.0, 0.0, 0.0, 0.0);
	gain = nec_get_maximum_gain(nec);

	nec_delete(nec);

	printf("Gain is %f dB\n",gain);

	return 0;
}
