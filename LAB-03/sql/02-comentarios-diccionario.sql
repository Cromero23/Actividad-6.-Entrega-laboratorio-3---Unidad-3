
-- ============================================================
-- LAB-03 — Politicas practicas, gobierno de datos y evidencias
-- Actividad 3: Diccionario de datos operativo
-- Motor: PostgreSQL 16.15
-- Base de datos: comercial
-- Tabla: public.clientes
-- Fecha: 16 de noviembre de 2026
-- ============================================================

-- NOTA:
-- Los comentarios ya fueron aplicados y verificados.
-- Este archivo documenta las instrucciones utilizadas.


-- 1. Comentario general de la tabla

COMMENT ON TABLE public.clientes IS
'Clientes de Comercializadora Norte. Propietario: Gerencia Comercial. Custodio: DBA. Clasificación: confidencial (contiene datos personales).';


-- 2. Identificador interno

COMMENT ON COLUMN public.clientes.id IS
'Identificador interno del cliente. Generado por el sistema.';


-- 3. Nombre del cliente

COMMENT ON COLUMN public.clientes.nombre IS
'Nombre completo. Dato personal identificador directo.';


-- 4. Correo electrónico

COMMENT ON COLUMN public.clientes.correo IS
'Correo de contacto. Dato personal. Uso: notificaciones al cliente.';


-- 5. Telefono

COMMENT ON COLUMN public.clientes.telefono IS
'Número telefónico del cliente. Dato personal. Uso: contacto y atención por parte de personal autorizado.';


-- 6. RFC

COMMENT ON COLUMN public.clientes.rfc IS
'RFC del cliente. Dato personal. Uso: facturación. Cambios auditados en auditoria.cambios_clientes.';


-- 7. Edad

COMMENT ON COLUMN public.clientes.edad IS
'Edad en años cumplidos. Dato personal. Uso: analítica agregada.';


-- 8. Ciudad

COMMENT ON COLUMN public.clientes.ciudad IS
'Ciudad de residencia del cliente. Dato de ubicación. Uso: atención comercial y análisis geográfico agregado.';


-- 9. Codigo postal

COMMENT ON COLUMN public.clientes.codigo_postal IS
'Código postal de residencia del cliente. Dato de ubicación. Uso: segmentación geográfica y análisis comercial.';


-- 10. Fecha de alta

COMMENT ON COLUMN public.clientes.fecha_alta IS
'Fecha de registro del cliente en el sistema. Uso: seguimiento de antiguedad y gestion comercial.';


-- 11. Segmento comercial

COMMENT ON COLUMN public.clientes.segmento IS
'Segmento comercial asignado al cliente. Uso: clasificacion de clientes y analisis comercial agregado.';


-- ============================================================
-- VERIFICACION DEL DICCIONARIO
-- ============================================================

SELECT
    c.ordinal_position AS pos,
    c.column_name AS columna,
    c.data_type AS tipo,
    c.character_maximum_length AS longitud,
    c.is_nullable AS acepta_nulos,
    c.column_default AS valor_por_defecto,
    col_description(
        'public.clientes'::regclass,
        c.ordinal_position
    ) AS descripcion
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'clientes'
ORDER BY c.ordinal_position;


-- ============================================================
-- RESULTADOS OBTENIDOS
-- ============================================================

-- Tabla documentada: public.clientes
-- Columnas documentadas: 10
-- Columnas sin descripcion: 0
--
-- Diccionario exportado:
-- evidencias/diccionario-clientes.csv
--
-- Archivo verificado mediante PowerShell:
-- Tamano: 1215 bytes
-- Registros: 10
--
-- Los comentarios agregan metadatos al esquema.
-- No modifican los registros de clientes.
-- ============================================================
