	SUBROUTINE CONTOR(Z,NZ,IZ,MX,MY,X1,XMX,Y1,YMY,NL,CL)
C
C	THIS SUBROUTINE WILL PRODUCE A CONTOUR PLOT OF THE FUNCTION
C	DEFINED BY Z(I,J) = F(X(I),Y(J)).   IT IS ASSUMED THAT
C	A CALL TO "MAPIT" HAS ALREADY BEEN MADE TO ESTABLISH THE
C	COORDINATE AXIS (X,Y), WITH X LIMITS COVERING THE RANGE
C	X1 TO XMX, AND Y LIMITS COVERING THE RANGE Y1 TO YMY.
C
C	Bad bug fixed: 23-APR-1985 by Hal R. Brand
C
CArguments:
C
C  Input
C
C	Z		* Type: real 2D array.
C			* The values of the function to contour:
C			   Z(I,J) = F(Xi,Yj) where:
C			     Xi = X1 + (i-1)*(XMX-X1)/(MX-1)
C			     Yj = Y1 + (j-1)*(YMX-Y1)/(MY-1)
C
C	NZ		* Type: integer constant or variable.
C			* The first dimension of the array Z - not necessarily
C				equal to MX, but MX <= NZ.
C
C	IZ		* Type: integer*2 2D array.
C			* Used internally for working storage. Should be
C				dimensioned same as the Z array.
C
C	MX 		* Type: integer constant or variable.
C			* The number of X grid points.
C
C	MY		* Type: integer constant or variable.
C			* The number of Y grid points.
C
C	X1		* Type: real constant or variable.
C			* The minimum X value.
C
C	XMX		* Type: real constant or variable.
C			* The maximum X value.
C
C	Y1		* Type: real constant or variable.
C			* The minimum Y value.
C
C	YMY		* Type: real constant or variable.
C			* The maximum Y value.
C
C	NL		* Type: integer constant or variable.
C			* The number of contour levels.
C
C	CL		* Type: real array.
C			* The coutour levels to draw.   (Same units as
C				F() or Z().)
C
C  Output
C
C    None.
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
	DIMENSION Z(NZ,MY)
	DIMENSION CL(NL)
	INTEGER*2 IZ(MX,MY)
	COMMON /CONTR/ CLEVEL,IOLD,JOLD,IN,JN,
     1   NX,NY,XL,DX,YL,DY
C
C	INITIALIZE ROUTINE
C
	XL = X1
	YL = Y1
	DX = XMX-X1
	DY = YMY-Y1
	NX=MX
	NY=MY
	NLOOP=MIN1(FLOAT(NX)/2.0+.5,FLOAT(NY)/2.0+.5)
C	START SEARCHING FOR PLUS-MINUS TRANSITIONS
C	TO START A CONTOR ON.
        icolor = 0
	DO 50 NC=1,NL
        icolor = icolor+1
        if (icolor.GT.7)  icolor=1
        Call GsColr(icolor,err)
C
C	ZERO ARRAY SHOWING WHERE WE HAVE BEEN
C
	DO 2 J=1,NY
		DO 1 I=1,NX
			IZ(I,J)=0
1			CONTINUE
2		CONTINUE
	CLEVEL=CL(NC)
	DO 50 ICIR=1,NLOOP
		IU=NX+1-ICIR
		JU=NY+1-ICIR
		DO 10 J=ICIR,JU-1
			CALL LOOK(Z,ICIR,J,1,IZ,NZ,NX)
10			CONTINUE
		DO 20 I=ICIR,IU-1
			CALL LOOK(Z,I,JU,2,IZ,NZ,NX)
20			CONTINUE
		DO 30 J=JU,ICIR+1,-1
			CALL LOOK(Z,IU,J,3,IZ,NZ,NX)
30			CONTINUE
		DO 40 I=IU,ICIR+1,-1
			CALL LOOK(Z,I,ICIR,4,IZ,NZ,NX)
40			CONTINUE
50		CONTINUE
	RETURN
	END
C
C
C
	SUBROUTINE LOOK(Z,II,JJ,M,IZ,NZ,IZDIM)
	INTEGER IZ(IZDIM,2)
	DIMENSION Z(NZ,2)
C
C	This subroutine looks for a contour starting at the point (II,JJ)
C	with the contour being oriented such that the point (II,JJ) is
C	greater than the current contouring level, and its neighbor (specified
C	by M) is less than the current contouring level.
C
	COMMON /CONTR/ CLEVEL,IOLD,JOLD,IN,JN,
     1   NX,NY,XL,DX,YL,DY
	DIMENSION IDMODE(3,4)
	DATA IDMODE/4,1,2,  1,2,3,  2,3,4,  3,4,1/
C
	IOLD=II
	JOLD=JJ
	MODE=M
	CALL NEWP(1,MODE)
C
C	LOOK FOR CONTOR STARTING HERE.   THE "OLD" POINT IS ALWAYS THE
C	 POSITIVE ONE, SO THE TEST IS EASY.
C
	IF (Z(IOLD,JOLD) .GE. CLEVEL .AND. Z(IN,JN) .LT. CLEVEL) GOTO 20
	RETURN
C
C	CHECK FOR CONTOR PREVIOUSLY THRU HERE - "SEGMNT" RETURNS THE POINT
C	 WE MARK WHEN EVER A CONTOUR PASSES THRU THE POINTS "(IOLD,JOLD)"
C	 AND "(IN,JN)".   "SEGMNT" ALSO RETURNS THE MARK THAT SHOULD BE
C	 PLACED GIVEN THE ORIENTATION OF THE CONTOUR.
C
20	CALL SEGMNT(ICI,ICJ,ISEG)
	IF (iand(IZ(ICI,ICJ),ISEG) .NE. 0) RETURN
C
C	NEW CONTOUR.   TRACE IT TILL IT ENDS BY LOOPING BACK ON ITSELF, OR
C	 RUNNING OFF THE GRID.
C
	CALL ZPNT(XX,YY,Z,NZ)
	CALL SCALE(XX,YY,VX,VY)
	CALL GSMOVE(VX,VY)
	IOLD=IN
	JOLD=JN
30		CONTINUE
		DO 50 N=2,4
			CALL NEWP(N,MODE)
			IF (IN .LT. 1 .OR. IN .GT. NX) RETURN
			IF (JN .LT. 1 .OR. JN .GT. NY) RETURN
			IF (SIGN(1.0,Z(IOLD,JOLD)-CLEVEL) .NE.
     1			  SIGN(1.0,Z(IN,JN)-CLEVEL)) GO TO 60
			IOLD=IN
			JOLD=JN
50			CONTINUE
C
C	IT IS IMPOSSIBLE TO JUST FALL THRU DUE TO THE ALGORITHM
C
		STOP 'SERIOUS ERROR'
60		CONTINUE
C
C	FOUND THE NEXT INTERSECTION.   SEE IF IT HAS ALREADY BEEN MARKED.
C	 IF SO, THEN WE ARE DONE, ELSE, MARK IT, DRAW TO IT, AND CONTINUE ON.
C
		CALL SEGMNT(ICI,ICJ,ISEG)
		IF (iand(IZ(ICI,ICJ),ISEG) .NE. 0) RETURN
		IZ(ICI,ICJ)=ior(IZ(ICI,ICJ),ISEG)
		CALL ZPNT(XX,YY,Z,NZ)
		CALL SCALE(XX,YY,VX,VY)
		CALL GSDRAW(VX,VY)
		MODE=IDMODE(N-1,MODE)
		GO TO 30
	END
C
C
C
	SUBROUTINE SEGMNT(ICI,ICJ,ISEG)
	COMMON /CONTR/ CLEVEL,IOLD,JOLD,IN,JN,
     1   NX,NY,XL,DX,YL,DY
	ICI=MIN0(IOLD,IN)
	ICJ=MIN0(JOLD,JN)
	ISEG=1
	IF (IOLD .EQ. IN) ISEG=2
	RETURN
	END
C
C
C
	SUBROUTINE NEWP(I,M)
	COMMON /CONTR/ CLEVEL,IOLD,JOLD,IN,JN,
     1   NX,NY,XL,DX,YL,DY
	DIMENSION IDELI(4),JDELJ(4)
	DATA IDELI,JDELJ / 0,1,0,-1,   1,0,-1,0/
	INDEX=MOD(2+I+M,4)+1
	IN=IOLD+IDELI(INDEX)
	JN=JOLD+JDELJ(INDEX)
	RETURN
	END
C
C
C
	SUBROUTINE ZPNT(X,Y,Z,NZ)
	DIMENSION Z(NZ,2)
	COMMON /CONTR/ CLEVEL,IOLD,JOLD,IN,JN,
     1   NX,NY,XL,DX,YL,DY
	A=Z(IN,JN)-Z(IOLD,JOLD)
C	IF NO CHANGE IN Z'S, PICK OLD POINT SO AS TO STAY TO RIGHT
	IF (A .EQ. 0.0) GO TO 10
	A=(CLEVEL-Z(IOLD,JOLD))/A
10	X=A*(IN-IOLD)+IOLD
	Y=A*(JN-JOLD)+JOLD
C	NOW CONVERT INDEXS TO X,Y VALUES
	X=(X-1.0)*DX/(NX-1)+XL
	Y=(Y-1.0)*DY/(NY-1)+YL
	RETURN
	END