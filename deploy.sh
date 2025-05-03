#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

#Colores y utilidades
info() { echo -e "🔹 $1"; }
success() { echo -e "✅ $1"; }
warning() { echo -e "⚠️  $1" >&2; }
error() { echo -e "❌ $1" >&2; exit 1; }

#Detectar sistema operativo
OS_TYPE="$(uname | tr '[:upper:]' '[:lower:]')"
case "$OS_TYPE" in
    mingw* | cygwin*) SYSTEM="windows" ;;
    linux*) SYSTEM="linux" ;;
    darwin*) SYSTEM="mac" ;;
    *) SYSTEM="desconocido" ;;
esac

info "Sistema detectado: $SYSTEM"

#Validar Docker
if ! command -v docker &> /dev/null; then
    error "Docker no está instalado o no está en el PATH"
fi

if ! docker info &> /dev/null; then
    error "Docker no está corriendo. Inicia Docker Desktop y vuelve a intentarlo."
fi

success "Docker está funcionando correctamente"

#Iniciar Minikube
info "Iniciando Minikube con el driver de Docker..."
minikube start --driver=docker

#Crear carpeta organizada para proyectos
BASE_DIR="$HOME/proyectos-k8s"
mkdir -p "$BASE_DIR"

#Clonar repositorio de manifiestos
REPO_MANIFIESTOS_URL="https://github.com/Leovaldi/k8s-manifiestos"
MANIFIESTOS_DIR="${BASE_DIR}/k8s-manifiestos"

info "Clonando el repositorio de manifiestos en $MANIFIESTOS_DIR..."
rm -rf "$MANIFIESTOS_DIR"
git clone "$REPO_MANIFIESTOS_URL" "$MANIFIESTOS_DIR"

#Clonar repositorio de la página estática
REPO_STATIC_URL="https://github.com/Leovaldi/static-website"
STATIC_DIR="${BASE_DIR}/static-website"

info "Clonando el repositorio de la página estática en $STATIC_DIR..."
rm -rf "$STATIC_DIR"
git clone "$REPO_STATIC_URL" "$STATIC_DIR"

#Aplicar manifiestos de Kubernetes
info "Aplicando manifiestos de Kubernetes desde $MANIFIESTOS_DIR..."

K8S_PATHS=("deployments" "pv" "pvc" "services")

for dir in "${K8S_PATHS[@]}"; do
  FULL_PATH="${MANIFIESTOS_DIR}/${dir}"
  if [ -d "$FULL_PATH" ]; then
    info "Aplicando manifiestos en: $FULL_PATH"
    kubectl apply -f "$FULL_PATH"
  else
    error "El directorio $FULL_PATH no existe. Revisa si está bien clonado el repositorio."
  fi
done

#Confirmar que los pods están corriendo
info "Esperando a que los pods estén en estado 'Running'..."
kubectl wait --for=condition=ready pod --all --timeout=120s

#Verificar que al menos 1 pod tenga etiqueta "app=static-site" y esté listo
info "Verificando que el pod de la página estática esté listo..."
STATIC_POD=$(kubectl get pods -l app=static-site -o jsonpath="{.items[0].metadata.name}")

if [ -z "$STATIC_POD" ]; then
  error "No se encontró un pod con la etiqueta app=static-site. Revisa tus manifiestos."
fi

# NUEVO: Verificar permisos y archivos en el pod
info "Verificando archivos en el pod $STATIC_POD..."
kubectl exec "$STATIC_POD" -- ls -la /usr/share/nginx/html || warning "No se pudo verificar el contenido del pod"

# NUEVO: Corregir permisos si es necesario
info "Ajustando permisos en el pod..."
kubectl exec "$STATIC_POD" -- chmod -R 755 /usr/share/nginx/html || warning "No se pudieron ajustar los permisos"

kubectl wait --for=condition=ready pod/"$STATIC_POD" --timeout=30s
success "El pod $STATIC_POD está listo."

#Abrir servicio expuesto automáticamente
info "Buscando un servicio con tipo NodePort o LoadBalancer para abrir en el navegador..."

SERVICE_NAME=$(kubectl get svc --all-namespaces -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}' | head -n 1)

if [ -n "$SERVICE_NAME" ]; then
  info "Verificando acceso al servicio '$SERVICE_NAME'..."
  READY_ENDPOINTS=$(kubectl get endpoints "$SERVICE_NAME" -o jsonpath='{.subsets[*].addresses[*].ip}')
  if [ -z "$READY_ENDPOINTS" ]; then
    error "El servicio '$SERVICE_NAME' no tiene endpoints disponibles. Verifica que los pods estén conectados al servicio."
  fi
  info "Endpoints encontrados: $READY_ENDPOINTS"
  
  # NUEVO: Mostrar URL alternativa para acceso directo
  MINIKUBE_IP=$(minikube ip)
  NODE_PORT=$(kubectl get svc "$SERVICE_NAME" -o jsonpath='{.spec.ports[0].nodePort}')
  info "Alternativamente, puedes acceder directamente en: http://${MINIKUBE_IP}:${NODE_PORT}"
  
  info "Abriendo el servicio '$SERVICE_NAME' en el navegador..."
  minikube service "$SERVICE_NAME"
else
  SERVICE_NAME=$(kubectl get svc --all-namespaces -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].metadata.name}' | head -n 1)
  if [ -n "$SERVICE_NAME" ]; then
    info "Abriendo el servicio '$SERVICE_NAME' en el navegador..."
    minikube service "$SERVICE_NAME"
  else
    error "No se encontró ningún servicio expuesto como NodePort o LoadBalancer."
  fi
fi

#Final 
success "Script completado con éxito"