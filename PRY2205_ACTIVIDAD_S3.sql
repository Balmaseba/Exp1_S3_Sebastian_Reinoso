--------------------------------------------------------------------------------
-- Caso 1: ANALISIS DE PROPIEDADES
-- Consultar las propiedades agrupadas por tipo
SELECT p.ID_TIPO_PROPIEDAD AS TIPO,
        COUNT(*) AS TOTAL_PROPIEDADES,
        TO_CHAR(MAX(p.VALOR_ARRIENDO), 'FM$9G999G999D00', 'NLS_NUMERIC_CHARACTERS=''.,''') AS MAX_ARRIENDO,
        TO_CHAR(ROUND(AVG(p.VALOR_ARRIENDO)), 'FM$9G999G999', 'NLS_NUMERIC_CHARACTERS=''.,''') AS PROMEDIO_ARRIENDO,
        TO_CHAR(MIN(p.VALOR_ARRIENDO), 'FM$9G999G999D00', 'NLS_NUMERIC_CHARACTERS=''.,''') AS MIN_ARRIENDO,
        CASE
            WHEN MAX(p.VALOR_ARRIENDO) <= 1000000 THEN 'ESTÁNDAR'
            ELSE 'PREMIUM'
        END AS CLASIFICACION,
        TO_CHAR(SUM(NVL(p.VALOR_GASTO_COMUN, 0)), 'FM$9G999G999', 'NLS_NUMERIC_CHARACTERS=''.,''') AS TOTAL_GASTOS_COMUNES
FROM PROPIEDAD p
INNER JOIN TIPO_PROPIEDAD tp ON p.ID_TIPO_PROPIEDAD = tp.ID_TIPO_PROPIEDAD
GROUP BY p.ID_TIPO_PROPIEDAD
HAVING SUM(NVL(p.VALOR_GASTO_COMUN, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(p.VALOR_GASTO_COMUN,0)) DESC;

--------------------------------------------------------------------------------
-- Caso 2: ANÁLISIS DE ANTIGÜEDAD DE EMPLEADOS
-- Consultar los empleados y calcular sus bonos de antigüedad
SELECT e.NOMBRE_EMP || ' ' || e.APPATERNO_EMP AS "Nombre Empleado",
        TO_CHAR(e.SUELDO_EMP, 'FM$9G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo con Formato",
        CASE
            WHEN e.SUELDO_EMP > 2000000 THEN 'ALTO'
            ELSE 'MEDIO'
        END AS "Clasificación Sueldo",
        TRUNC(MONTHS_BETWEEN(SYSDATE, e.FECING_EMP) / 12) AS "Años Antigüedad",
        CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.FECING_EMP) / 12) BETWEEN 5 AND 10
                THEN 'Corresponde bono 5%: ' || TO_CHAR(ROUND(e.SUELDO_EMP * 0.05), 'FM$9G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.FECING_EMP) / 12) BETWEEN 11 AND 20
                THEN 'Corresponde bono 10%: ' || TO_CHAR(ROUND(e.SUELDO_EMP * 0.10), 'FM$9G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.FECING_EMP) / 12) > 20
                THEN 'Corresponde bono 15%: ' || TO_CHAR(ROUND(e.SUELDO_EMP * 0.15), 'FM$9G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
            ELSE 'Sin bono'
        END AS BONO
FROM EMPLEADO e
WHERE e.ID_CATEGORIA_EMP = 3
    AND e.ID_SUCURSAL <> &CODIGO_SUCURSAL
    AND TRUNC(MONTHS_BETWEEN(SYSDATE, e.FECING_EMP) / 12) > 5
ORDER BY e.SUELDO_EMP DESC;

--------------------------------------------------------------------------------
-- Caso 3: Lista de clientes
-- Consultar la cantidad de clientes agrupados por clasificacion de renta y disponibilidad de teléfonos
SELECT CASE
            WHEN c.RENTA_CLI >= 1000000 THEN 'PREMIUM'
            WHEN c.RENTA_CLI >= 600000 THEN 'ALTA'
            WHEN c.RENTA_CLI >= 300000 THEN 'MEDIA'
            ELSE 'BAJA'
        END AS CLASIFICACION_RENTA,
        COUNT(*) AS CANTIDAD_CLIENTES,
        TO_CHAR(ROUND(AVG(c.RENTA_CLI)), 'FM$9G999G999','NLS_NUMERIC_CHARACTERS='',.''') AS RENTA_PROMEDIO,
        CASE
            WHEN COUNT(c.FONOFIJO_CLI) + COUNT(c.CELULAR_CLI) > 0
                THEN 'Clientes con Teléfono'
            ELSE 'Clientes sin Teléfono'
        END AS ESTADO_TELEFONO
FROM CLIENTE c
GROUP BY CASE  
            WHEN c.RENTA_CLI >= 1000000 THEN 'PREMIUM'
            WHEN c.RENTA_CLI >= 600000 THEN 'ALTA'
            WHEN c.RENTA_CLI >= 300000 THEN 'MEDIA'
            ELSE 'BAJA'
        END
HAVING AVG(c.RENTA_CLI) > 200000
ORDER BY CLASIFICACION_RENTA ASC;



