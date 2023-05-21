#ifndef	MTS_LIBHEADER_H
#define	MTS_LIBHEADER_H

//#include	"dump.h"


typedef struct S_MTS_INOUT {
	long in_time; /* sec */
	long in_frame; /* # fame */
 	long out_time; /* sec */ 
 	long out_frame; /* # frame */
} MTS_INOUT;


#define MTS_STAT_NONE			0x0000
#define MTS_STAT_RUN			0x0001
#define MTS_STAT_STATUS			0x00E
#define MTS_STAT_ERR_CODE		0x0FF0	// TAB
#define MTS_STATE_ERR_OPEN1		0x0010	// fopen source file error
#define MTS_STATE_ERR_OPEN2		0x0020	// fopen target file error
#define MTS_STATE_ERR_READ		0x0030	// fread source file error
#define MTS_STATE_ERR_WRITE 	0x0040  // fwrtie target file error
#define MTS_STATE_ERR_MEMORY	0x0100	// malloc/free error
#define MTS_STATE_ERR_MTS		0x0200	// MTS analyz error
#define MTS_STATE_ERR_HEADER	0x0400	// header error

#define	MTS_STATE_ERR_TSOVER	0x0800	// TS Rate too high
#define	MTS_STATE_ERR_TSUNDER	0x1000	// TS Rate too low
#define	MTS_STATE_ERR_MPOVER	0x2000	// MPEG Rate too high
#define	MTS_STATE_ERR_MPUNDER	0x4000	// MPEG Rate too low
#define	MTS_STATE_ERR_SIPSI		0x8000	// SI/PSI error

typedef struct S_MTS_STATUS { 
	long status;
	long counter;
	long totalcount;
}MTS_STATUS;

#define	MTS_FLAG_STOP			0x1000
#define	MTS_FLAG_START			0x2000

typedef struct S_MTS_FLAG {
	unsigned long flag;
} MTS_FLAG;

/*
 *
 */
typedef struct  MY_THREAD_INOUTARG{	
	char inFilename[512];
	char outFilename[512];	
	MTS_INOUT *List;
	int ListCnt;
	long duration;	// sec
} THREAD_INOUTARG;

typedef struct MY_THREAD_SPLITARG{	
	char inFilename[512];
	char outFilename[512];	
	int SplitCnt;
	long duration;	// sec
} THREAD_SPLITARG;


typedef struct  MY_THREAD_JOINARG{	
	char inFilename[512];
	char outFilename[512];	
	long duration;	// sec
} THREAD_JOINARG;

extern int *MTS_Start ( void *arg );  /* MTS_Start( THREAD_INOUTARG *) */
extern void MTS_GetStatus( int *status, int *counter, int *totalcount ); 
extern int MTS_GetStatusCounter( );
extern int MTS_GetFlag(  );
extern void MTS_PutStatus( int status );
extern void MTS_PutStatusCounter( int counter );
extern void MTS_PutStatusTotalCount( int totalcount );
extern void MTS_StatusCountDown( int countdown );
extern void MTS_PutFlag( int flg);
extern int	*MTS_Split( void *arg);  /* MTS_Split( THREAD_SPLITARG *) */

extern int	MTS_JoinOpenOutput( char *outFilename );
extern int 	MTS_JoinCloseOutput( );
extern int	*MTS_Join ( void  *arg );

#endif
