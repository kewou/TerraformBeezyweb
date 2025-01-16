# Recherche de la zone Route 53 avec le nom de domaine
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

# Création de l'instance EC2
resource "aws_instance" "ec2_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }

  key_name       = var.key_name
  subnet_id      = var.subnet_id
  security_groups = var.security_groups

  user_data = <<-EOF
    #!/bin/bash
    # Chemin du fichier de configuration Nginx
    NGINX_CONF_PATH="/etc/nginx/conf.d/default.conf"

    # Récupère l'adresse IP publique via l'API des métadonnées AWS
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    # Vérifie si l'IP publique a été récupérée
    if [ -z "$PUBLIC_IP" ]; then
        echo "Erreur : Impossible de récupérer l'adresse IP publique" >> /var/log/nginx-update.log
        exit 1
    fi

    # Met à jour le fichier de configuration Nginx avec la nouvelle IP
    sed -i "s|proxy_pass http://.*:8080;|proxy_pass http://$PUBLIC_IP:8080;|g" $NGINX_CONF_PATH

    # Redémarre Nginx pour appliquer les changements
    systemctl restart nginx

    # Log de l'opération
    echo "Nginx mis à jour avec l'IP : $PUBLIC_IP" >> /var/log/nginx-update.log
  EOF
}

# Enregistrement DNS Route 53
resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.selected.id
  name    = var.route53_record_name
  type    = "A"
  ttl     = 300

  records = [aws_instance.ec2_instance.public_ip]
}

