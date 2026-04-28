#ifndef __KERNEL_PIPE_H
#define __KERNEL_PIPE_H
#include "kernel_streams.h"
#define PIPE_BUFFER_SIZE 8192

typedef struct pipe_control_block {
	FCB *reader, *writer;
	CondVar has_space;    /* For blocking writer if no space is available */ //cv_empty
	CondVar has_data;     /* For blocking reader until data are available */ //cv_full
	int w_position, r_position;  /* write, read position in buffer (it depends on your implementation of bounded buffer, i.e. alternatively pointers can be used)*/
	char BUFFER[PIPE_BUFFER_SIZE];   /* bounded (cyclic) byte buffer */
} pipe_cb;

int pipe_write(void* pipecb_t, const char *buf, uint n);
int pipe_read(void* pipecb_t, char *buf, uint n);
int pipe_writer_close(void* pipe);
int pipe_reader_close(void* pipe);

pipe_cb* initialize_Pipe_Control_Block(FCB** fcb);

#endif