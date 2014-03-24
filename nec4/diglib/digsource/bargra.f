	SUBROUTINE BARGRA(XLOW,XHIGH,NOBARS,IMXPTS,X,
     1                 SXLAB,SYLAB,STITLE,TYPE)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C	PROJECT NAME: GRAPHICS UTILITY
C	FILE NAME   : BARGRA.FOR
C	ROUTINE NAME: BARGRA
C	ROUTINE TYPE: SUBROUTINE
C	LANGUAGE    : COMPATIBLE FORTRAN
C
C	VERSION     : 1
C
C	ORIGINAL AUTHOR: JOE P GARBARINI JR
C	DATE           : 02-JUL-82
C
C	MAINTAINER     : HAL R BRAND L126 X26313 (DIGLIB V2 VERSION)
C
C	REVISION: 0
C	  REVISION AUTHOR:
C	  REVISION DATE  :
C	  REVISION NOTES :
C
C	SUMMARY:
C
C		This routine makes a bar graph (frequency graph)
C		from an array of real data.
C
C	INPUT VARIABLES:
C
C		XLOW  : REAL*4 CONSTANT OR VARIABLE.
C			THE LOW LIMIT FOR THE X-AXIS.
C			MUST HAVE XLOW <= X(I) FOR ALL I.
C		XHIGH : REAL*4 CONSTANT OR VARIABLE.
C			THE HIGH LIMIT FOR THE X-AXIS.
C			MUST HAVE X(I) <= XHIGH FOR ALL I.
C		NOBARS: INTEGER CONSTANT OR VARIABLE.
C			THE NUMBER OF BARS TO DRAW.
C			1 <= *NOBARS* <= 200
C			SEE LOCAL VARIABLE *IMXC*.
C		IMXPTS: INTEGER CONSTANT OR VARIABLE.
C			THE DIMESION OF ARRAY *X*.
C		X     : REAL*4 VARIABLE.
C			THE ARRAY OF REAL DATA TO GRAPH.
C		SXLAB : LOGICAL CONSTANT OR VARIABLE.
C			THE X-AXIS LABLE.
C		SYLAB : LOGICAL CONSTANT OR VARIABLE.
C			THE Y-AXIS LABLE.
C		STITLE: LOGICAL CONSTANT OR VARIABLE.
C			THE TITLE.
C		TYPE  : INTEGER CONSTANT OR VARIABLE.
C			THE AXIS FLAG.  SEE *DIGLIB* DOCUMENTATION.
C
C	OUTPUT VARIABLES: NONE
C
C	INOUT VARIABLES: NONE
C
C	COMMON VARIABLES: NONE
C
C	LOCAL VARIABLES: SEE CODE.
C
C	EXCEPTION HANDLING: NONE
C
C	SIDE EFFECTS: NONE
C
C	PROGRAMMING NOTES:
C
C		This routine does all the calls to DIGLIB necessary
C		to do the plot EXCEPT for a call to DEVSEL.  This
C		way the calling program can choose the device.
C
C		DIGLIB's MAPIT routine uses its own rules for the
C		actual lowest and highest values on the axes.  They
C		always include the users values.  If you wish to move
C		the bar graph away from the left and/or (imaginary) right
C		y axis do the following:
C
C		Let S = (XH - XL) / NOBARS where XH = max X(i)
C		and XL = min X(i).  Now set XLOW = XL - N * S
C		XHIGH = XH + M * S where N,M are chosen at your discretion.
C
C		MAKE SURE THAT XLOW <= X(I) <= XHIGH FOR ALL I.
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
	INTEGER IMXPTS,NOBARS,TYPE
	REAL*4    XLOW,XHIGH
	REAL*4    X
	DIMENSION X(IMXPTS)
	LOGICAL SXLAB(20),SYLAB(20),STITLE(20)
C
	INTEGER I,J,IMXC
	REAL*4    COUNT(200),STEP,FBAR,YLOW,YHIGH,X0,Y0,VX0,VX1
	REAL*4    VY0,VY1,FIMX
C
	IMXC   = 200
	YLOW   = 0.0
	YHIGH  = 1.0
	FBAR   = FLOAT(NOBARS)
C
	IF (XLOW .GE. XHIGH) GOTO 9999
	IF (NOBARS .GT. IMXC) GOTO 9999
C
	STEP   = (XHIGH - XLOW) / FBAR
C
	DO 100 I = 1,NOBARS
C
	    COUNT(I) = 0.0
C
 100	CONTINUE
C
	DO 200 I = 1,IMXPTS
C
	    J      = INT((X(I)-XLOW)/STEP)+1
	    IF (J .GT. NOBARS) J = NOBARS
	    COUNT(J) = COUNT(J) + 1.0
C
 200	CONTINUE
C
	FIMX   = FLOAT(IMXPTS) * STEP
C
	DO 300 I = 1,NOBARS
C
	    COUNT(I) = COUNT(I) / FIMX
C
 300	CONTINUE
C
	CALL MINMAX(COUNT,NOBARS,YLOW,YHIGH)
	YLOW   = 0.0
	YHIGH  = YHIGH + 0.1 * YHIGH
C
	CALL BGNPLT
	CALL MAPSIZ(0.0,100.0,0.0,100.0,0.0)
	CALL MAPIT(XLOW,XHIGH,YLOW,YHIGH,SXLAB,SYLAB,STITLE,TYPE)
C
	X0     = XLOW
	Y0     = 0.0
	CALL SCALE(X0,Y0,VX0,VY0)
	CALL GSMOVE(VX0,VY0)
C
	DO 400 I = 1,NOBARS
C
	    X0     = XLOW + I * STEP
	    Y0     = COUNT(I)
	    CALL SCALE(X0,Y0,VX1,VY1)
	    CALL GSDRAW(VX0,VY1)
	    CALL GSDRAW(VX1,VY1)
	    CALL GSDRAW(VX1,VY0)
C
	    VX0    = VX1
C
 400	CONTINUE
C
	CALL ENDPLT
C
 9999	CONTINUE
C
C	BYE
C
	RETURN
	END