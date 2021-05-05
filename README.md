# tip-wlan-pki-cert-scripts

Scripts for creating PKI certificates for test servers and clients.

***WARNING: These scripts are just examples - only to get help developers getting started.***

***WARNING: Make sure you know what you are doing when you generate certificates for production systems!!!***

***WARNING: do not check in generated certificates into publically available source control systems!!!***

Some background reading:
* http://www.moserware.com/2009/06/first-few-milliseconds-of-https.html
* https://mcuoneclipse.com/2017/04/14/enable-secure-communication-with-tls-and-the-mosquitto-broker/


## How to Generate self-signed certificates 

Run the following script to generate the self-signed CA, server, and client keys and certificates.

```
$ ./generate_all.sh
```

At this point the following files will be generated:
```
testCA/cacert.pem <- CA public certificate
truststore.jks <- CA public certificate in jks format

servercert.pem <- Server public certificate
serverkey.pem <- Server private key, protected by the pass-phrase
serverkey_dec.pem <- Server private key, unprotected
server.pkcs12 <- Server private key and public certificate in pkcs12 format, protected by password
server_keystore.jks <- Server private key and public certificate in jks format, protected by password

mqttservercert.pem <- MQTT Server public certificate
mqttserverkey.pem <- MQTT Server private key, protected by the pass-phrase
mqttserverkey_dec.pem <- MQTT Server private key, unprotected

clientcert.pem <- Client public certificate
clientkey.pem <- Client private key, unprotected
client.pkcs12 <- Client private key and public certificate in pkcs12 format, protected by password
client_keystore.jks <- Client private key and public certificate in jks format, protected by password
```

Server certificates are to be used by all the services in the cloud.
MQTT Server certificates are to be used by the mqtt server, they have its hostname encoded.

Client certificates are to be used by the APs and AP simulators.

Note: You will not be able to use the client certificate to run a server.

If all you need is a single server certificate and a single client certificate, then you may stop here.

If you need to generate more server and/or client certificates, then read on.

### Create additional Server certificates

See the contents of following scripts and use them as a baseline:
```
create-server-cert-request.sh
show-server-csr.sh
sign-server-cert-request.sh
show-server-purpose.sh
verify-server.sh
```

### Create additional Client certificates

See the contents of following scripts and use them as a baseline:
```
create-client-cert-request.sh
show-client-csr.sh
sign-client-cert-request.sh
show-client-purpose.sh
verify-client.sh
```

### Package additional Server certificates

See the contents of following script and use it as a baseline: 
```
package-server-cert.sh
```

### Package additional Client certificates
```
package-client-cert.sh
```

### If you need to generate additional certificates to be used for new APs

Use the following commands, replace ap-inventory-id with the unique inventoryId of the AP:

```
$ cd /opt/tip-wlan/certs
$ ./create-ap-cert.sh ap-inventory-id

# Optional - Show the content of the client certificate
$ openssl x509 -in ap_keys/ap-inventory-id.pem -text -noout
```

The resulting files will be ap_keys/ap-inventory-id_dec.pem and ap_keys/ap-inventory-id.pem.

## How to Generate Digicert-signed certificates

### Setup

Open the file _digicert-config.sh_ and adjust the values according to your account.

Additionally make your Digicert API key available through an environment variable called _DIGICERT_API_KEY_, e.g. by running `export DIGICERT_API_KEY=XXXXXXXXXXXXXXXXX` or using a tool like [direnv](https://direnv.net/).

The scripts use a tool called jq, so please make sure you have it [installed](https://stedolan.github.io/jq/download/).

On MacOS you'll additionally need to install the GNU versions of [awk](https://formulae.brew.sh/formula/gawk) and [sed](https://formulae.brew.sh/formula/gnu-sed).

### Generate cloud controller certificates

To generate cloud controller certificates you'll need:

* a unique ID for your deployment, e.g. demo-instance
* the domain names at which your MQTT broker and OpenSync gateway will be exposed

Then open the _configs/digicert-mqtt-server.cnf_ file and replace the _commonName_default_ value with the domain your MQTT broker will be exposed on.

```
...
commonName_default   = mqtt-broker.openwifi.tip.build
...
```

Similarly open the _configs/configs/digicert-openssl-server.cnf_ file and add your domain(s) to the alternate names.

```
...
[ alternate_names ]
DNS.1  = opensync-redirector.openwifi.tip.build
DNS.2  = opensync-controller.openwifi.tip.build
...
```

Afterwards you can execute the generate script using your unique ID.

```bash
$ ./digicert-generate-server.sh demo-instance
...
$ ls generated
cacert.pem                  cassandraserverkey.pem         client_keystore.jks  kafkaserverkey.pem         mqttservercert.pem     postgresclientcert.pem     postgresclient.p12  serverkey.pem        truststore.jks
cassandraservercert.pem     cassandra_server_keystore.jks  client.pkcs12        kafka_server_keystore.jks  mqttserverkey_dec.pem  postgresclientkey_dec.pem  servercert.pem      server_keystore.jks
cassandraserverkey_dec.pem  cassandra-server.pkcs12        kafkaservercert.pem  kafka-server.pkcs12        mqttserverkey.pem      postgresclientkey.pem      serverkey_dec.pem   server.pkcs12
```

**!Do not loose the key files as they cannot be recreated!**

### Generate AP certificates

To generate an AP certificate you'll need:

* the manufacturer of your AP
* the MAC address of the primary interface of your ID
* the URL the AP will be redirected to

After collecting these infos you can generate an AP cert like so:

```bash
$ ./digicert-generate-ap-certs.sh Linksys ab:cd:ef:12:34:56 my-redirector.openwifi.tip.build
...
$ ls generated
ABCDEF123456.tar.gz  client_cacert.pem  clientcert.pem  client_deviceid.txt  clientkey_dec.pem  clientkey.pem
```

**!Do not loose the key files as they cannot be recreated!**

### Revoke cloud controller certificates

To be able to recreate a certificates for a cloud controller deployment, you need to revoke the previously issued certificates beforehand.

To revoke cloud controller certificates you'll need:

* the unique ID that you used to generate the certs initially, e.g. demo-instance

Afterwards execute `./digicert-revoke-server-certs.sh demo-instance` to revoke the certificates for this cloud controller.

### Revoke AP certificates

To be able to recreate a certificate for a certain AP, you need to revoke the previously issued certificate beforehand.

To revoke an AP certificate you'll need:

* the MAC address of the primary interface of your ID

Afterwards execute `./digicert-revoke-ap-certs.sh ab:cd:ef:12:34:56` to revoke the certificate of this device.
