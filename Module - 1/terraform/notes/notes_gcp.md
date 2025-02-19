## Table of Contents
- [Creating VM instance and setting SSH keys](#creating-a-vm-instance-and-setting-up-ssh-keys)
- [Configuring VM Instance](#configuring-vm-instance)
- [Insatlling applications in the VM](#installing-anaconda-in-the-vm)
    - [Installing Anaconda](#installing-anaconda-in-the-vm)
    - [Installing Docker](#installing-docker-in-the-vm)
    - [Installing pgcli](#installing-pgcli-in-the-vm)
    - [Installing Terraform](#install-terraform)
- [Cloning DE github repo in the VM](#clone-this-repo-in-the-vm)
- [Configuring VScode to access the VM](#how-to-configure-vscode-to-access-the-vm)
- [Things to keep in mind](#things-to-keep-in-mind)
- [Common Commands](#commonly-used-commands)

### DE Zoomcamp 1.4.1 - Setting up the Environment on Google Cloud (Cloud VM + SSH access)

#### Creating a VM instance and setting up SSH keys. 
1. We will create a VM instance in GCP (compute engine), but before we do, we need to set up SSH keys to be able to connect to the VM's - 
    You can find the google doc [here](https://cloud.google.com/compute/docs/connect/create-ssh-keys)
    - Go to `.ssh/` folder in git bash and run the below command, changing the filename and username accordingly. 
    > ssh-keygen -t rsa -f ~/.ssh/<KEY_FILENAME> -C <USERNAME>

2. Add this ssh-key to GCP.
    - Go to google console > settings > metadata > ssh keys 
    - cat key_filename.pub in bash to get the public key, then copy it. 
    - Paste the key in ssh keys, add key. 

3. Create a New VM Instance. 
    - Machine Configs: 
        - instance name: `de-zoomcamp`
        - region: `europe-west1 (belgium)`
        - machine type: `e2-standard-4 (4 vCPU, 2 core, 16 GB memory)`
    - OS & Storage:
        - OS: `Ubuntu`
        - version: `Ubuntu 20.04 LTS`
        - size: `30GB`

4. Once created, copy the `External IP` and run the command `ssh -i ~/.ssh/<filename> <username>@<external-ip>` (ssh -i ~/.ssh/gcp rimsha@35.187.97.60) on gitbash. 
    The IP address will be added as a known host. 
    > Note : The command ssh -i filename username@external_ip_address is used to connect to a remote server securely via SSH (Secure Shell) using a private key for authentication.
    > What Happens When You Run This Command?
    > SSH will attempt to authenticate to the remote server using the provided private key (from the -i option).
    > The remote server will check if the corresponding public key is authorized for the username you're logging in as.
    > If the authentication is successful, you'll be granted access to the remote machine, and you'll be able to run commands as that user.

5. Run `htop` on the shell that opens on executing above command. It will display VM details. (We're inside the VM)

6. We've already downloaded Google SDK (check here). 

```bash
    rimsha@de-zoomcamp:~$ htop
    rimsha@de-zoomcamp:~$ ls
    rimsha@de-zoomcamp:~$ gcloud --version
    Google Cloud SDK 510.0.0
    alpha 2025.02.10
    beta 2025.02.10
    bq 2.1.12
    bundled-python3-unix 3.12.8
    core 2025.02.10
    gcloud-crc32c 1.0.0
    gsutil 5.33
    minikube 1.35.0
    skaffold 2.13.1
```
#### Configuring VM instance
7. Now we need to configure the VM instance just created with the required dependencies. (running in the bash shell that opens after ssh -i command)
    
    - Open another gitbash (home dir) and setup a config file in `~/.ssh/config`
        >Host de-zoomcamp 
        >    HostName 35.187.97.60
        >    User rimsha
        >    IdentityFile ~/.ssh/gcp
    - Run `ssh de-zoomcamp`
    
    Note: For some reason, entering the entire path (as mentioned in the lecture vid), i.e. `c:/Users/rimsh/.ssh/gcp` in the config file gave an error on running `ssh de-zoomcamp`.
    So, I changed it to  `~/.ssh/gcp`, which worked. 

    ```bash
    $ ssh de-zoomcamp
    Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1075-gcp x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/pro

    System information as of Tue Feb 18 12:21:07 UTC 2025

    System load:  0.0                Processes:             123
    Usage of /:   32.5% of 28.89GB   Users logged in:       1
    Memory usage: 5%                 IPv4 address for ens4: *
    Swap usage:   0%


    Expanded Security Maintenance for Applications is not enabled.

    0 updates can be applied immediately.

    Enable ESM Apps to receive additional future security updates.
    See https://ubuntu.com/esm or run: sudo pro status

    New release '22.04.5 LTS' available.
    Run 'do-release-upgrade' to upgrade to it.


    Last login: Tue Feb 18 11:54:46 2025 from *
    ```

You can use `logout` to logout/disconnect from the VM session (that you logged in to by using ssh de-zoomcamp). Then login again. 


#### Installing Anaconda in the VM
    - After you run `ssh de-zoomcamp`, follow:
        - Go to [Anaconda Download](https://www.anaconda.com/download/success) and download the Linux distribution for the Ubuntu VM. 
        - Run the command `wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh` in the bash shell. 
        - After it completes, run the installer `bash Anaconda3-2024.10-1-Linux-x86_64.sh` (as displayed after running above command) to enter anaconda shell. 
        - Scroll through terms of service and enter `yes` to agree when prompted. 
        - Anaconda will then be downloaded in the specified location. 

#### Troubleshooting anaconda installation issues
If you're not seeing the `(base)` environment when you open a new terminal after running `ssh de-zoomcamp` or when `which python` gives no result, you may need to initialize Conda properly and ensure the environment is set up in your terminal session.
    - Run `conda init` to Initialize Conda, but if Conda is not recognized even though you have installed anaconda distribution-- check if the PATH is added. 
    - Run `nano ~/.bashrc` and append to the end `export PATH="$HOME/anaconda3/bin:$PATH"`, then ctr+o to save and ctr+x to exit.  
    - Then, reload the shell config `source ~/.bashrc` or simply exit the terminal and login again using `ssh de-zoomcamp`.
    - Run `conda --version` or `which python` to check whether conda is recognized. 

Note: You can run `conda activate base` to activate base env if necessary.

#### Installing docker in the VM. 

1. Run `sudo apt-get update`
    - `apt-get` is the package management tool used to handle packages on your system.
    - `update` tells `apt-get` to update the list of available packages from the repositories that are defined in your system. Repositories are basically the online locations (servers) where package files are stored.

Before installing or upgrading any software on your system, it's a good practice to run sudo apt-get update to ensure your system is aware of the latest package versions available in the repositories.

2. Run `sudo apt-get install docker.io`. The command installs Docker from the Ubuntu repositories. 

3. Run `docker` to confirm installation.

4. Typically, you'd have to use sudo docker for every command, so to avoid this and give it the necesarry permissions, run the commands mentioned [here](https://gist.github.com/kevmo/22e5e36ee897a23156050c28703f266d). 
    - Add the docker group if it doesn't already exist - `sudo groupadd docker`
    - Add the connected user $USER to the docker group - `sudo gpasswd -a $USER docker`
        Optionally change the username to match your preferred user.
    - Restart the docker daemon - `sudo service docker restart`
    - `logout` so your group membership is re-evaluated. 
    - Re-login and run `docker run hello-world`. It will be successful.

5. Download docker-compose 
    - Go to [docker-compose releases in Github](https://github.com/docker/compose/releases) and copy the link for [docker-compose-linux-x86_64](hhttps://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-x86_64)
    - `mkdir bin` and `cd bin`
    - Run `wget https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-x86_64 -O docker-compose`
    - Make the file executable : `chmod +x docker-compose`
    - Run `./docker-compose` (we're in bin/) and `./docker-compose --version`
    - Now, we don't want to do this from the bin directory each time, so we add it to the env path. 
        - Run `nano .bashrc`
        - Append `export PATH="${HOME}/bin:${PATH}"`, ctr+o and ctr+x
        - `source .bashrc` - logout, login functionality basically.
        - Run `docker-compose --version` / `which docker-compose` for confirmation.   

#### Installing pgcli in the VM

1. Go to github repo > Module - 1 > docker_sql, and run `docker-compose up -d`. 
2. Run `docker ps` to confirm whether pgadmin and postgres:13 are running.
3. Now, in another bash window, connect to remote vm/login using ssh de-zoomcamp, then run `pip install pgcli`
4. Run `pgcli -h localhost -U root -d ny_taxi` (ignore keyring warning - or fix it by downloading a keyring package. Not dealing with this rn)
5. `root@localhost:ny_taxi` is avaiable-- run `\dt`
6. To by pass some errors and warnings, uninstall pgcli - `pip uninstall pgcli` and reinstall using conda -- `conda insall -c conda-forge pgcli`. You'll see no errors. 
7. But you can't rerun `pgcli -h localhost -U root -d ny_taxi`, so run `pip install -U mycli`
8. Run `pgcli -h localhost -U root -d ny_taxi` >> **!ERROR!** (from [here](https://www.youtube.com/watch?v=ae-CV2KfoN0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=14))

*In the vid, he goes on to run jupyter notebook in the VM shell to execute the local_ny_ingest.ipynb file (cell by cell).. and upon successfully running the above pgcli command, he's in `root@localhost:ny_taxi`-- where he runs `/dt` and the data is available* 

#### Install Terraform

1. Run `wget https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip`
2. `sudo apt-get install unzip`
3. `unzip terraform_1.10.5_linux_amd64.zip`
4. `rm terraform_1.10.5_linux_amd64.zip`
5. Before running the terraform files, we need to copy the service account credentials into this VM's folders. 
    - Go to the terraform folder on your local computer. 
    - Run `sftp de-zoomcamp`
    - `mkdir .gc`
    - `cd .gc`
    - Run `put sa-creds.json`
    Now, if you check cd .gc in the VM (ssh de-zoomcamp), you'll see `sa-creds.json` there. 
6. Set credentials - `export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/sa-creds.json`
7. Authenticate and activate service account - `gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS`

**ERROR**: I get error on running `terraform init` and `terraform plan`. 
```
│ Error: JSON credentials are not valid
│
│   with provider["registry.terraform.io/hashicorp/google"],
│   on main.tf line 10, in provider "google":
│   10: provider "google" {
│
│ invalid character 'g' looking for beginning of value
╵
╷
│ Error: JSON credentials are not valid: invalid character 'g' looking for beginning of value
│
│   with provider["registry.terraform.io/hashicorp/google"],
│   on main.tf line 11, in provider "google":
│   11:   credentials = "gcp-terraform/keys/sa-creds.json"
│
╵
```
#### Troubleshooting Terrform errors on VM
    1. Modify `main.tf` > `credentials=file("gcp-terraform/keys/sa-creds.json")`
    OR
    2. Comment credentials, and instead pass it as GOOGLE_APPLICATION_CREDENTIALS each time before running terraform. 
        - `export GOOGLE_APPLICATION_CREDENTIALS = './gcp-terraform/keys/sa-creds.json'` (local)
        - `export GOOGLE_APPLICATION_CREDENTIALS = ~/.gc/sa-creds.json` (VM)
    **Method 2 resolved the error**

#### Clone this repo in the VM 

1. Run `ssh de-zoomcamp`
2. Run `git clone https://github.com/Rimsha-Bashir/Data-Engineering-Project-ZC-2025.git`. Cloning in the HTTP format allows you to be anonymous and you don't have to configure ssh keys in the vm again. 

#### How to configure VScode to access the VM. 

1. Install the `Remote-SSH` extension and click `F1` to open command palette Enter `Remote-SSH: Connect to host` and you should see the option `de-zoomcamp`, since we already created the config file.
2. Another vscode window will open up.   
3. Port forwarding : **!!RECHECK!! CONNECTION TIMEOUT FOR PORT:5432!!** (from [here](https://www.youtube.com/watch?v=ae-CV2KfoN0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=14))

#### Things to keep in mind

1. Everytime you shut down the VM and restart it, the external IP address changes, and so, you'll have to update the config file in the .ssh foler accordingly. 

#### Commonly used commands 

- `ssh hostname/username@hostname/ipaddress` : Uses the config file for the parameters
- `ssh -i ~/.ssh/<filename> <username>@<external-ip>` : Manually entering config parameters
Both methods will connect you to the same remote machine, assuming you have the same information configured correctly in the SSH config file.
- `sudo shutdown now` to close ssh connections. It is equivalent to stopping the VM instance from the google console.


### DE Zoomcamp 1.6.1 - Docker Module Walk-Through on WSL

- Similar to what we do in Gitbash. 
- If you get an error on running 
  ```docker run -it \
        -e POSTGRES_USER="root" \
        -e POSTGRES_PASSWORD="root" \
        -e POSTGRES_DB="ny_taxi" \
        -v "C:\Users\rimsh\Desktop\rimsha\github\DECamp-2025\Module - 1\docker_sql\ny_taxi_data:/var/lib/postgresql/data" \
        -p 5433:5432 \
        --network=pg-network \
        --name pg-database \
        postgres:13
    ```
    - Run `docker volume create --name dtc_postgres_volume_local -d local` 
      (It'll s how up in docker desktop > volumes)
      And then, 
      ```
        docker run -it \
            -e POSTGRES_USER="root" \
            -e POSTGRES_PASSWORD="root" \
            -e POSTGRES_DB="ny_taxi" \
            -v dtc_postgres_volume_local:/var/lib/postgresql/data" \
            -p 5433:5432 \
            --network=pg-network \
            --name pg-database \
            postgres:13```
    - Accordingly befor eyou run docker-compose, add volume tag data in the yaml file as well. (Check [here](https://www.youtube.com/watch?v=Mv4zFm2AwzQ&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=17))
     

    > Note: Volumes are persistent data stores for containers, created and managed by Docker. You can create a volume explicitly using the docker volume create command, or Docker can create a volume during container or service creation.

    - Run `wsl` on cmd or powershell, or your PS terminal here, and you can run the commands from all lectures (with some tweaking here and there- check YT vid) on vscode. 