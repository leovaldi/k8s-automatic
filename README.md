````markdown
# 🌐 Despliegue automático de sitio web estático con Kubernetes + Minikube

Este repositorio contiene los manifiestos necesarios para desplegar automáticamente un sitio web estático en un clúster local de Kubernetes usando Minikube. El despliegue se automatiza completamente con un script Bash.

---

## ✅ Requisitos previos

Asegúrate de tener instalados los siguientes programas:

- Git
- Docker
- Minikube (1.24.x o superior)
- Kubectl (1.21.x o superior)

> 💡 Nota: Si usás `--driver=docker`, Docker debe estar corriendo antes de iniciar Minikube.

---

## 🚀 Despliegue automático

1. Abre una terminal.
2. Clona este repositorio o descarga el script `deploy.sh`.
3. Da permisos de ejecución al script si es necesario:
   ```bash
   chmod +x deploy.sh
````

4. Ejecutá el script:

   ```bash
   ./deploy.sh
   ```

Este script:

* Verifica las herramientas necesarias.
* Clona automáticamente los repositorios:

  * [`static-website`](https://github.com/Leovaldi/static-website)
  * [`k8s-manifiestos`](https://github.com/Leovaldi/k8s-manifiestos)
* Inicia Minikube montando el sitio web.
* Aplica los manifiestos Kubernetes.
* Espera a que el pod esté en estado `Running`.
* Abre el sitio web automáticamente en el navegador.

> 🧭 Si el navegador **no se abre automáticamente**, podés abrir manualmente la URL ejecutando:

```bash
minikube service static-site-service --url
```

---

## 📁 Estructura esperada del repositorio

```
k8s-manifiestos/
├── deployments/
│   └── static-site-deployment.yaml
├── ingress/             # (vacío en esta versión)
├── pv/
│   └── static-site-pv.yaml
├── pvc/
│   └── static-site-pvc.yaml
├── services/
│   └── static-site-service.yaml
├── deploy.sh            # Script de automatización
├── README.md
```

---

## ✅ Sitio montado

El sitio se monta desde la carpeta `static-website` al path `/mnt/web` en el contenedor, y se expone mediante Nginx automáticamente.

---

## 🛠️ Troubleshooting

Si algo falla:

* Asegurate de tener Docker corriendo.
* Verifica los permisos de ejecución.
* Podés consultar los logs del pod con:

  ```bash
  kubectl logs <nombre-del-pod>
  ```
* Ingresar al contenedor:

  ```bash
  kubectl exec -it <nombre-del-pod> -- /bin/bash
  ls /usr/share/nginx/html
  ```

---

📌 Proyecto de [Leovaldi](https://github.com/Leovaldi)

```
