	SUBROUTINE TRACEC(X,Y,NPTS)
	DIMENSION X(NPTS), Y(NPTS)
C
C	THIS SUBROUTINE TRACES THE LINE FROM X(1),Y(1) TO
C	X(NPTS),Y(NPTS) WITH APPROPIATE CLIPPING.
C
	DIMENSION AREA(4)
C
	CALL MPCLIP(AREA)
	CALL SCALE(X(1),Y(1),VX,VY)
	CALL GSMOVE(VX,VY)
10	DO 100 I=2,NPTS
	CALL SCALE(X(I),Y(I),VX,VY)
	CALL GSDRAW(VX,VY)
100	CONTINUE
	CALL GSRCLP(AREA)
	RETURN
	END
