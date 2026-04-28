#ifndef __KERNEL_SOCKET_H
#define __KERNEL_SOCKET_H
#include "kernel_streams.h"
#include "tinyos.h"
#include "kernel_pipe.h"


typedef struct socket_control_block socket_cb;

typedef enum socket_type
{
	UNBOUND,
	LISTENER,
	PEER
}socket_type;

//Domh unbound socket
typedef struct unbound_socket
{
	rlnode unbound_socket;

}unbound_socket;

//Domh listener socket
typedef struct listener_socket 
{
	rlnode queue;
	CondVar req_available; //Tha koimatai to accept edw
}listener_socket;


//Domh peer socket
typedef struct peer_socket
{
	socket_cb *peer; //WEAK POINTER deixnei me poio socket enothike
	pipe_cb *write_pipe; //send
	pipe_cb *read_pipe; //recv	
	//int canWrite;
	//int canRead;
}peer_socket;


typedef union socket_type_union
{
	unbound_socket  unbound_s;
	listener_socket  listener_s;
	peer_socket peer_s;	
}SOCK_TYPE_U;



typedef struct socket_control_block{

	Fid_t fid; //fid of this socket

	FCB *fcb; //The file control block for this socket

	socket_type type; //Type of this socket

	SOCK_TYPE_U sock_uni;

	int refcount;  

	port_t port;
}socket_cb;


socket_cb* PORT_MAP [MAX_PORT+1];// arxikopoihsh tou port map sto socket.c se NULL

//Domh tou connection request
typedef struct conn_req
{
	int  admitted; //Otan ginei ena mas leei oti to socket eksipireteitai   or integer if it was succedeed????
	socket_cb* peer;//poio socket kanei request   (thumomaste asteraki)
	CondVar connected_cv; //otan ginei connection ginetai signaled
	rlnode  queue_node;
}REQ;


REQ* initialize_request_Block();
void initialize_PT();

#endif