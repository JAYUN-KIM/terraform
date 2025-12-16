#!/bin/bash
dnf install -y httpd
echo "My ALB web page" > /var/www/html/index.html
systemctl restart httpd
systemctl enable httpd
