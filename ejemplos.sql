/*Sucursal = (nombreSucursal, ciudadSucursal, activo)
Cliente = (codCliente, dni, nombCliente, dirCliente, viveCliente)
Prestamo = (nroPrestamo, importe, nombreSucursal(fk))
PropietarioPrestamo = (codCliente(fk), nroPrestamo(fk))
Cuenta = (nroCuenta, saldo, nombreSurcursal(fk))
PropietarioCuenta = (nroCuenta(fk), codCliente(fk))*/

/*  • Ej: clientes con cuentas o préstamos en cualquier sucursal
    •  Ej: clientes con cuentas y préstamos en cualquier sucursal
    • Ej: clientes con cuentas y sin préstamos*/

SELECT DISTINCT c.codCliente, c.dni, c.nombCliente
FROM Cliente c
LEFT JOIN PropietarioPrestamo pp ON (c.codCliente = pp.codCliente)
UNION (SELECT c2.codCliente, c2.dni, c2.nombCliente
    FROM Cliente c2
    LEFT JOIN PropietarioCuenta pc ON (c2.codCliente = pc.codCliente)
);

SELECT DISTINCT c.codCliente, c.dni, c.nombCliente
FROM Cliente c
LEFT JOIN PropietarioPrestamo pp ON (c.codCliente = pp.codCliente)
INTERSECT (SELECT c2.codCliente, c2.dni, c2.nombCliente
    FROM Cliente c2
    LEFT JOIN PropietarioCuenta pc ON (c2.codCliente = pc.codCliente)
);

SELECT DISTINCT c.codCliente, c.dni, c.nombCliente
FROM Cliente c
LEFT JOIN PropietarioPrestamo pp ON (c.codCliente = pp.codCliente)
EXCEPT (SELECT c2.codCliente, c2.dni, c2.nombCliente
    FROM Cliente c2
    LEFT JOIN PropietarioCuenta pc ON (c2.codCliente = pc.codCliente)
);

/*• Ej: cantidad de cuentas con saldo mayor a $50000
• Ej: saldo promedio de las cuentas de la sucursal ‘X’
• Ej: importe del mayor préstamo otorgado por la sucursal ‘Y’
• Ej: importe total asignado a prestamos¨. */

SELECT COUNT(nroCuenta) as cantCuentas
FROM Cuenta
WHERE saldo>50000;

SELECT AVG(saldo) as promedio
FROM Cuenta
WHERE nombreSucursal = 'X';

SELECT MAX(importe) as maximo
FROM Prestamo
WHERE nombreSucursal = "Y";

SELECT SUM(importe) as total
FROM Prestamo;

/*• Ej: obtener saldo promedio de las cuentas de c/ sucursal
• Ej: presentar las sucursales junto con el saldo promedio de sus 
cuentas siempre y cuando supere los $200.000
• Ej: contar el Nº de clientes que tienen cuentas en cada sucursal
• Ej: saldo promedio de las cuentas de c/ cliente que vive en La 
Plata y tiene al menos 3 cuentas*/

SELECT c.nombreSucursal, AVG(saldo) as saldoPromedio
FROM Cuenta c
GROUP BY c.nombreSucursal;

SELECT c.nombreSucursal, AVG(saldo) as saldoPromedio
FROM Cuenta c
GROUP BY c.nombreSucursal
HAVING AVG(saldo) > 200000;

SELECT c.nombreSucursal, COUNT(DISTINCT pc.nroCliente) as cantidadCuentas
FROM PropietarioCuenta pc
INNER JOIN Cuenta c ON (pc.nroCuenta = c.nroCuenta)
GROUP BY c.nombreSucursal;

SELECT c.dni, AVG(saldo)
FROM Cliente c
INNER JOIN PropietarioCuenta pc ON (c.codCliente = pc.codCliente)
INNER JOIN Cuenta c2 ON (pc.nroCuenta= c2.nroCuenta)
WHERE c.viveCliente LIKE "La Plata";
GROUP BY c.dni, pc.codCliente
HAVING COUNT(DISTINCT pc.nroCuenta) >= 3;

/* Clientes con préstamos y cuentas en una misma sucursal de “La 
Plata*/

SELECT DISTINCT c.dni, c.nombCliente
FROM Cliente c
LEFT JOIN PropietarioPrestamo pp ON (pp.codCliente = c.codCliente)
LEFT JOIN Prestamo p ON (pp.nroPrestamo = p.nroPrestamo)
WHERE p.nombreSucursal = "La Plata" AND c.nroCliente IN (
    SELECT pc.codCliente
    FROM Cuenta c2
    INNER JOIN PropietarioCuenta pc ON (c2.nroCuenta = pc.nroCuenta)
    WHERE p.nombreSucursal = c2.nombreSucursal
);

/*• Ej: presentar las sucursales que tengan activo mayor que alguna otra
• Ej: presentar la sucursal que tenga activo superior a todas
• Ej: encontrar la sucursal que tiene el mayor saldo promedio
• Ej: clientes con cuenta en todas las sucursales*/

SELECT nombreSucursal, ciudadSucursal
FROM Sucursal
WHERE activo > SOME(
    SELECT activo
    FROM Sucursal
);

SELECT nombreSucursal
FROM Sucursal
WHERE activo >= ALL(
    SELECT activo
    FROM Sucursal
);

SELECT nombreSucursal
FROM Cuenta
GROUP BY nombreSucursal
HAVING AVG(saldo) >=ALL(
    SELECT AVG(saldo)
    FROM Cuenta
    GROUP BY nombreSucursal
);

SELECT c.dni, c.nombCliente
FROM Cliente c
WHERE NOT EXISTS(
    SELECT *
    FROM Sucursal s
    WHERE NOT EXISTS(
        SELECT *
        FROM Cuenta cta
        INNER JOIN PropietarioCuenta pc ON (cta.nroCuenta = pc.nroCuenta)
        WHERE c.codCliente = pc.codCliente
            AND cta.nombreSucursal = s.nombreSucursal
    )
);