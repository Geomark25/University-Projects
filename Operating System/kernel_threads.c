
#include "tinyos.h"
#include "kernel_streams.h"
#include "kernel_proc.h"
#include "kernel_cc.h"


//einai san thn  start main_thread ths proc.c , lambanei ypopsin to ptcb
//kai kanei spawn kai execute ena thread ths proccess.
void start_main_ptcb_thread(){
  int exitval;

////////////////////////////////////////////////////////////////////
  Task call =  cur_thread() -> ptcb_ptr-> ptcb_task; 
  int argl = cur_thread() -> ptcb_ptr ->argl; 
  void* args = cur_thread() -> ptcb_ptr ->args;

  exitval = call(argl,args); // anti gia exitval

  sys_ThreadExit(exitval); 
  ////////////////////////////////////////////////////////////////////
}


/** 
  @brief Create a new thread in the current process.
  */
////////////////////////////////////////////////////////////////////////////
PTCB* acquire_PTCB() //Arxikopoioume to ptcb, kanoume th xmalloc, 
{

  
  PCB* curproc = CURPROC;

  PTCB* ptcb = (PTCB*) xmalloc(sizeof(PTCB)); 
  ptcb->argl = 0;     //Arxikopoioume opws sto intialize tou proc.c
  ptcb->args = NULL;
  
 
  ptcb->detached= 0; //Ta arxikopoioume sto 0
  ptcb->exited=0;
  ptcb->exitval=0;

  ptcb->exit_cv=COND_INIT;
  ptcb->refcount=0;

 
  rlnode_init(&ptcb->ptcb_list_node, ptcb); 
  rlist_push_back(&(curproc->ptcb_list), &(ptcb->ptcb_list_node));

   

  
  return ptcb;
}

/////////////////////////////////////////////////////////////////////////
//Dhmiourgoume ena nhma pou anhkei sto pcb gia to ptcb kai egine me bash th sys_exec
Tid_t sys_CreateThread(Task task, int argl, void* args)
{
  //To task einai to function pou trexei to pcb otan klhthei na ektelestei 
  //
  PCB *curproc;   
  PTCB *newptcb;

  curproc=CURPROC;

   /* The new process PTCB */
  newptcb = (PTCB*) acquire_PTCB(); 

  // Initialize PTCB
    /* Set the thread's function */
  newptcb->ptcb_task = task;

  /* Copy the arguments to new storage, owned by the new thread */
  newptcb->argl = argl; ///ta arxikopoioume stis parametroys tis synartishs 
  newptcb->args = args; 

  // Create and wake up the thread for the main function. This must be the last thing
  // we do, because once we wakeup the new thread it may run! so we need to have finished
  // the initialization of the PCB.
   if(task != NULL) {
    newptcb->tcb= spawn_thread(curproc, newptcb, start_main_ptcb_thread);
    curproc->thread_count++;
    wakeup(newptcb->tcb);
  }


  
  return (Tid_t) newptcb;
}

/**
  @brief Return the Tid of the current thread.
 */
Tid_t sys_ThreadSelf()
{
  return (Tid_t) cur_thread()-> ptcb_ptr; /**episterfei to tid tou ccurrente thread*/
}

/**
  @brief Join the given thread. 
  */
int sys_ThreadJoin(Tid_t tid, int* exitval)
{
  PTCB* ptcb=(PTCB*)tid; /**orizoume to ptcb*/
  /** tha jekinhsoyme na kanoyme elegxous gia to tid */
  //kanoume toys 3 elegxous
  if (rlist_find(&(CURPROC->ptcb_list),ptcb,NULL)==NULL) //**elegxoume an tid einais thn idia diadikasia
  {
      return -1;  
  }
  if (tid==sys_ThreadSelf()) /**elegxoume oti den kanei join ton eayto tou*/
  {
          return -1; 
  }
  if (ptcb->detached==1)  /**elegxoume oti den einai detached*/
  {
       return -1; 
  }
     
  //se priptwsh pou oi elegxoi einai komple prosthetoume to refcount
  ptcb->refcount++;         
  
  //mpainei sth while an to nhma den einai oute exited oute detached kai afou mpei koimatai kanontas kernel wait().
  
  while (ptcb->exited==0  && ptcb->detached==0) //An d isxuoun ta parapanw tha exei ena loop 
      {
      kernel_wait(& ptcb->exit_cv,SCHED_USER); //pou tha kanei ena kernel_wait((PTCB*)tid)->cv_exit,..)
      
      }


      ptcb->refcount--; // meiwnw to refcount

          
     if (ptcb->detached==1)  
      {
          return -1; /**error*/
      }
      
    ///an to exit status den einai null to anathetoyme sto ptcb
    if(exitval != NULL)
      {
      (*exitval) = ptcb->exitval;
      }
            
    //Eleftherwnw to ptcb
    if (ptcb->refcount == 0)
      {
        rlist_remove(& ptcb->ptcb_list_node);
        free(ptcb);
      }

       return 0;

          

  
}

////kanei to nhma detach dld mh joinable
int sys_ThreadDetach(Tid_t tid)
{

  PTCB* ptcb=(PTCB*)tid; /**orizoume to ptcb*/
  //Kanoume tous 2 elegxous
  if(rlist_find(&(CURPROC->ptcb_list),ptcb,NULL)==NULL) // Elegxoume oti to nhma den anhkei sth idia diadikasia
  {
    return -1;
  }

  if (ptcb->exited==1) // Elegxoume oti den einai exited
  {
    return -1;
  }

  ptcb->detached=1; //h timh tou detached pleon eina ish me 1
  kernel_broadcast(& ptcb->exit_cv); //ksypnaei osoys perimenoun
  
  return 0;
} 


//eleftheronei to ptcb otan pleon de to xreiazomaste, kati to opoio de ginetai automata
/*void release_PTCB(PTCB* ptcb)
{
   rlnode* removed_node;
  PCB* curproc = CURPROC;

  removed_node = rlist_find(&(curproc->ptcb_list), ptcb, NULL); //Psaxnei na brei poio tha svhsei

  //Ama ayto poy brei den einai NULL tote kanoume remove apo th thread_list tou PCB 
  if(removed_node != NULL){
    rlist_remove(removed_node);
  }

  free(ptcb);

}


  @brief Terminate the current thread.
  */
void sys_ThreadExit(int exitval)
{
  TCB* curthread = cur_thread();
  PTCB* ptcb_ptr = curthread->ptcb_ptr;
  PCB* curproc = CURPROC;

  ptcb_ptr->exitval=exitval; //tο exitval του ptcb με το exitval pou exei san parametro
  ptcb_ptr->exited=1; // Kanei to exited=1 
  kernel_broadcast(&(ptcb_ptr->exit_cv));

  curproc->thread_count--;
 
 ////ektelei tin letoyrgia tis sys exit + ena if poy elegxei
 /// an einai to teleytaio thread tis diergasias
  if(curproc->thread_count == 0){
    if(get_pid(curproc)!=1) {

    /* Reparent any children of the exiting process to the 
       initial task */
    PCB* initpcb = get_pcb(1);
    while(!is_rlist_empty(& curproc->children_list)) {
      rlnode* child = rlist_pop_front(& curproc->children_list);
      child->pcb->parent = initpcb;
      rlist_push_front(& initpcb->children_list, child);
    }

    /* Add exited children to the initial task's exited list 
       and signal the initial task */
    if(!is_rlist_empty(& curproc->exited_list)) {
      rlist_append(& initpcb->exited_list, &curproc->exited_list);
      kernel_broadcast(& initpcb->child_exit);
    }

    /* Put me into my parent's exited list */
    rlist_push_front(& curproc->parent->exited_list, &curproc->exited_node);
    kernel_broadcast(& curproc->parent->child_exit);

  }

 

  assert(is_rlist_empty(& curproc->children_list));
  assert(is_rlist_empty(& curproc->exited_list));


  /* 
    Do all the other cleanup we want here, close files etc. 
   */

  /* Release the args data */
  if(curproc->args) {
    free(curproc->args);
    curproc->args = NULL;
  }

  /* Clean up FIDT */
  for(int i=0;i<MAX_FILEID;i++) {
    if(curproc->FIDT[i] != NULL) {
      FCB_decref(curproc->FIDT[i]);
      curproc->FIDT[i] = NULL;
    }
  }

  /* Disconnect my main_thread */
  curproc->main_thread = NULL;

  /* Now, mark the process as exited. */
  curproc->pstate = ZOMBIE;
   }



  kernel_sleep(EXITED,SCHED_USER);  

}