# Prueba técnica PyE — entorno Odoo 19

Este repo levanta en tu laptop un Odoo 19 Community con PostgreSQL usando Docker.
Es opcional: si ya tienes tu propia forma de montar Odoo 19, puedes usarla en la prueba.

La primera vez descarga las imágenes y crea la base, lo que tarda varios minutos.
Si puedes, levántalo antes de la prueba para no gastar ese tiempo.

## Requisitos

- Docker Desktop (Windows o macOS) o Docker Engine con el plugin `compose` (Linux).
  En Windows, Docker Desktop con el backend WSL2.
- 8 GB de RAM y unos 5 GB libres en disco.
- Git y un editor o IDE con soporte de Python (VS Code, PyCharm…).
- Funciona en procesadores Intel/AMD y en Mac con Apple Silicon.

## Inicializar

Linux, macOS o Git Bash / WSL en Windows:

```bash
bash init.sh
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\init.ps1
```

El script descarga las imágenes, crea la base `prueba` con Ventas, Inventario y Facturación,
carga datos de demostración, activa los descuentos en líneas de venta, crea los usuarios y
copia el código fuente de Odoo a `./odoo-src` para que puedas leerlo desde tu editor.

| Usuario | Contraseña | Rol |
| --- | --- | --- |
| admin | admin | Administrador |
| vendedor | vendedor | Ventas: solo sus documentos |
| gerente | gerente | Ventas: administrador |

## El día de la prueba

Te daremos la URL de un repo. Clónalo dentro de `addons/` con el nombre `prueba`:

```bash
git clone <url-que-te-daremos> addons/prueba
docker compose restart odoo
```

Odoo ya está configurado para buscar módulos en `addons/prueba`.

## Estructura

```
addons/        tus módulos (se montan en /mnt/extra-addons dentro del contenedor)
addons/prueba/ el repo del día de la prueba (lo clonas ese día)
config/        configuración de Odoo
odoo-src/      copia de solo lectura del código de Odoo (se genera con init)
scripts/       scripts de inicialización
```

Los módulos del core están en `odoo-src/addons/` (por ejemplo `odoo-src/addons/sale`).
Editar `odoo-src` no cambia nada: es solo para leer y navegar.

## Comandos útiles

| Para | Comando |
| --- | --- |
| Ver logs | `docker compose logs -f odoo` |
| Reiniciar Odoo (tras cambiar Python) | `docker compose restart odoo` |
| Instalar un módulo | `docker compose run --rm odoo odoo -d prueba -i <modulo> --stop-after-init --no-http` |
| Actualizar un módulo (tras cambiar XML o campos) | `docker compose run --rm odoo odoo -d prueba -u <modulo> --stop-after-init --no-http` |
| Correr los tests de un módulo | `docker compose run --rm odoo odoo -d prueba -u <modulo> --test-tags /<modulo> --stop-after-init --no-http` |
| Shell de Odoo | `docker compose run --rm odoo odoo shell -d prueba --no-http` |
| Depurar con `breakpoint()` | `docker compose stop odoo` y luego `docker compose run --rm --service-ports odoo odoo --dev=all` |
| Volver a empezar desde cero | `docker compose down -v` y de nuevo `bash init.sh` |

Después de instalar o actualizar un módulo, reinicia Odoo (`docker compose restart odoo`) y recarga el navegador.

Odoo corre en modo desarrollador (`--dev=all`): entre otras cosas, los errores de permisos
muestran su traceback en el log.
