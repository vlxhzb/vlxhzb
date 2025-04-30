#!/bin/sh

echo "Genrating private key"
/usr/bin/openssl genrsa -out ${1}apache_key.pem -aes128 2048 -days 3650
echo "#################################################"
echo "Killing passphrase"
/usr/bin/openssl rsa -in ${1}apache_key.pem -out ${1}apache_key.pem
echo "#################################################"
echo "Genrate certivicates service request"
echo "Country: DE"
echo "State: Berlin"
echo "City: Berlin"
echo "Company: Helmholtz-Zentrum Berlin fuer Materialien und Energie GmbH"
/usr/bin/openssl req -new -key ${1}apache_key.pem -out ${1}apache_csr.pem -nodes
echo "Take the apache_csr.pem to the DFN request to sign a serer certificate" 
