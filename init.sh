#!/usr/bin/env bash
# Prepara el entorno de la prueba: base de datos con ventas, inventario y
# facturación, datos demo, descuentos activos y usuarios de prueba.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> 1/5 Descargando imágenes (solo la primera vez)"
docker compose pull

echo "==> 2/5 Arrancando PostgreSQL"
docker compose up -d db

echo "==> 3/5 Creando la base 'prueba' (tarda unos minutos)"
docker compose run --rm odoo odoo -d prueba \
  -i sale_management,sale_stock,account --with-demo \
  --stop-after-init --no-http

echo "==> 4/5 Activando descuentos y creando usuarios"
docker compose run --rm -T odoo odoo shell -d prueba --no-http < scripts/setup_data.py

echo "==> 5/5 Arrancando Odoo y copiando el código fuente a ./odoo-src"
docker compose up -d odoo
rm -rf odoo-src
docker compose cp odoo:/usr/lib/python3/dist-packages/odoo ./odoo-src

echo
echo "Listo. Abre http://localhost:8069"
echo "Usuarios: admin/admin, vendedor/vendedor, gerente/gerente"
