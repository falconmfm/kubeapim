#!/bin/bash

export BASE=.
export CERPASS="wso2carbon"
export CERNAME="wso2carbon"
export CERALIAS="wso2carbon"
export RUTA=$1

cat <<EOF >>openssl.cnf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
[req_distinguished_name]
countryName = ES
countryName_default = ES
stateOrProvinceName = Andalucia
stateOrProvinceName_default = Seville
localityName = Seville
localityName_default = Seville
organizationalUnitName = Nubentos
organizationalUnitName_default = Nubentos
commonName = apimarket.nubentos.com
commonName_max = 64

[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.nubentos.com
DNS.2 = *.nubentos.falc0n.es
DNS.3 = *.default.svc.cluster.local
DNS.4 = apim-core.default.svc.cluster.local
DNS.5 = localhost
EOF

openssl req -new -newkey rsa:4096 -nodes -keyout ${CERNAME}.key -out ${CERNAME}.csr -sha256 -config openssl.cnf -passout "env:CERPASS"
openssl rsa -in ${CERNAME}.key -out ${CERNAME}.key.tmp
openssl x509 -req -days 1024 -extensions v3_ca -in ${CERNAME}.csr -signkey ${CERNAME}.key.tmp -out ${CERNAME}.crt -extensions v3_req -extfile openssl.cnf  -passin "env:CERPASS"
openssl pkcs12 -export -inkey ${CERNAME}.key.tmp -in ${CERNAME}.crt -out ${CERNAME}.p12 -name ${CERALIAS} -passin "env:CERPASS" -password "env:CERPASS"
keytool -importkeystore -noprompt -srcstorepass $CERPASS -deststorepass $CERPASS -srcalias ${CERALIAS} -destalias ${CERALIAS} -destkeystore ${RUTA}/wso2carbon.jks -srcstoretype pkcs12 -srckeystore ${CERNAME}.p12 -srcstoretype pkcs12
keytool -delete -alias  ${CERALIAS} -keystore ${RUTA}/client-truststore.jks -storepass  $CERPASS
keytool -import -trustcacerts -alias ${CERALIAS} -file ${CERNAME}.crt -keystore ${RUTA}/client-truststore.jks -storepass $CERPASS

