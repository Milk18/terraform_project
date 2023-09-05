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
see ["how to change PATH system variable?"](https://www.java.com/en/download/help/path.html)

## That's it! You can now start milking! 🐄👨‍🌾🐄
##      ㅤㅤㅤㅤㅤㅤㅤㅤ ㅤㅤㅤ   ㅤㅤㅤㅤㅤㅤ      🥛💦🥛     


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [Terraform]: <https://developer.hashicorp.com/terraform/tutorials/azure-get-started>
   [Python Flask]: <https://flask.palletsprojects.com/en/2.3.x/>
   [Python psycopg2]: <https://pypi.org/project/psycopg2/>
   [Postgresql]: <https://www.postgresql.org/docs/>
   [Azure CLI]: <https://learn.microsoft.com/en-us/cli/azure/>

 
