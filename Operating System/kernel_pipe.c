#include "tinyos.h"
#include "kernel_pipe.h"
#include "kernel_cc.h"
#include "kernel_streams.h"
#include "util.h"
#include "math.h"

//Arxikopoioume 2 metavlites file_ops
//Opws sth dev.c line 50
static file_ops reader = {
	.Open = NULL,
	.Read = pipe_read,
	.Write = NULL,
	.Close = pipe_reader_close
}; 

static file_ops writer = {
	.Open = NULL,
	.Read = NULL,
	.Write = pipe_write,
	.Close = pipe_writer_close
}; 


//Arxikopoihsh tou Pipe Control Block
pipe_cb* initialize_Pipe_Control_Block(FCB** fcb){
	pipe_cb* pipe1 = (pipe_cb*)xmalloc(sizeof(pipe_cb));
        
	pipe1->w_position=ceil(PIPE_BUFFER_SIZE/2);
	pipe1->r_position=ceil(PIPE_BUFFER_SIZE/2);
	pipe1->reader=fcb[0]; //0 --> reader
	pipe1->writer=fcb[1]; //1 --> writer

	pipe1->has_data=COND_INIT;
    pipe1->has_space=COND_INIT;

    return pipe1;
}

int first_write=0;//metavlhth pou xrhsimopoieitai otan tha grapsei gia prwth fora mono
//mono tote tha vriskontai sthn idia thesh,xekinane apo 0


int pipe_write(void* pipecb_t, const char *buf, unsigned int n){

	pipe_cb* pipe1=(pipe_cb*)pipecb_t; //casting toy pipecb_t se pipe1

	//Ean ena apo ta dyo einai kleista error
	if(pipe1->writer==NULL || pipe1->reader==NULL) {
		return -1;
	}

	int temp=0; //metavlhth pou deixnei posa byte grafthkan

	while(temp<n){
    	
		//Mpainoume sthn while otan ta exei grpasei olo to buffer size, dhladh otan w_position = r_position-1, ara tha prepei na diavasei
		while(pipe1->w_position==(pipe1->r_position-1) && first_write!=0){ 
		
			pipe1->BUFFER[pipe1->w_position]=buf[temp]; //epitrepoume na grapsei sthn thesh pou einai akrivws prin ton reader
            kernel_broadcast(&(pipe1->has_data)); //Ksipname reader gia na diabasei o reader efoson ta exei grapsei ola
			kernel_wait(&(pipe1->has_space),SCHED_PIPE);	//Koimizoume ton writer giati den exei allo na grapsei	
		}

		first_write=1;
		pipe1->BUFFER[pipe1->w_position]=buf[temp];//na grapsei apo ekei pou eixe stamathsei
		pipe1->w_position=(pipe1->w_position+1)%(PIPE_BUFFER_SIZE);//update ths theshs tou writer
		temp=temp+1;
	
    }

	kernel_broadcast(&(pipe1->has_data));//Afou ta grapsei ola tha prepei na xupnhsei ton reader
   	
   	return temp; //Epistrefoume ta byte pou grafthkan, mporei na mhn einai olo to n
}


int pipe_read(void* pipecb_t, char *buf, unsigned int n){

	pipe_cb* pipe1=(pipe_cb*)pipecb_t; //casting toy pipecb_t se pipe1

	if(pipe1->reader==NULL){ //An to akro tou reader einai kleisto apotyxia, to akro tou writer de mas noiazei
    	return -1;
    }

    //Ean to telos tou reader anoixto,to telos tou writer kleisto kai vriskontai sthn idia thesh EOF exoume diavasei olo to arxeio ara kanoume return 0
   if (pipe1->w_position==pipe1->r_position && pipe1->reader != NULL && pipe1->writer == NULL){
   	return 0;
   }


   int temp=0; //metavlhth pou deixnei posa byte diavasthkan

	while(temp<n){
    	
		//Mpainoume sthn while otan ta exei diavasei ta panta kai mporei na grapsei
		while(pipe1->w_position==(pipe1->r_position) && pipe1->writer!=NULL){ 
		
			buf[temp] = pipe1->BUFFER[pipe1->r_position]; //epitrepoume na ta diavasei olas
            kernel_broadcast(&(pipe1->has_space)); //Ksipname ton writer gia na grapsei efoson o reader ta exei diavasei ola
			kernel_wait(&(pipe1->has_data),SCHED_PIPE);	//Koimizoume ton reader giati den exei alla na diavasei	
		}

		//An o writer kleisei kata thn diarkeia na epistrafoun ta byte pou exoun diavastei ws twra
		if(pipe1->w_position==pipe1->r_position && pipe1->writer==NULL){
         	return temp;
         }

		buf[temp] = pipe1->BUFFER[pipe1->r_position];//na diavasei apo ekei pou eixe stamathsei
		pipe1->r_position=(pipe1->r_position+1)%(PIPE_BUFFER_SIZE);//update ths theshs tou reader, kanoume % giati einai kykliko buffer
		temp=temp+1;
	
    }

    kernel_broadcast(&(pipe1->has_space));//Afou ta diavasei ola tha prepei na xupnhsei ton writer
    
	return temp; //Epistrefoume ta byte pou diavasthkan, mporei na mhn einai olo to n
}



int sys_Pipe(pipe_t* pipe){

	Fid_t fid_array[2];//pinakas apo 2 stoixeia fid_t,to prwto panta gia reader,to deutero panta gia writer
	FCB* fcb_array[2];//pinakas apo pointers

	if(FCB_reserve(2, fid_array,fcb_array)){  //ama uparxoun diathesima (kena) fidt sunexizw

	pipe_cb* pipe1 = initialize_Pipe_Control_Block(fcb_array); 

	//Sundew ta pedia tou struct pipe_t katallhla sto pinaka fid
	pipe->read=fid_array[0];
	pipe->write=fid_array[1];
    
    //To FCB exei metavlhth file_ops,prepei nata sundesw me tis panw statikes metavlhtes
	fcb_array[0]->streamfunc=&reader;
	fcb_array[1]->streamfunc=&writer;

    //To FCB exei metavlhth stream,prepei na to sundesw me to stream pou dhmiourgithike,to pipe
	fcb_array[0]->streamobj=pipe1;
	fcb_array[1]->streamobj=pipe1;

    return 0;
    }

    return -1;
}


int pipe_writer_close(void* _pipecb){
	pipe_cb* pipe1=(pipe_cb*)_pipecb; //casting toy _pipecb se pipe1
	pipe1->writer = NULL;

	kernel_broadcast(&(pipe1->has_data));//otan kleinei o write ksipnaei o reader

	return 0;
}


int pipe_reader_close(void* _pipecb){
	pipe_cb* pipe1=(pipe_cb*)_pipecb; //casting toy _pipecb se pipe1
	pipe1->reader = NULL;

	kernel_broadcast(&(pipe1->has_space));//otan kleinei ocreader ksipnaei o writer

	return 0;
}


