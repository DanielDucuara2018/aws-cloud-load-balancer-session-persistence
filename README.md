# Sticky policies POC in aws cloud

## Goal

## Introduction

## Architecture

- Un VPC avec 2 Subets. Public / Privé
- Subnet public = 1 bouncer (mais pas besoin sur le papier vu que l'installation des site-web )
- NatGW sur le subnet public
- Subnet privé = 2 VMs avec 2 web app services replying "Congratulations, it's a web app AAA!" ou "Congratulations, it's a web app BBB!"
- 1 LBU qui round-robin sur chaque VM du subnet privé

## Requirements

python3.9
Flask>=2.2
Flask-Session>=0.5.0
gunicorn>=21.2.0

## Terraform

Initialize terraform:

```bash
terraform init
```

Apply terraform recipe:

```bash
terraform apply
```

Destroy terraform resources:

```bash
terraform destroy
```

## Bouncer VM

Check the web service on the web browser by using the public ip of the bouncer VM (Inspect the cookie value and its expiration date).

By default the haproxy uses the APP cookie sticky policy. You can use the LB cookie sticky policy by uncommenting the following line on the haproxy.cfg file:

```
cookie MYCOOKIE insert indirect nocache maxidle 20s maxlife 20s
```

and commenting the line:

```
cookie session prefix indirect nocache
```

Restart the haproxy service to apply the changes. 

```bash
sudo -i 
systemctl restart haproxy.service
```

Check the web service again on the web browser (Inspect the cookie value and its expiration date).

Note: Connect into the bouncer vm using ssh. Modify the haproxy config file. see [Recomendations](#recomendations)

## Load Balancer

Now check the load balancer service using its DNS. You have to get the same reponse from the web service as before.

Add Sticy policies into the Load Balancer instance by using the api calls:

to Add a LB cookie sticky policy use [doc](https://docs.aws.amazon.com/cli/latest/reference/elbv2/modify-target-group-attributes.html): 

```bash
aws elbv2 modify-target-group-attributes --target-group-arn "arn:aws:elasticloadbalancing:eu-west-3:224292614096:targetgroup/terraform-balancer-target-group/064dba88b9985a05" --attributes Key=stickiness.enabled,Value=true Key=stickiness.lb_cookie.duration_seconds,Value=20
```

to Add an APP cookie sticky policy use [doc](https://docs.aws.amazon.com/cli/latest/reference/elbv2/modify-target-group-attributes.html): 

```bash
aws elbv2 modify-target-group-attributes --target-group-arn "arn:aws:elasticloadbalancing:eu-west-3:224292614096:targetgroup/terraform-balancer-target-group/ed47c156212b0b81" --attributes Key=stickiness.enabled,Value=true Key=stickiness.type,Value=app_cookie Key=stickiness.app_cookie.cookie_name,Value=session Key=stickiness.app_cookie.duration_seconds,Value=10
```

Check the behavior on the web browser by using its DNS (Inspect the cookie value and its expiration date). 

For more information see [Sticky sessions for your Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/sticky-sessions.html)

## Recomendations

To access to the private vms, connect first into the public vm (Bouncer vm):

```bash
ssh-add <private_ssh_key>  
ssh -i <private_ssh_key> ubuntu@<public_ip_bouncer_vm> -A
```

then connect into the public vms:

```bash
ssh <private_ip_private_vm> -A
```

 
