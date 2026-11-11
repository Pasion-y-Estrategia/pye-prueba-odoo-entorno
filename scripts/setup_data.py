# Ejecutado dentro de `odoo shell` (la variable `env` ya existe).
# Activa los descuentos en líneas de venta y crea los usuarios de la prueba.

settings = env['res.config.settings'].create({'group_discount_per_so_line': True})
settings.execute()

g_user = env.ref('base.group_user')
g_salesman = env.ref('sales_team.group_sale_salesman')
g_manager = env.ref('sales_team.group_sale_manager')
g_stock = env.ref('stock.group_stock_user')
g_invoice = env.ref('account.group_account_invoice')

USERS = [
    # login, nombre, grupos
    ('vendedor', 'Valeria Vendedora', g_user | g_salesman | g_stock | g_invoice),
    ('gerente', 'Gabriel Gerente', g_user | g_manager | g_stock | g_invoice),
]

for login, name, groups in USERS:
    user = env['res.users'].with_context(no_reset_password=True).search([('login', '=', login)])
    vals = {
        'name': name,
        'login': login,
        'password': login,
        'email': f'{login}@prueba.local',
        'group_ids': [(6, 0, groups.ids)],
    }
    if user:
        user.write(vals)
    else:
        env['res.users'].with_context(no_reset_password=True).create(vals)

env['res.users'].browse(2).password = 'admin'
env.cr.commit()
print('OK: descuentos activos; usuarios admin/admin, vendedor/vendedor, gerente/gerente')
