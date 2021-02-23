#!/bin/bash

brew install minikube
minikube start --driver='hyperkit'
minikube addons enable ingress

