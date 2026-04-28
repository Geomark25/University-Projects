all: audit_logger audit_monitor rsa


audit_logger: audit_logger.c
	gcc -Wall -fPIC -shared -o audit_logger.so audit_logger.c -lcrypto -ldl 


audit_monitor: audit_monitor.c 
	gcc audit_monitor.c -o audit_monitor

rsa: rsa.c
	gcc rsa.c -o rsa -lgmp -lcrypto -lssl

run: audit_logger.so rsa
	LD_PRELOAD=$$(pwd)/audit_logger.so ./ransomware.sh

clean:
	rm -rf audit_logger.so
	rm -rf rsa
	rm -rf audit_monitor

