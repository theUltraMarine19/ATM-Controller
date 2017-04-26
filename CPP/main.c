#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <makestuff.h>
#include <libfpgalink.h>
#include <libbuffer.h>
#include <liberror.h>
#include <libdump.h>
#include <argtable2.h> 
#include <readline/readline.h>
#include <readline/history.h>

typedef enum {
    FLP_SUCCESS,
    FLP_LIBERR,
    FLP_BAD_HEX,
    FLP_CHAN_RANGE,
    FLP_CONDUIT_RANGE,
    FLP_ILL_CHAR,
    FLP_UNTERM_STRING,
    FLP_NO_MEMORY,
    FLP_EMPTY_STRING,
    FLP_ODD_DIGITS, 
    FLP_CANNOT_LOAD,
    FLP_CANNOT_SAVE,
    FLP_ARGS
}ReturnCode;

void encrypt (uint32_t* v, uint32_t* k) {
    uint32_t v0=v[0], v1=v[1], sum=0, i;           /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i < 32; i++) {                       /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

void decrypt (uint32_t* v, uint32_t* k) {
    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              
    v[0]=v0; v[1]=v1;
}

uint8 updateCSV(uint32_t id,uint16_t pin,long int cash_req,uint8 temp, uint32_t n1000){

    pin=(pin << 11)|(pin >> 5);
    
    FILE* f = fopen("/home/aadhavan/20140524/makestuff/apps/flcli/lin.x64/rel/SampleBackEndDatabase.csv","r");
    
    int i=0;
    char line[1024];
    
    if(!fgets(line, 1024, f)){
        exit(0);
    }//reading the first line containing coulumn names
    if(!f)
        printf("here22\n");
    i++;

    while(fgets(line, 1024, f)){
        char* t;
        t=strtok(line,",");//splitting the read line into column values-- t contains id
        printf("%s,",t); 
        if(atoi(t)==id){
            t=strtok(NULL,",");
            printf("%s,",t);//now t contains hashed pin
            if(atoi(t) == pin){
                t=strtok(NULL,",");
                printf("%s,",t);//now t contains admin flag
                if(strcmp(t,"1")==0)
                    return 0x03;//0x03 ==> admin user validated
                else{
                    t=strtok(NULL,",");
                    printf("%s,",t);// now t contains user's balance
                    if(atol(t)<cash_req || n1000>0){
                        return 0x02;// 0x02 ==> insufficient user balance
                    }
                    else{
                        if(temp==0x02){
                            return 0x01;// no enough cash in atm but enough user balance 
                        }
                        fclose(f);

                        //update the csv file to contain the new user balance
                        FILE* f1=fopen("/home/aadhavan/20140524/makestuff/apps/flcli/lin.x64/rel/SampleBackEndDatabase.csv","r");
                        FILE* f2=fopen("/home/aadhavan/20140524/makestuff/apps/flcli/lin.x64/rel/SampleBackEndDatabase1.csv","w");
                        int j=0;
                        while(fgets(line, 1024, f1)){
                            if(j!=i){
                                fputs(line,f2);
                            }
                            else{
                                char l[100];
                                char iden[20],pinstr[20],cash[20];
                                strcpy(iden,"");
                                strcpy(pinstr,"");
                                strcpy(cash,"");
                                sprintf(iden,"%d",id);
                                sprintf(pinstr,"%d",pin);
                                long int c=atol(t)-cash_req;
                                sprintf(cash,"%ld",c);
                                strcpy(l,"");
                                strcat(l,iden);
                                strcat(l,",");
                                strcat(l,pinstr);
                                strcat(l,",");
                                strcat(l,"0");
                                strcat(l,",");
                                strcat(l,cash);
                                strcat(l,"\n");

                                fputs(l,f2);
                            }
                            j++;
                        }
                        fclose(f1);
                        fclose(f2);
 
                        int ret;
                        
                        ret=remove("/home/aadhavan/20140524/makestuff/apps/flcli/lin.x64/rel/SampleBackEndDatabase.csv");                        
                        //exit if remove fails
                        if(ret!=0){
                            printf("Remove() failed %d\n",ret);
                            exit(0);
                        }
                        
                        ret=rename("/home/aadhavan/20140524/makestuff/apps/flcli/lin.x64/rel/SampleBackEndDatabase1.csv","/home/aadhavan/20140524/makestuff/apps/flcli/lin.x64/rel/SampleBackEndDatabase.csv");
                        //exit if rename fails
                        if(ret!=0){
                            printf("Rename() failed %d\n",ret);
                            exit(0);
                        }

                        return 0x01;//enough user balance and enough cash in atm
                    }
                }
            }
        }
        i++;
    }
    return 0x04;//invalid user
}

int main(void){
    ReturnCode retVal = FLP_SUCCESS;
    struct FLContext *handle = NULL;
    FLStatus fStatus;
    const char *error = NULL;
    const char *vp = "1d50:602b:0002";
    const char *ivp = "1443:0007";
    uint8 conduit = 0x01;

    fStatus = flInitialise(0, &error);
    CHECK_STATUS(fStatus, FLP_LIBERR, cleanup);

    printf("Executing flOpen\n");
    //establishing laptop and board interface
    fStatus = flOpen(vp, &handle, NULL);
    //printf("%d", fStatus);
    if(fStatus){
        // printf("acbd\n");
        int count = 60;
        uint8 flag;
         //loading the firmware
        fStatus = flLoadStandardFirmware(ivp, vp, &error);
                                                            //have to check_status
        printf("Awaiting renumeration");
        flSleep(1000);
        do {
            printf(".");
            fflush(stdout);
            fStatus = flIsDeviceAvailable(vp, &flag, &error);
            CHECK_STATUS(fStatus, FLP_LIBERR, cleanup);                                                 //have to check fstatus CHECK_STATUS(fStatus, FLP_LIBERR, cleanup);
            flSleep(250);
            count--;
        } while ( !flag && count );
        printf("\n");

        if ( !flag ) {
            fprintf(stderr, "FPGALink device did not renumerate properly as %s\n", vp);
            FAIL(FLP_LIBERR, cleanup);
        }

        printf("Attempting to open connection to FPGLink device %s again...\n", vp);
        fStatus = flOpen(vp, &handle, &error);
        printf(
        "Connected to FPGALink device %s (firmwareID: 0x%04X, firmwareVersion: 0x%08X)\n",
        vp, flGetFirmwareID(handle), flGetFirmwareVersion(handle)
    );
                                                            //have to check fstatus
    }
    bool isCommCapable = flIsCommCapable(handle, conduit);
    if ( isCommCapable ) { 
        //print("here1\n");  
        uint8 isRunning;
        fStatus = flSelectConduit(handle, conduit, &error);
        CHECK_STATUS(fStatus, FLP_LIBERR, cleanup);
        fStatus = flIsFPGARunning(handle, &isRunning, &error);
        CHECK_STATUS(fStatus, FLP_LIBERR, cleanup);
        if ( isRunning ) {    
            //print("here2\n");
            int count = 0;
            uint8 temp;
            uint8 y1=0x00;
            fStatus=flWriteChannel(handle,9,(uint32)1,&y1,&error);
            //print("here3\n");                                                                    //have to check fstatus
            while(true){
                uint8 x;
                //print("here4\n");
                //poll channel 0
                fStatus=flReadChannel(handle,0,(uint32)1,&x,&error);
                //print("here5\n");
                //channel 0 has 0x00 ==> no communication ==> channel 9 is 0x00
                //channel 0 has 0x03 ==> rersponse received at frontend ==> channel 9 is 0x00
                if(x==0x00||x==0x03){
                    //print("here6\n");
                    fStatus = flWriteChannel(handle,9,(uint32)1,&y1,&error);
                }
                //setting temp to 0x01 or 0x02 when read for the first(relative)
                else if(count==0&&(x==0x01||x==0x02)){
                    temp = x;
                    count++;
                }
                
                //increment count if same value of 0x01 or 0x02 is read of from channel 0
                else if(temp==x&&count!=0&&(x==0x01||x==0x02)){
                    count++;
                }
                
                // poll afresh
                else if(temp!=x&&count!=0){
                    count = 0;
                    temp = 0x11;
                }
                // printf("%d\n", x);
                //same value of 0x01 or 0x02 is read from channel 0 3 times continuously
                if(count==3&&(temp==0x01||temp==0x02)){ 
                    count = 0;
                    // printf("0x01 or 0x02\n");
                    uint32_t v[2]={0,0},k[4]={0xff0f7457,0x43fd99f7,0x75f8c48f,0x2927c18c};//arguments for encrypt/decrypt
                    
                    //read from channels 1 to 8
                    for (int i = 1; i<=8; i++){ 
                        uint8 readValue;
                        fStatus = flReadChannel(handle,i,(uint32)1,&readValue,&error);
                        printf("%d\n", readValue);
                        if(i<=4){
                            v[0]=(v[0] << 8) | readValue;
                        }
                        else{
                            v[1]=(v[1] << 8) | readValue;
                        }
                    }
                    
                    decrypt(v,k);//decryption of message from the board
                    printf("here23\n");

                    uint32_t id,pin,n2000,n1000,n500,n100;//variables to contain the read values 

                    //bit operations for splitting the required bits
                    pin = (v[0] & 65535);
                    id = (v[0] & 4294901760) >> 16;
                    n100 = (v[1] & 255);
                    n500 = (v[1] & 65280) >> 8;
                    n1000 = (v[1] & 16711680) >> 16;
                    n2000 = (v[1] & 4278190080) >> 24;
                    printf("%d %d %d %d\n",n100,n500,n1000,n2000);
                    //cash required by the user
                    long int cash_req=n2000*2000+n1000*1000+n500*500+n100*100;
                    printf("here28\n");                
                        //check whether valid user, if so check for sufficient balance
                    uint8 response = updateCSV(id,pin,cash_req,temp,n1000);
                    
                    // //response returned is written to channel 9
                    // fStatus=flWriteChannel(handle,9,(uint32)1,&response,&error);
                    
                    //if insufficient funds or invalid user put 0s on channels 10 through 17
                    if(response==0x02||response==0x04){
                        for(int i=10;i<=17;i++){
                            uint8 y=0x00;
                            fStatus=flWriteChannel(handle,(uint8)i,(uint32)1,&y,&error);
                        }
                    }

                    //if sufficient funds or admin user put the same values read on channels 1 thro' 8 to 10 thro' 17
                    else{
                        encrypt(v,k);//encryption of information

                        //splitting v into respective bytes
                        uint8 idout1, idout2, pinout1, pinout2, n2000out, n1000out, n500out, n100out;
                        pinout1 = (v[0] & 255);
                        pinout2 = ((v[0] & 65280)>>8);
                        idout1 = ((v[0] & 16711680)>>16);
                        idout2 = ((v[0] & 4278190080)>>24);
                        n100out = ((v[1] & 255));
                        n500out = ((v[1] & 65280)>>8);
                        n1000out = ((v[1] & 16711680)>>16);
                        n2000out = ((v[1] & 4278190080)>>24);
                        
                        //writing into the respective channels
                        fStatus = flWriteChannel(handle,10,(uint32)1,&idout2,&error);
                        fStatus = flWriteChannel(handle,11,(uint32)1,&idout1,&error);
                        fStatus = flWriteChannel(handle,12,(uint32)1,&pinout2,&error);
                        fStatus = flWriteChannel(handle,13,(uint32)1,&pinout1,&error);
                        fStatus = flWriteChannel(handle,14,(uint32)1,&n2000out,&error);
                        fStatus = flWriteChannel(handle,15,(uint32)1,&n1000out,&error);
                        fStatus = flWriteChannel(handle,16,(uint32)1,&n500out,&error);
                        fStatus = flWriteChannel(handle,17,(uint32)1,&n100out,&error);      
                    }
                    //response returned is written to channel 9
                    fStatus=flWriteChannel(handle,9,(uint32)1,&response,&error);

                }

                //wait for 1 sec before reading the next time
                flSleep(1000);
                }
            }
        }
cleanup:
    flClose(handle);
    if ( error ) {
        fprintf(stderr, "%s\n", error);
        flFreeError(error);
    }
    return retVal;
}