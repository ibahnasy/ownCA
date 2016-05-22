#!/usr/bin/env bash


## Script:	openca.sh
## Version:	1.0
## Description:	Simplifies the creation of self certificate authority and server/client certificate generation
## Tutorial:	Based and thanks to this tutorial 
##		https://jamielinux.com/docs/openssl-certificate-authority/introduction.html
## Author:	Islam Bahnasy
## Email:	islam@cybertechlab.com


# Exit status 2 = error

CA_PATH=/root/ca
CNF_FILE="$(pwd)"/openssl.cnf
ROOT_CERT_SIZE=8192
SERVER_CERT_SIZE=4096
CLIENT_CERT_SIZE=4096


#### Check for root
function root_user_check {
	if [[ $EUID -ne 0 ]]; then
	   echo "This script must be run as root" 
	   exit 2
	fi
}


#### CA Check
function ca_check {
	[ ! -f "$CA_PATH/README" ] && echo "Certificate Authority Doesn't Exist." && exit 2
}


#### Initialize CA
function init_ca {
	echo "Initializing Certificate Authority"
	[ -f "$CA_PATH/README" ] && echo "Certificate Authority Already Exist." && exit 2

	mkdir $CA_PATH
	cd $CA_PATH || exit 2
	mkdir certs crl newcerts private csr
	chmod 700 private
	touch index.txt
	echo 1000 > serial
	touch README
	echo "DONE."
}


#### Create Root CA Key,Certificate
function root_cert {
	echo "Creating CA Root Key"
	ca_check
	
	## Root Key
	cd $CA_PATH || exit 2
	[ -f "$CA_PATH/private/ca.key.pem" ] && echo "Key Already Exists." && exit 2

	openssl genrsa -aes256 -out private/ca.key.pem $ROOT_CERT_SIZE
	chmod 400 "private/ca.key.pem"
	
	echo "Creating CA Root Certificate"
	## Root Cert
	[ -f "$CA_PATH/private/ca.cert.pem" ] && echo "Certificate Already Exists." && exit 2
	
	cd $CA_PATH || exit 2
	openssl req -config "$CNF_FILE" \
		-key private/ca.key.pem \
		-new -x509 -days 7300 -sha512 -extensions v3_ca \
		-out "certs/ca.cert.pem"
	chmod 444 "certs/ca.cert.pem"
}


#### Create Server Certificate
function server_cert {
	## Key
	echo "Creating Server Root Key"
	ca_check
	
	[ -f "$CA_PATH/private/$1.key.pem" ] && echo "Key Already Exists." && exit 2
	
	cd $CA_PATH || exit 2
	openssl genrsa -aes256 -out "private/$1.key.pem" $SERVER_CERT_SIZE
	chmod 400 "private/$1.key.pem"
	
	## CSR
	echo "Creating Server CSR"
	openssl req -config "$CNF_FILE" \
		-key "private/$1.key.pem" \
	      	-new -sha512 -out "csr/$1.csr.pem"


	## Cert
	echo "Creating Server Certificate"
	[ -f "$CA_PATH/certs/$1.cert.pem" ] && echo "Certificate Already Exists." && exit 2
	
	openssl ca -config "$CNF_FILE" \
	      	-extensions server_cert -days 375 -notext -md sha512 \
	      	-in "csr/$1.csr.pem" \
	      	-out "certs/$1.cert.pem"
	chmod 444 "certs/$1.cert.pem"
}


#### Create Client Certificate
function client_cert {
	## Key
	echo "Creating Client Key"
	ca_check
	
	[ -f "$CA_PATH/private/$1.key.pem" ] && echo "Key Already Exists." && exit 2
	
	cd $CA_PATH || exit 2
	openssl genrsa -aes256 -out "private/$1.key.pem" $CLIENT_CERT_SIZE
	chmod 400 "private/$1.key.pem"
	
	## CSR
	echo "Creating Client CSR"
	openssl req -config "$CNF_FILE" \
		-key "private/$1.key.pem" \
	      	-new -sha512 -out "csr/$1.csr.pem"

	## Cert
	echo "Creating Client Certificate"
	[ -f "$CA_PATH/certs/$1.cert.pem" ] && echo "Certificate Already Exists." && exit 2
	
	openssl ca -config "$CNF_FILE" \
	      	-extensions usr_cert -days 375 -notext -md sha512 \
	      	-in "csr/$1.csr.pem" \
	      	-out "certs/$1.cert.pem"
	chmod 444 "certs/$1.cert.pem"
}


#### Display Certificate Information
function show_cert {
	openssl x509 -noout -text -in "$1"
}


#### Verify Certificate against CA
function verify_cert {
	[ ! -f "$CA_PATH/certs/ca.cert.pem" ] && echo "CA Certificate Doesn't Exist." && exit 2
	cd $CA_PATH || exit 2
	openssl verify -CAfile "certs/ca.cert.pem" "$1"
}


#### Main

root_user_check

case "$1" in
	"init-ca" )
		init_ca ;;
	"root-cert" )
		root_cert ;;
	"server-cert" )
		[ -z "$2" ] && echo "Enter Common Name" && exit 2
		server_cert "$2"
		;;
	"client-cert" )
		[ -z "$2" ] && echo "Enter Common Name" && exit 2
		client_cert "$2"
		;;
	"show-cert" )
		[ -z "$2" ] && echo "Enter Certificate Filename" && exit 2
		show_cert "$2"
		;;
	"verify-cert" )
		[ -z "$2" ] && echo "Enter Certificate Filename" && exit 2
		verify_cert "$2"
		;;
	"" )
		echo "Available Options:"
		echo -e " \t $0 init-ca"
		echo -e " \t $0 root-cert"
		echo -e " \t $0 server-cert <hostname/common_name>"
		echo -e " \t $0 client-cert <hostname/common_name>"
		echo -e " \t $0 show-cert <certificate_filename>"
		echo -e " \t $0 verify-cert <certificate_filename>"
		;;
esac

