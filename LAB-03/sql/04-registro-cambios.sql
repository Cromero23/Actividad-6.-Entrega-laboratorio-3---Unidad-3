
-- ============================================================
-- LAB-03 - Actividad 7: Registro de cambios y conciliacion
-- Base de datos: comercial
-- Fecha: 16 de noviembre de 2026
-- Motor: PostgreSQL 16
-- Politica relacionada: POL-06
-- ============================================================
-- 1. IMPLEMENTACION REALIZADA
-- ============================================================

CREATE SCHEMA gobierno;

REVOKE ALL ON SCHEMA gobierno FROM PUBLIC;

CREATE TABLE gobierno.solicitudes_cambio (
    folio TEXT PRIMARY KEY,
    descripcion TEXT NOT NULL,
    solicitado_por TEXT NOT NULL,
    aprobado_por TEXT,
    ambiente TEXT NOT NULL
        CHECK (ambiente IN ('desarrollo', 'pruebas', 'produccion')),
    fecha_aprobacion TIMESTAMPTZ,
    ventana_inicio TIMESTAMPTZ,
    ventana_fin TIMESTAMPTZ
);

COMMENT ON TABLE gobierno.solicitudes_cambio IS
'Registro de solicitudes de cambio en la base comercial. Propietario: Comité de cambios. Custodio: DBA. Evidencia de POL-06.';

-- Solicitud academica simulada CAM-2026-014.
-- No representa una autorizacion empresarial real.

INSERT INTO gobierno.solicitudes_cambio VALUES (
    'CAM-2026-014',
    'Agregar columna canal_alta a clientes',
    'Gerencia Comercial',
    'Comite de cambios',
    'produccion',
    now() - interval '1 day',
    now() - interval '5 minutes',
    now() + interval '1 hour'
);

-- Se verifico la ventana antes de modificar la tabla.

SELECT
    folio,
    aprobado_por,
    ventana_inicio,
    ventana_fin,
    ventana_inicio <= now()
        AND now() <= ventana_fin AS dentro_de_ventana
FROM gobierno.solicitudes_cambio
WHERE folio = 'CAM-2026-014';

-- El resultado fue 't' al momento de la comprobacion.

ALTER TABLE public.clientes
ADD COLUMN canal_alta VARCHAR(20);

COMMENT ON COLUMN public.clientes.canal_alta IS
'Canal por el que se registro el cliente. Cambio CAM-2026-014.';


-- ============================================================
-- 2. CONSULTAS DE VERIFICACION
-- Estas consultas son de solo lectura.
-- ============================================================

-- Comprobar la solicitud registrada.

SELECT *
FROM gobierno.solicitudes_cambio
WHERE folio = 'CAM-2026-014';

-- Verificar la columna incorporada.

SELECT
    c.column_name AS columna,
    c.data_type AS tipo,
    c.character_maximum_length AS longitud,
    c.is_nullable AS acepta_nulos,
    col_description(
        'public.clientes'::regclass,
        c.ordinal_position
    ) AS descripcion
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'clientes'
  AND c.column_name = 'canal_alta';

-- Verificar que el disparador este habilitado.

SELECT
    tgname AS disparador,
    CASE tgenabled
        WHEN 'O' THEN 'HABILITADO'
        WHEN 'D' THEN 'DESHABILITADO'
        WHEN 'R' THEN 'SOLO REPLICA'
        WHEN 'A' THEN 'SIEMPRE'
    END AS estado
FROM pg_trigger
WHERE tgrelid = 'public.clientes'::regclass
  AND tgname = 'trg_auditoria_clientes';


-- ============================================================
-- 3. CONCILIACION CON LA BITACORA ACTIVA
-- ============================================================

-- Se utiliza 'sentencia:' porque el servidor registra
-- los mensajes de PostgreSQL en espanol.
-- Las lineas con posibles credenciales se ocultan.

SELECT
    num,
    left(linea, 23) AS momento,
    substring(linea FROM 'user=([^ ]*)') AS usuario,
    CASE
        WHEN linea ~* '(PASSWORD|IDENTIFIED BY)'
            THEN '[REDACTADO: posible credencial]'
        ELSE split_part(linea, 'sentencia: ', 2)
    END AS sentencia
FROM dba.bitacora
WHERE linea ~
    '(sentencia|statement): (CREATE|ALTER|DROP|GRANT|REVOKE)'
ORDER BY num;


-- ============================================================
-- 4. RESULTADOS OBSERVADOS
-- ============================================================

-- Solicitud: CAM-2026-014
-- Aprobador simulado: Comite de cambios
-- Ventana inicial: 2026-11-16 09:07:33 CST
-- Ventana final:   2026-11-16 10:12:33 CST
-- Comprobacion previa: dentro_de_ventana = true

-- Bitacora del 16 de noviembre de 2026:
--
-- Linea 35: CREATE SCHEMA gobierno
-- Linea 36: REVOKE ALL ON SCHEMA gobierno FROM PUBLIC
-- Linea 37: CREATE TABLE gobierno.solicitudes_cambio
-- Linea 42: ALTER TABLE public.clientes ADD COLUMN canal_alta
--
-- Usuario registrado: postgres
-- ALTER TABLE registrado: 09:13:50 CST
-- Resultado SQL observado: ALTER TABLE

-- Bitacora historica del 28 de octubre de 2026:
--
-- Linea 164: GRANT UPDATE, usuario postgres
-- Linea 553: DISABLE TRIGGER, usuario app_ventas
-- Linea 554: ERROR por falta de propiedad de la tabla
-- Linea 555: SENTENCIA fallida de app_ventas
-- Linea 589: DISABLE TRIGGER, sesion postgres
-- Linea 602: ENABLE TRIGGER, sesion postgres
--
-- Estado actual verificado:
-- trg_auditoria_clientes = HABILITADO

-- Los cambios historicos no cuentan con un folio
-- de autorizacion identificado en las evidencias.

-- ============================================================
-- NOTA DE SEGURIDAD
-- ============================================================

-- Los registros pueden contener credenciales o datos
-- personales. Deben revisarse y redactarse antes
-- de compartir una exportacion completa.
--
-- El reporte de hallazgos se guardara en:
-- evidencias/06-conciliacion.md
-- ============================================================
