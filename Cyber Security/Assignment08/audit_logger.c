#define _GNU_SOURCE

#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <openssl/sha.h>

#define LOG_FILE "/home/student/data/access_log.log"

static char* W_MODES[4] = {"w", "a", "wb", "ab"};
static char* R_MODES[2] = {"r", "rb"};
static char* WR_MODES[6] = {"w+", "a+", "r+", "w+b", "a+b", "r+b"};

static char openedFile[1024] = {};
static int read_only = 0;

/* Original fopen */
static FILE *(*original_fopen)(const char*, const char*) = NULL;
static int (*original_fclose)(FILE*) = NULL;

static void init_fopen(){
	if(!original_fopen){
		original_fopen = dlsym(RTLD_NEXT, "fopen");
	}
}

static void init_fclose(){
	if(!original_fclose){
		original_fclose = dlsym(RTLD_NEXT, "fclose");
	}
}

static char *sha256_file(const char* path) {

    FILE* file = (*original_fopen)(path, "rb");
    if (!file) return NULL;

    SHA256_CTX ctx;
    SHA256_Init(&ctx);

    unsigned char buffer[4096];
    size_t n;
    while ((n = fread(buffer, 1, sizeof(buffer), file)) > 0) {
        SHA256_Update(&ctx, buffer, n);
    }

    if (ferror(file)) {
        (*original_fclose)(file);
        return NULL;
    }

    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_Final(hash, &ctx);
    (*original_fclose)(file);

    // Convert hash to hex string
    char *hex = malloc(SHA256_DIGEST_LENGTH * 2 + 1);
    if (!hex) return NULL;

    for (unsigned int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        sprintf(&hex[i * 2], "%02x", hash[i]);
    }
    hex[SHA256_DIGEST_LENGTH * 2] = '\0';

    return hex;
}

static void write_log(int op, int denied){

	FILE* log = (*original_fopen)(LOG_FILE, "a");

	uid_t userID = getuid();
	pid_t procID = getpid();

	time_t currTime;
	struct tm *tm_info;

	time(&currTime);
	tm_info = gmtime(&currTime);

	char date[11];
	char time[9];

	strftime(date, sizeof(date), "\%d/%m/%Y", tm_info);
	strftime(time, sizeof(time), "%H:%M:\%S", tm_info);

	char* hash = sha256_file(openedFile);
	
	fprintf(log, "UID:\t\t%i\n", userID);
	fprintf(log, "PID:\t\t%i\n", procID);
	fprintf(log, "Filename:\t%s\n", realpath(openedFile, NULL));
	fprintf(log, "Date:\t\t%s\n", date);
	fprintf(log, "Time:\t\t%s\n", time);
	fprintf(log, "Operation:\t%d\n", op);
	fprintf(log, "Denied Flag:\t%d\n", denied);
	fprintf(log, "File hash:\t%s\n\n\n\n", hash);

	(*original_fclose)(log);
	free(hash);
}

FILE *
fopen(const char *path, const char *mode) 
{
	init_fopen();
	init_fclose();

	struct stat buf;
	int exists = stat(path, &buf) == 0 ? 1 : 0;

	FILE *original_fopen_ret = (*original_fopen)(path, mode);
	
	strcpy(openedFile, path);

	int denied = 0;

	for(int i = 0; i < 4; i++){
		if(strstr(mode, W_MODES[i]) != NULL){
			denied = access(openedFile, W_OK) == 0 ? 0 : 1;
			read_only = 0;
		}
	}
	for(int i = 0; i < 2; i++){
		if(strstr(mode, R_MODES[i]) != NULL){
			denied = access(openedFile, R_OK) == 0 ? 0 : 1;
			read_only = 1;
		}
	}
	for(int i = 0; i < 6; i++){
		if(strstr(mode, WR_MODES[i]) != NULL){
			denied = access(openedFile, W_OK|R_OK) == 0 ? 0 : 1;
			read_only = 0;
		}
	}

	write_log(exists, denied);

	return original_fopen_ret;
}


size_t 
fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream) 
{
	init_fopen();
	init_fclose();

	size_t original_fwrite_ret;
	size_t (*original_fwrite)(const void*, size_t, size_t, FILE*);

	/* call the original fwrite function */
	original_fwrite = dlsym(RTLD_NEXT, "fwrite");
	original_fwrite_ret = (*original_fwrite)(ptr, size, nmemb, stream);
	fflush(stream);

	int denied = 0;
	if(!read_only){
		denied = access(openedFile, W_OK) == 0 ? 0 : 1;
	}

	write_log(2, denied);

	return original_fwrite_ret;
}


int 
fclose(FILE *stream)
{
	init_fopen();
	init_fclose();

	int original_fclose_ret = (*original_fclose)(stream);

	write_log(3, 0);

	memset(openedFile, '\0', sizeof(openedFile));
	read_only = 0;
	
	return original_fclose_ret;
}