#include "tinyos.h"
#include "kernel_pipe.h"
#include "kernel_streams.h"
#include "kernel_cc.h"
#include "util.h"
#include "kernel_socket.h"


socket_cb* initialize_socket_control_block(FCB** fcb,port_t port){

	socket_cb*  socket1 = (socket_cb*)xmalloc(sizeof(socket_cb));
    
	socket1->fcb = fcb[0];//The file control block for this socket
	socket1->port= port;//The port of this socket.
	socket1->type =UNBOUND;//The type of this socket.

	socket1->refcount = 1;
	
	return socket1;
}

void initialize_PT(){

for (int i = 0; i < MAX_PORT; i++)
    	{  // arxikopoihsh tou port map sto socket.c se NULL,ginetai sto bootarisma ,kernel_init
			PORT_MAP[i] = NULL;
			}

}


//Gia na kanei read to socket mesw tou pipe
int socket_read(void* socket, char *buf, unsigned int size){

	socket_cb*  socket1 = (socket_cb*)socket;

	if(socket == NULL ||socket1->type != PEER){ //An to sokcet einai NULL h an den einai peer socket apotyxia 
		return -1;
	}
	else if (socket1->sock_uni.peer_s.read_pipe == NULL) //An to akro read tou pipe einai kleisto apotyxia
	{
		return -1;
	}

	int temp = 0;
	temp = pipe_read(socket1->sock_uni.peer_s.read_pipe, buf, size);

	return temp;
}


//Gia na kanei write to socket mesw tou pipe
int socket_write(void* socket, const char *buf, unsigned int size){

	socket_cb*  socket1 = (socket_cb*)socket;

	if(socket == NULL ||socket1->type != PEER){ //An to sokcet einai NULL h an  den einai peer socket apotyxia 
		return -1;
	}
	else if (socket1->sock_uni.peer_s.write_pipe == NULL) //An to akro write tou pipe einai kleisto
	{
		return -1;
	}

	int temp = 0;
	temp = pipe_write(socket1->sock_uni.peer_s.write_pipe, buf, size);

	return temp;
}


int socket_close(void* socket){

	socket_cb* socket1=(socket_cb*)socket; 

	if(socket1->type==LISTENER || socket1->type==UNBOUND){
		PORT_MAP[socket1->port]=NULL; //Diagrafoume to listener apo to port tou
		//Kspinaei to accept gia na ginei free to socket sth periptosi pou koimatai kapoio accept sto listener socket
		kernel_broadcast( &(socket1->sock_uni.listener_s.req_available) ); 
		free(socket1);
	}

	if(socket1->type == PEER){
		//Kleinoume kai tis 2 kateuthunseis kai apeleuthrwnoume to socket
		pipe_writer_close(socket1->sock_uni.peer_s.write_pipe);
		pipe_reader_close(socket1->sock_uni.peer_s.read_pipe);
		free(socket1);
	}
	else{
		return -1;
	} 


	return 0;
}


static file_ops socket_file_ops ={

	.Open = NULL,
    .Read = socket_read,
    .Write = socket_write,
    .Close = socket_close
};

//Dhmiourgoume to socket
Fid_t sys_Socket(port_t port)
{	

	if(port >MAX_PORT || port < 0){ //The port is iilegal 
		return NOFILE;
	} 

	Fid_t sock_fid[1];//Pinakas me 2 stoixeia, 0-->reader kai 1-->writer
	FCB* sock_fcb[1];//Pinakas apo pointers FCB

	//Get the fid and FCB with FCB_reserve()
	if(FCB_reserve(1, sock_fid, sock_fcb)){ //Check if the available file ids for the process are exhausted

		socket_cb* socket1 = initialize_socket_control_block(sock_fcb, port); //Get the socket
		socket1->fid= sock_fid[0]; 

		//to FCB exei metavlhth stream,prepei na to sundesw me to stream pou dhmiourgithike,to socket
		sock_fcb[0]->streamfunc= &socket_file_ops; //gia tis sunarthseis READ,WRITE,CLOSE

    	//to FCB exei metavlhth file_ops,prepei nata sundesw me tin panw statikh metavlhth
		sock_fcb[0]->streamobj= socket1;

		return sock_fid[0]; 
	}

	return NOFILE;
}



int sys_Listen(Fid_t sock)
{

	/*if(sock<0 || sock>MAX_FILEID) { //Elegxoume to orio twn fid
		return -1;
	}*/

	FCB* sock_fcb = get_fcb(sock);//Get FCB from sock. Translate an fid to an FCB

	if (sock_fcb==NULL) { //Error: an to get_fcb epistrepsei null
		return -1;
	}

	//Pairnoume to sugegkrimeno socket me auto to fid,prosvash mesa apo to fcb
   	socket_cb*  socket1 = sock_fcb->streamobj;

   	if(socket1==NULL) {//Error: The socket has already been initialized 
   	return -1;
   	} 

   	//Ean sth sugekrimenh thesh sto port map den exei sundethei allo socket kai to socket einai se katastash unbound
   	if(PORT_MAP[socket1->port]==NULL && socket1->type==UNBOUND && socket1->port>0 && socket1->port!=NOPORT && socket1->port<MAX_PORT){

   		socket1->type = LISTENER; //To markaroyme ws socket listener
   		PORT_MAP[socket1->port]=socket1; //sundesh port me to socket ,desmeush theshs sto port map
   		//Initialize the listsner_socket fileds of the union
   		socket1->sock_uni.listener_s.req_available = COND_INIT;
   		rlnode_init(& socket1->sock_uni.listener_s.queue, NULL);//arxikopoihsh listas tou listener
 	  	return 0;
   	} 
   	else
		return -1;
}


Fid_t sys_Accept(Fid_t lsock)
{

	/*if(lsock<0 || lsock>MAX_FILEID) { //Elegxoume to orio twn fid
		return -1;
	}*/

	FCB* sock_fcb = get_fcb(lsock);//Get FCB from lsock. Translate an fid to an FCB

	if (sock_fcb==NULL) { //Error: an to get_fcb epistrepsei null
		return NOFILE;
	}

	//Pairnoume to sugegkrimeno socket me auto to fid,prosvash mesa apo to fcb
   	socket_cb* socket1 = sock_fcb->streamobj;

   	if(socket1==NULL) { //Error: The socket has already been initialized 
   		return NOFILE;
   	} 

   	if(socket1->type!=LISTENER) { //Prepei na einai listener_socket gia na ginei accept
   		return NOFILE;
   	}

   	//socket_cb->refcount = socket_cb->refcount + 1;
   	socket1->refcount = socket1->refcount + 1;

   	//Oso den exei aitimata apo tin connect i accept perimenei, dhladh oso einai adeia h lista queue tou listener kanw kernel_wait
	while (is_rlist_empty(&(socket1->sock_uni.listener_s.queue)) && PORT_MAP[socket1->port] != NULL){
		//elegxos
		kernel_wait(&(socket1->sock_uni.listener_s.req_available),SCHED_USER);
	}

	//Otan bgei apth while tha exei ksipnisei

	//if(PORT_MAP[socket1->port] != socket1)  //Check if the port is still valid
	//	return NOPORT;

	if(PORT_MAP[socket1->port] == NULL)  //Check if the port is still valid
		return NOFILE;

	//////////////////////////////////////////
	//Dimiourgw ena trito socket neo socket
	Fid_t sock3 = sys_Socket(socket1->port);

	if(sock3 == NOFILE/*|| sock3==0*/){
		return NOFILE;
	}

    if(sock3 < 0 || sock3 > MAX_FILEID) {
    	return NOFILE;
    }

	FCB* sock_fcb3 = get_fcb(sock3);

	if (sock_fcb3==NULL) {
		return NOFILE;
	}

	socket_cb* socket3 = sock_fcb3->streamobj;

	if(socket3==NULL) {
		return NOFILE;
	} 
	////////////////////////////////////////////

	//Otan h lista tha exei request h accept tha ta bgalei apo thn lista
	rlnode* queue_node = rlist_pop_front(&(socket1->sock_uni.listener_s.queue));

	//Get the request object of the node.
	REQ *req = queue_node->obj;
	/*REQ *req; 
	req->queue_node = queue_node;*/

	req->admitted = 1; //Eksipireteitai request

	socket_cb* socket2 = req->peer; //To socket pou exei erthei apo tin connect, dhladh aut pou kanei to request

	//  socket 2  (write_pipe)->[[[[[[pipe1]]]]] <-(read_pipe) socket3 :fcb_array_for_first_pipe
	//            (read_pipe)-> [[[[[[pipe2]]]]] <-(write_pipe)        :fcb_array_for_second_pipe

	//Ta FCBs ton duo parapanw socket tha perasoun ws orismata stin initialize Pipe Control Block
	FCB* fcb_array_for_first_pipe[2];
	fcb_array_for_first_pipe[0] = socket3->fcb; //0-->read (socket3)
	fcb_array_for_first_pipe[1]= socket2->fcb;	//1-->write (socket2)

	FCB* fcb_array_for_second_pipe[2];
	fcb_array_for_second_pipe[0] = socket2->fcb; //0-->read (socket2)
	fcb_array_for_second_pipe[1] = socket3->fcb; //1-->write (socket3)

	//Twra tha kanei ta duo sockets peer sockets, afou dimiourgisei ta pipes me ta opoia
   	//tha antallaksoun tin pliroforia
	pipe_cb* pipe1 = initialize_Pipe_Control_Block(fcb_array_for_first_pipe); // Epistrefei ena read kai ena write
   	pipe_cb* pipe2 = initialize_Pipe_Control_Block(fcb_array_for_second_pipe); // Epistrefei ena read kai ena write 

   	//Sindesi peer to peer EGINAN PEER
   	socket2->type = PEER; //allagh sto type
   	socket3->type = PEER;

   	//Enosi
   	socket2->sock_uni.peer_s.peer = socket3;
   	socket3->sock_uni.peer_s.peer = socket2;

	socket2->sock_uni.peer_s.write_pipe = pipe1; // Write pipe is pipe1 for socket2
   	socket2->sock_uni.peer_s.read_pipe = pipe2; // Read pipe is pipe2 for socket 2  

	socket3->sock_uni.peer_s.write_pipe = pipe2; // Write pipe is pipe2 for socket3
   	socket3->sock_uni.peer_s.read_pipe = pipe1; // Read pipe is pipe2 for socket3

   	socket1->refcount = socket1->refcount - 1;
	
	return sock3; //return fidt of the new socket 
}


REQ* initialize_request_Block(){

	REQ*  sock_req = (REQ*)xmalloc(sizeof(REQ));  //dhmiourgei to request
    sock_req->connected_cv = COND_INIT ;//otan ginei connection ginetai signaled
	sock_req->admitted = 0; //Otan ginei ena mas leei oti to socket eksipireteitai
	rlnode_init(&(sock_req->queue_node),sock_req); //lista apo aithmata

    return sock_req;
}



int sys_Connect(Fid_t sock, port_t port, timeout_t timeout)
{

	/*if(sock<0 || sock>MAX_FILEID) { //Elegxoume to orio twn fid
		return -1;
	}*/

	FCB* sock_fcb = get_fcb(sock);//Get FCB from sock. Translate an fid to an FCB

	if (sock_fcb==NULL) { //Error: an to get_fcb epistrepsei null
		return -1;
	}

	//Pairnoume to sugegkrimeno socket me auto to fid,prosvash mesa apo to fcb
   	socket_cb* socket1 = sock_fcb->streamobj;

   	if(socket1==NULL) {//Error: The socket has already been initialized 
   		return -1;
   	} 

	/*if(PORT_MAP[socket1->port]!=NULL) { //If given a listening or connected socket apotyxia
		return -1; 
	}*/

	if(port >MAX_PORT || port < 0  || PORT_MAP[port]==NULL){ //Elegxos gia ta port
		return -1;
	}

	socket_cb* lsock = PORT_MAP[port]; //listener socket

	//To socket pou dinei h connect,to opoio thelei na sundethei de prepei na einai listener
    if(socket1->type!=UNBOUND){
    	return -1;
    }  

    socket1->refcount = socket1->refcount + 1; //Increase refcount


	REQ* sock_req = initialize_request_Block();  //arxikopoiei to request

	//o idioktitis tou request einai to socket pou dimiourgei i connect
	sock_req->peer = socket1;

	//Prosthetoume to aithma sthn lista tou listener(queue)
	rlist_push_back( &(lsock->sock_uni.listener_s.queue), &(sock_req->queue_node));

	//H connect tha koimithei mexri na tin ksipnisei i accept 
	//prota omws tha prepei na idopoiisei tin accept oti exei douleia na kanei
	kernel_signal(&(lsock->sock_uni.listener_s.req_available));

	//Ean termatistei logo xronou 
	/*if(kernel_timedwait(&(sock_req->connected_cv), SCHED_USER, timeout)){
		return -1;
	}*/
	
	kernel_timedwait(&(sock_req->connected_cv), SCHED_USER, timeout); //sleep

	//Ean den eksipiretithei to request
	if(sock_req->admitted!=1){
		return -1;
	}/*

	/*while(sock_req->admitted!=1){
		kernel_timedwait(&(sock_req->connected_cv), SCHED_USER, timeout);
	}*/

	socket1->refcount = socket1->refcount - 1; //Decrease refcount

	//To refcount xrhmineuei gia na diagrapsoume to node
	if(socket1->refcount == 0){
		rlist_remove(&sock_req->queue_node); //remove from listener's queue in case it hasn't been removed from Accept()
		free(sock_req);
	}

	return 0;

}


int sys_ShutDown(Fid_t sock, shutdown_mode how)
{

	if(sock<0 || sock >MAX_FILEID) {
		return -1;
	}

	FCB* sock_fcb = get_fcb(sock);

    if (sock_fcb==NULL) {
    	return -1;
    }

    //Gia na parw to sugegkrimeno socket me auto to fid,prosvash mesa apo to fcb
   	socket_cb* socketA = sock_fcb->streamobj; //socketA to socket pou thelw na kleisw
   	//socket_cb* socketB = socketA->sock_uni.peer_s.peer; //socketB to socet pou einai syndedemeno me to socketA

   	if(socketA->type == PEER){ //Mono otan einai peer yparxei sundesh 2 sockets alliws den exei nohma

   		if(how == SHUTDOWN_READ){ 
			
            pipe_cb *socket_readA = socketA->sock_uni.peer_s.read_pipe; //Kleinoume ton reader tou A
   			return pipe_reader_close(socket_readA);
 	    }
 	    else if(how == SHUTDOWN_WRITE){

 	    	// will first exhaust the buffered data and then will return 0.
 	    	pipe_cb *socket_writeA = socketA->sock_uni.peer_s.write_pipe; //Kleinoume ton writer tou A
 	    	return pipe_writer_close(socket_writeA);
 	    }
 	    else if(how == SHUTDOWN_BOTH){ //Kleinei kai ta 2 akra

 	    	pipe_cb *socket_readA  = socketA->sock_uni.peer_s.read_pipe;
 	    	pipe_cb *socket_writeA = socketA->sock_uni.peer_s.write_pipe;
 	    	
 	    	pipe_reader_close(socket_readA); //Kleinoume ton reader tou A
 	    	pipe_writer_close(socket_writeA); //Kleinoume ton writer tou A

 	    	if(pipe_reader_close(socket_readA) == 0 && pipe_writer_close(socket_writeA) == 0){
 	    		return 0;
 	    	}else{
 	    		return -1;
 	    	}  
 	    	
   		}
   		else{
   			return -1;
   		}
   	}
   	else{
   		return 0;
   	}	

}

