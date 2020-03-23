# Creating an SSL certificate for Jupyterhub


## Set up a web server on port 80

We need a webserver accessible on port 80 in order to serve the acme-challenge. Let's use nginx:

1. Enable and start nginx:
```bash
sudo systemctl enable nginx && sudo systemctl start nginx
```

2. In the Azure-portal, add a firewall rule to allow incoming TCP-requests on port 80

3. Create a directory for the acme-challenge:
By default, the ngingx webroot is at ```/usr/share/nginx/html```. Create a directory for the acme-challenge inside the webroot. We will run the ZeroSSL client as the ```www-data``` user, so we need to make the acme-challenge directory writable for the ```www-data``` user.

```bash
sudo mkdir -p /usr/share/nginx/html/.well-known/acme-challenge
sudo chmod 775 /usr/share/nginx/html/.well-known/acme-challenge
sudo chown www-data.www-data /usr/share/nginx/html/.well-known/acme-challenge
```


## Download the ZeroSSL client
1. Add yourself to the docker group:
```bash
sudo usermod -aG docker $USER
```
Log out and in to activate the group change

2. Download the docker image with the ZeroSSL client:
```bash
docker pull zerossl/client
```

3. Create an alias for running the ZeroSSL client from the docker image:
Note that we map ```/webroot``` to the directory we created above, and ```/data``` to the directory where JupyterHub expects to find the certificates: ```/etc/jupyterhub/srv```. We also specify that the client shall run as the ```www-data``` user.
```bash
alias le.pl='docker run -it -v /etc/jupyterhub/srv:/data -v /usr/share/nginx/html/.well-known/acme-challenge:/webroot -u $(id -u www-data) --rm zerossl/client'
```


## Manually create the SSL certificate

1. Back up the existing certificate in ```/etc/jupyterhub/srv```

2. Make the certificate directory writable for the www-data user:
```bash
sudo chown www-data /etc/jupyterhub/srv
```

3. Use the client to generate a certificate:
NOTE: Until you're sure everything works, omit the ```--live``` option at the end. This will create a dummy-certificate. Add it back when things look good and you want to create a proper certificate.

```bash
export DOMAINS="nautilus.northeurope.cloudapp.azure.com"
le.pl --key account.key --csr domain.csr --csr-key server.key --crt server.crt --domains $DOMAINS --generate-missing --path /webroot --unlink --api 2 --live
```

4. Restart the JupyterHub server

In order for the JupyterHub to use the newly created certificate, it needs to be restarted.
```bash
sudo systemctl restart jupyterhub
```


## Create a cronjob that automatically renews the certificate

The certificate is valid for 90 days. Let's create a cronjob that runs every day at 0200 and renews the certificate when there is 10 or fewer days left until it expires. If there is more than 10 days left, nothing happpens.

If/when the certificate is renewed (the command exits with value 42), we also restart the JupyterHub server to load the new certificate.

NOTE: This has the side-effect of shutting down all running notebooks. AFAIK there is no way to make jupyterhub reload the certificate without stopping/starting it (it should e.g. be possible to send a SIGHUP).

```bash
crontab -l
0 2 * * * docker run -it -v /etc/jupyterhub/srv:/data -v /usr/share/nginx/html/.well-known/acme-challenge:/webroot -u $(id -u www-data) --rm zerossl/client --key account.key --csr domain.csr --csr-key server.key --crt server.crt --domains "nautilus.northeurope.cloudapp.azure.com" --generate-missing --path /webroot --unlink --api 2 --live --renew 10 --issue-code 42 --quiet ; if [ $? -eq 42 ]; then sudo systemctl restart jupyterhub; fi
```
