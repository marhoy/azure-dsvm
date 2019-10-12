# azure-dsvm
Setting up an Azure Data Science Virtual Machine

# Creating SSL certificate for Jupyterhub

## Set up a web server on port 80

We need a webserver to serve the acme-challenge, e.g. nginx.

1. Enable and start nginx:
```bash
sudo systemctl enable nginx && sudo systemctl start nginx
```

2. In the Azure-portal, add a firewall rule to allow incoming TCP-requests on port 80

3. Create a directory for the acme-challenge:
By default, the ngingx webroot is at ```/usr/share/nginx/html```. Create a directory for the acme-challenge inside the webroot. We will run the ZeroSSL client as the www-data user, so we need to make the acme-challenge directory writable for the ```www-data``` user.

```bash
sudo mkdir -p /usr/share/nginx/html/.well-known/acme-challenge
sudo chmod 775 /usr/share/nginx/html/.well-known/acme-challenge
sudo chown www-data.www-data /usr/share/nginx/html/.well-known/acme-challenge
```


## Download ZeroSSL client
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


## Create new SSL certificates

1. Back up the existing certificate in ```/etc/jupyterhub/srv```

2. Make the certificate directory writable for the www-data user:
```bash
sudo chown www-data /etc/jupyterhub/srv
```

3. Use the client to generate a certificate:
```bash
le.pl --key account.key --csr domain.csr --csr-key server.key --crt server.crt --domains "nautilus.northeurope.cloudapp.azure.com" --generate-missing --path /webroot --unlink --api 2 --live
```

## Restart the JupyterHub server

```bash
sudo systemctl restart jupyterhub
```

## Create a cronjob to renew the certificate every month
```bash
crontab -l
0 0 1 * * docker run -it -v /etc/jupyterhub/srv:/data -v /usr/share/nginx/html/.well-known/acme-challenge:/webroot -u $(id -u www-data) --rm zerossl/client --key account.key --csr domain.csr --csr-key server.key --crt server.crt --domains "nautilus.northeurope.cloudapp.azure.com" --generate-missing --path /webroot --unlink --api 2 --live --quiet
```
