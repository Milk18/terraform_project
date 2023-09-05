# Milkers Terraform
## _My Last Terraform project, Ever_

[![N|Solid](https://png.pngitem.com/pimgs/s/266-2664000_transparent-cow-head-png-face-of-a-cow.png)](https://www.youtube.com/watch?v=xm3YgoEiEDc)

Milkers is a website to manage your books.

- Clone the repository to your local computer
- Configure terraform with your personal provider (preferably azurerm) and run terraform init
- Create your special terraform.tfvars and vars.tf files with your own passwords and variables
- Run the code with terraform apply
- ✨Magic ✨


> Terraform is an Iaac tool that creates and manages resources on cloud platforms and 
> other services through their application programming interfaces 
> (APIs)


## Tech

Milkers uses a number of open source projects to work properly:

- [Terraform] - Build, change, and destroy Azure infrastructure using Terraform!
- [Python Flask] - Flask is a micro web framework written in Python.
- [Python psycopg2] - Psycopg is the most popular PostgreSQL database adapter for the 
  Python programming language.
- [Postgresql] - The database we used.
- [Azure CLI] - a set of commands used to create and manage Azure resources.


## Installation

Milkers requires [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli), [Azure subscription](https://azure.microsoft.com/en-us/get-started/azure-portal) and [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) to run.

Install the dependencies to start the server.

To connect terraform to your azure subscription, run the following commands:
```sh
az login --tenant <your subscription id>
```
Follow the provided links for further configurations.

Make sure that if you are using windows, you need to add terraform to your PATH. 
See ["how to change PATH system variable?"](https://www.java.com/en/download/help/path.html)

## Terraform
### terraform_directory:
- **<u> main.tf:</u>**  The primary Terraform configuration file. It defines and provides data to the Terraform modules used in the project. This is where most of the infrastructure-as-code magic happens.
- **<u> output.tf:</u>** Contains definitions of values to output after terraform apply is run. These values might include IP addresses, URLs, or other useful data.
- **<u> providers.tf:</u>** Specifies and configures the providers used in the Terraform configuration. This is where you define the cloud providers (e.g., AWS, Azure) and any required settings.
- **<u> variables.tf:</u>**  Contains variable definitions for Terraform. Variables are often used to generalize configurations, making it easier to reuse or adapt the code for different environments or purposes.


## Python 
### milkers_flask_app directory:
- **<u> init_db.py:</u>**  A Python script responsible for initializing and setting up the database. This includes creating tables, setting up indices, and populating initial data.
- **<u> milkers.py:</u>**  The primary Flask web application. This script runs the web server, defines routes, handles database interactions, and serves the application's webpages. This is what makes it all possible and accessible to the web. It uses flask and psycopg2 packages.


## Bash
### shell_scripts directory:
- **<u> db_script.bash:</u>**  Bash script designed for the setup and configuration of the database server. This includes installing necessary packages, adjusting configurations, and invoking other scripts like export_script.
- **<u> web_script.bash:</u>**  Bash script for setting up and configuring the web server environment. This includes steps like installing required packages, setting up virtual environments, or starting the Flask app defined in milkers.py.
- **<u> export_script.bash:</u>** Bash script that exports necessary environment variables. These environment variables include database credentials, port numbers, or other configuration values required by the Flask application or database.

If for some reason the DB vm has crashed , we need to restart the vm and start the postgres client:
```bash
sudo systemctl start postgresql.service
```
###
If for some reason the WEB vm has crashed we need to do the following steps:
1. In order to run the commands in a root shell:
```bash
sudo -s 
```
2. Export the necessary environment variables ((DB_PASS is a secret) :
```bash
export APP_PORT=8080 DB_IP=10.1.1.4 DB_USER=oriu DB_PASS=* WEB_SNET=10.1.0.0/24
```
<sup> Make sure the values and keys are correct according to your terraform 'variables.tf' file and export script </sup> 

3. Run the milkers.py python script in the background:
```bash
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/milkers.py &
```
4. Exit the root shell:
```bash
exit 
```
<sup> Note that you need to make sure that the envs in the export command are correct and that your DB vm is up and running. </sup>

####

<span style="font-family:Coursive; font-size:2em;"> That's it folks! You can now start milking!</span> 🐄👨‍🌾🥛 







[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [Terraform]: <https://developer.hashicorp.com/terraform/tutorials/azure-get-started>
   [Python Flask]: <https://flask.palletsprojects.com/en/2.3.x/>
   [Python psycopg2]: <https://pypi.org/project/psycopg2/>
   [Postgresql]: <https://www.postgresql.org/docs/>
   [Azure CLI]: <https://learn.microsoft.com/en-us/cli/azure/>

 
