#!/bin/bash

#######################################################
#  This is set up to install the AllergenCheckerApp   #
#######################################################

# sudo cp -r Allergen_Checker/AllergenCheckerApp/build/web/ /var/www/html/
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.12 python3.12-venv
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1
sudo update-alternatives --config python

sudo apt install pipenv