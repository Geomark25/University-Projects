#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <openssl/evp.h>
#include <bits/getopt_core.h>

#define LOG_FILE "/home/student/data/access_log.log"
#define TIME_WINDOW_SECONDS 1200 // 20 minutes
#define IGNORED_FILE "/usr/lib/terminfo/x/xterm"

/* --- Structs --- */
typedef struct full_log_t {
    uid_t userID;
    char filename[1024];
    char date[32];
    char time[32];
    int access_type; // 0 for Create, 1 for Open
    int denied;
    time_t timestamp; 
} full_log_t;

/* --- Helper Functions --- */

/* Convert Date (DD/MM/YYYY) and Time (HH:MM:SS) to unix timestamp */
time_t parse_datetime(const char* date_str, const char* time_str) {
    struct tm tm;
    memset(&tm, 0, sizeof(struct tm));
    
    // FIX: Parse DD/MM/YYYY with slashes
    if (sscanf(date_str, "%d/%d/%d", &tm.tm_mday, &tm.tm_mon, &tm.tm_year) != 3) {
        // Fallback: Try YYYY-MM-DD just in case format varies
        if (sscanf(date_str, "%d-%d-%d", &tm.tm_year, &tm.tm_mon, &tm.tm_mday) != 3) {
            return 0;
        }
    }
    
    // Parse Time (HH:MM:SS)
    if (sscanf(time_str, "%d:%d:%d", &tm.tm_hour, &tm.tm_min, &tm.tm_sec) != 3) return 0;

    tm.tm_year -= 1900; // Struct tm year is years since 1900
    tm.tm_mon -= 1;     // Struct tm month is 0-11
    tm.tm_isdst = -1;   // Let system determine DST

    return mktime(&tm);
}

int should_skip_file(const char* filename) {
    if (filename == NULL || strlen(filename) == 0 || strcmp(filename, "(null)") == 0) return 1;
    if (strcmp(filename, IGNORED_FILE) == 0) return 1;
    return 0;
}

/* Extract value after a label, handling tabs and spaces */
void extract_value(const char* line, const char* label, char* dest) {
    char* p = strstr(line, label);
    if (p) {
        p += strlen(label);
        while (*p == ' ' || *p == '\t') p++; // Skip whitespace
        strcpy(dest, p);
        dest[strcspn(dest, "\n")] = '\0';
    } else {
        dest[0] = '\0';
    }
}

/* --- Log Parsing --- */
full_log_t* getFullLog(FILE* file) {
    char line[1024];
    if (feof(file)) return NULL;

    full_log_t* entry = (full_log_t*)malloc(sizeof(full_log_t));
    if (!entry) return NULL;
    memset(entry, 0, sizeof(full_log_t));

    // 1. UID
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }
    entry->userID = (uid_t)atoi(line + 5); 

    // 2. PID 
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }

    // 3. Filename
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }
    extract_value(line, "Filename:", entry->filename);

    // 4. Date
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }
    extract_value(line, "Date:", entry->date);

    // 5. Time
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }
    extract_value(line, "Time:", entry->time);

    entry->timestamp = parse_datetime(entry->date, entry->time);

    // 6. Access Type (Logs say "Operation:")
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }
    char op_str[32];
    extract_value(line, "Operation:", op_str);
    entry->access_type = atoi(op_str);

    // 7. Denied (Logs say "Denied Flag:")
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }
    char den_str[32];
    extract_value(line, "Denied Flag:", den_str);
    entry->denied = atoi(den_str);

    // 8. Hash 
    if (!fgets(line, sizeof(line), file)) { free(entry); return NULL; }

    // Skip blank lines
    int c;
    while ((c = fgetc(file)) != EOF) {
        if (c != '\n' && c != '\r') {
            ungetc(c, file);
            break;
        }
    }

    if (should_skip_file(entry->filename)) {
        free(entry);
        return NULL;
    }
    return entry;
}

int parseFullLogs(full_log_t*** logs) {
    FILE* file = fopen(LOG_FILE, "r");
    if (!file) { fprintf(stderr, "No log found at %s!\n", LOG_FILE); return 0; }

    int count = 0;
    full_log_t* temp;
    char buffer[1024];

    while (!feof(file)) {
        long pos = ftell(file);
        if (!fgets(buffer, sizeof(buffer), file)) break;
        if (strstr(buffer, "UID:")) {
            fseek(file, pos, SEEK_SET);
            temp = getFullLog(file);
            if (temp != NULL) {
                *logs = (full_log_t**)realloc(*logs, sizeof(full_log_t*) * (count + 1));
                (*logs)[count++] = temp;
            }
        }
    }
    fclose(file);
    return count;
}

/* --- Detection Logic --- */
void detect_burst_activity(int threshold) {
    full_log_t** logs = NULL;
    int count = parseFullLogs(&logs);
    time_t now = time(NULL);
    int recent_creations = 0;

    printf("Analyzing burst activity (Time Window: %ds)...\n", TIME_WINDOW_SECONDS);

    for (int i = 0; i < count; i++) {
        full_log_t* log = logs[i];
        if (log->access_type == 0 && log->denied == 0) { // 0 = Create
            double diff = difftime(now, log->timestamp);
            if (diff >= 0 && diff <= TIME_WINDOW_SECONDS) {
                recent_creations++;
            }
        }
    }

    if (recent_creations > threshold) {
        printf("[ALERT] Burst Activity Detected!\n");
        printf("  %d files created in the last 20 minutes (Threshold: %d)\n", recent_creations, threshold);
    } else {
        printf("  No burst activity detected. (%d creations found)\n", recent_creations);
    }

    for (int i = 0; i < count; i++) free(logs[i]);
    free(logs);
}

void detect_encryption_workflow() {
    full_log_t** logs = NULL;
    int count = parseFullLogs(&logs);
    printf("Analyzing for encryption-and-delete workflows...\n");

    for (int i = 0; i < count; i++) {
        full_log_t* enc_log = logs[i];
        if (enc_log->access_type == 0 && enc_log->denied == 0) {
            size_t len = strlen(enc_log->filename);
            if (len > 4 && strcmp(enc_log->filename + len - 4, ".enc") == 0) {
                char original_name[1024];
                strncpy(original_name, enc_log->filename, len - 4);
                original_name[len - 4] = '\0';

                for (int j = 0; j < count; j++) {
                    full_log_t* orig_log = logs[j];
                    if (orig_log->userID == enc_log->userID &&
                        orig_log->access_type == 1 && 
                        strcmp(orig_log->filename, original_name) == 0) {
                        
                        printf("[ALERT] Ransomware Pattern Detected!\n");
                        printf("  User ID: %d\n", enc_log->userID);
                        printf("  Original File Opened: %s\n", orig_log->filename);
                        printf("  Encrypted File Created: %s\n", enc_log->filename);
                        break; 
                    }
                }
            }
        }
    }
    for (int i = 0; i < count; i++) free(logs[i]);
    free(logs);
}

/* --- Usage & Main --- */
void usage(void) {
    printf("\nUsage:\n");
    printf("  ./audit_monitor [options]\n\n");
    printf("Options:\n");
    printf("  -v <threshold>   Detect high-volume file creation (burst activity)\n");
    printf("                   Alerts if creations > threshold in the last 20 mins.\n");
    printf("  -e               Detect encryption-and-delete workflow\n");
    printf("                   Alerts if a file is opened and then a .enc version is created.\n");
    printf("  -h               Show this help message\n\n");
    exit(1);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        usage();
    }

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-v") == 0) {
            if (i + 1 < argc) {
                detect_burst_activity(atoi(argv[i+1]));
                return 0;
            } else {
                fprintf(stderr, "Error: -v requires a threshold argument.\n");
                usage();
            }
        } 
        else if (strcmp(argv[i], "-e") == 0) {
            detect_encryption_workflow();
            return 0;
        } 
        else if (strcmp(argv[i], "-h") == 0) {
            usage();
        } 
        else {
            fprintf(stderr, "Unknown argument: %s\n", argv[i]);
            usage();
        }
    }
    return 0;
}