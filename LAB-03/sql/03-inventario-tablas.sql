
-- ============================================================
-- LAB-03: Politicas practicas, gobierno de datos y evidencias
-- Actividad 4: Catalogo minimo de datos
-- Motor: PostgreSQL 16.15
-- Base de datos: comercial
-- Fecha: 16 de noviembre de 2026
-- ============================================================

-- Actualizacion de estadisticas realizada durante la practica.
-- ANALYZE;

-- Inventario tecnico de tablas ordinarias

SELECT
    n.nspname AS esquema,
    c.relname AS tabla,
    pg_get_userbyid(c.relowner) AS propietario_tecnico,
    c.reltuples::bigint AS filas_estimadas,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano,
    obj_description(c.oid, 'pg_class') AS descripcion
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2;


-- ============================================================
-- RESULTADOS OBSERVADOS
-- ============================================================

-- auditoria.cambios_clientes
-- Propietario tecnico: postgres
-- Filas estimadas: 10
-- Tamano: 32 kB
-- Descripcion: sin comentario registrado.

-- public.clientes
-- Propietario tecnico: postgres
-- Filas estimadas: 7
-- Tamano: 24 kB
-- Descripcion: Clientes de Comercializadora Norte.
-- Propietario de negocio: Gerencia Comercial.
-- Custodio: DBA.
-- Clasificacion: confidencial.

-- La vista dba.bitacora no aparece porque la consulta
-- enumera tablas ordinarias (relkind = 'r').

-- La tabla gobierno.solicitudes_cambio se creara
-- posteriormente durante la Actividad 7.

-- Las cantidades obtenidas son estimaciones estadisticas.
-- No representan necesariamente conteos exactos.
