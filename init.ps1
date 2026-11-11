# Versión para Windows PowerShell del script init.sh
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Run($cmd) {
    Write-Host "  > $cmd"
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) { throw "Falló: $cmd" }
}

Write-Host "==> 1/5 Descargando imágenes (solo la primera vez)"
Run "docker compose pull"

Write-Host "==> 2/5 Arrancando PostgreSQL"
Run "docker compose up -d db"

Write-Host "==> 3/5 Creando la base 'prueba' (tarda unos minutos)"
Run "docker compose run --rm odoo odoo -d prueba -i sale_management,sale_stock,account --with-demo --stop-after-init --no-http"

Write-Host "==> 4/5 Activando descuentos y creando usuarios"
Get-Content -Raw scripts/setup_data.py | docker compose run --rm -T odoo odoo shell -d prueba --no-http
if ($LASTEXITCODE -ne 0) { throw "Falló la configuración de datos" }

Write-Host "==> 5/5 Arrancando Odoo y copiando el código fuente a .\odoo-src"
Run "docker compose up -d odoo"
if (Test-Path odoo-src) { Remove-Item -Recurse -Force odoo-src }
Run "docker compose cp odoo:/usr/lib/python3/dist-packages/odoo ./odoo-src"

Write-Host ""
Write-Host "Listo. Abre http://localhost:8069"
Write-Host "Usuarios: admin/admin, vendedor/vendedor, gerente/gerente"
