# Luis merino : Despliegue en aws con terraform y ansible
# 

# Para representar las salidas hace falta una construccion output
# primero sacamos ls ip del master
output "Jenkins-Main-Node-Public-Ip" {
  value = aws_instance.jenkins-master.public_ip
}

# despues sacamois las de los worker
output "Jenkins-Worker-Public-Ip" {
  value = {
    for instance in aws_instance.jenkins-worker-oregon :
    instance.id => instance.public_ip
  }
}

# Ahora es necesario sacar la dns del balanceador para acceder app
output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}