
````markdown
# 🚀 Script de Despliegue Kubernetes con Minikube

Este script (`deploy.sh`) automatiza el despliegue de un entorno Kubernetes local usando Minikube y Docker. Clona los repositorios necesarios, aplica manifiestos y abre automáticamente el servicio en el navegador.

---

## 📋 Requisitos previos

Antes de ejecutar el script, asegurate de tener instalado y funcionando:

### 🔧 Herramientas necesarias

| Herramienta         | Recomendación / Versión mínima |
|---------------------|-------------------------------|
| [Docker](https://www.docker.com/)             | ✅ Docker Desktop corriendo |
| [Minikube](https://minikube.sigs.k8s.io/docs/start/)          | ✅ v1.30 o superior |
| [kubectl](https://kubernetes.io/docs/tasks/tools/)            | ✅ v1.26 o superior |
| [Git](https://git-scm.com/)                 | ✅ para clonar repositorios |
| Bash (Linux/macOS o Git Bash en Windows) | ✅ Necesario para ejecutar el script |

> ⚠️ En **Windows**, se recomienda ejecutar este script desde **Git Bash** y tener **Docker Desktop activo** con el backend WSL2 o Hyper-V configurado correctamente.

---

## 📦 ¿Qué hace el script?

1. Verifica que Docker esté instalado y en ejecución.
2. Inicia Minikube con driver Docker.
3. Clona dos repositorios:
   - Uno con manifiestos Kubernetes.
   - Uno con una página estática para desplegar.
4. Aplica los manifiestos (deployments, PVCs, services).
5. Espera a que los Pods estén listos.
6. Verifica permisos y contenido del contenedor `nginx`.
7. Abre automáticamente el servicio expuesto en tu navegador.

---

## 🚀 Ejecución

1. Cloná este repositorio o guardá el script `deploy.sh`.

2. Asigná permisos de ejecución al script:

```bash
chmod +x deploy.sh
````

3. Ejecutalo:

```bash
./deploy.sh
```

---

## 🌐 Acceso a la página desplegada

El script detecta automáticamente un servicio tipo `NodePort` o `LoadBalancer`, y:

* Abre el servicio directamente usando `minikube service ...`.
* Te muestra una URL alternativa con la IP y puerto de Minikube en caso de que falle.

---

## 🧪 Verificación manual (opcional)

Si querés verificar manualmente:

```bash
kubectl get pods
kubectl get svc
minikube ip
```

---

## ❓ Problemas comunes

* `❌ Docker no está instalado o no está en el PATH` → Instalá Docker y asegurate que esté corriendo.
* `❌ El pod app=static-site no se encuentra` → Verificá que el manifiesto tenga la etiqueta correcta.
* `❌ El servicio no tiene endpoints disponibles` → Asegurate de que los pods estén conectados al servicio.
* `❌ error validating "/etc/kubernetes/...": dial tcp [::1]:8443: connect: connection refused` → Minikube no pudo levantar el API server. Recomendado:

  ```bash
  minikube delete
  minikube start --driver=docker
  ```

---

## 🧼 Limpieza (opcional)

Para eliminar todo lo creado:

```bash
minikube delete
```

---

## 📁 Estructura esperada del repositorio de manifiestos

El repositorio `k8s-manifiestos` debe tener una estructura como esta:

```
k8s-manifiestos/
├── deployments/
├── services/
├── pv/
└── pvc/
```

---

## ✍️ Autor

Leonel Valdivia – [GitHub](https://github.com/Leovaldi)

---

```

¿Querés que también te genere una versión en inglés o preferís mantenerlo solo en español?
```
