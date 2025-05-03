#!/bin/bash

set -e

#FUNCIONES

function check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: $1 no está instalado."
    exit 1
  fi
}

function wait_for_pod() {
  echo "Esperando a que el pod esté en estado Running..."
  while true; do
    STATUS=$(kubectl get pods -o jsonpath="{.items[0].status.phase}")
    if [ "$STATUS" == "Running" ]; then
      echo "Pod en estado Running."
      break
    else
      sleep 2
    fi
  done
}

function open_browser() {
  echo "🌐 Abriendo navegador con el sitio web..."
  case "$OSTYPE" in
    linux*) xdg-open "$1" ;;
    darwin*) open "$1" ;;
    msys*) start "$1" ;;
    cygwin*) cygstart "$1" ;;
    *) echo "No se pudo abrir el navegador automáticamente." ;;
  esac
}

function fix_path() {
  case "$OSTYPE" in
    msys*|cygwin*)
      FIXED_PATH=$(cygpath -m "$1")
      ;;
    *)
      FIXED_PATH="$1"
      ;;
  esac
  echo "$FIXED_PATH"
}

#VERIFICAR DEPENDENCIAS

echo "Verificando herramientas necesarias..."

for cmd in minikube docker kubectl git; do
  check_command "$cmd"
done

#CREAR DIRECTORIO TEMPORAL Y CLONAR REPOS

WORKDIR="static_site_deploy_$(date +%s)"
mkdir "$WORKDIR"
cd "$WORKDIR"

echo "Clonando repositorios..."
git clone https://github.com/leovaldi/static-website.git
git clone https://github.com/leovaldi/k8s-manifiestos.git

#INICIAR MINIKUBE CON MOUNT

MOUNT_PATH=$(pwd)/static-website
MOUNT_PATH=$(fix_path "$MOUNT_PATH")

echo "Iniciando Minikube con volumen montado..."
minikube delete &> /dev/null || true
minikube start --driver=docker --mount --mount-string="$MOUNT_PATH:/mnt/web"

#APLICAR MANIFIESTOS

echo "Aplicando manifiestos..."
cd k8s-manifiestos
kubectl apply -f pv/
kubectl apply -f pvc/
kubectl apply -f deployments/
kubectl apply -f services/

#ESPERAR POD RUNNING

wait_for_pod

#ABRIR SITIO WEB

echo "🌍 Accediendo al sitio web..."
SERVICE_URL=$(minikube service static-site-service --url)
open_browser "$SERVICE_URL"

echo "Despliegue completado exitosamente."
