sudo apt-get update

sudo apt-get install python3.10-distutils
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.10 get-pip.py
sudo apt-get install -y pkg-config libcairo2-dev libgirepository1.0-dev
sudo apt-get install python3-pip python3-dev libpq-dev nginx curl
sudo apt install certbot python3-certbot-nginx
sudo apt install ttf-mscorefonts-installer

sudo ufw enable
sudo ufw allow 22 && ufw allow 80 && ufw allow 443 && ufw allow 3306 && ufw allow 6379

# goto dir
pip3 install virtualenv
virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Test server
python3 manage.py initial-data
python3 manage.py generate-deployment-conf
python3 manage.py migrate

gunicorn --bind 0.0.0.0:8000 config.wsgi


# Config NGINX
cp deployments/nginx.prod.conf /etc/nginx/sites-available/%APP_NAME%.conf
sudo ln -s /etc/nginx/sites-available/%APP_NAME%.conf /etc/nginx/sites-enabled

# Install Supervisor
sudo apt-get install supervisor
sudo rm /etc/supervisor/conf.d/supervisor.conf
sudo cp deployments/supervisor.prod.conf /etc/supervisor/conf.d/%APP_NAME%.conf

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start %APP_NAME%

# Reload code after deploy
sudo nginx -t && systemctl restart nginx && supervisorctl restart %APP_NAME%
