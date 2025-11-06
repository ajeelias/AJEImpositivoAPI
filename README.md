# AJE Impositivo API Class

[![Clarion](https://img.shields.io/badge/Clarion-Library-blue.svg)](https://www.softvelocity.com/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![AFIP](https://img.shields.io/badge/AFIP-Integration-green.svg)](https://www.afip.gob.ar/)

Biblioteca Clarion para integración con servicios web de AFIP (Administración Federal de Ingresos Públicos) de Argentina.

## 📋 Descripción

Esta biblioteca proporciona una clase completa en Clarion para la integración con los servicios web de AFIP, incluyendo:

- **Facturación Electrónica** (WSFE)
- **Factura Electrónica de Crédito** (WSFECred)
- **Consulta de Padrones** (A5, A13)
- **Autenticación y gestión de tokens** (WSAA)

## ✨ Características

- ✅ Autenticación automática con WSAA usando certificados digitales
- ✅ Gestión inteligente de tokens con caché y renovación automática
- ✅ Soporte para ambientes de Producción y Homologación
- ✅ Comunicación SOAP con servicios AFIP
- ✅ Generación y parseo de XML automático
- ✅ Manejo robusto de errores
- ✅ Integración con OpenSSL para firma de certificados

## 🏗️ Arquitectura

```
AJEImpositivoApiClass (extends AJEBaseApiClass)
│
├── Autenticación
│   └── LoginTicket() - Gestión de tokens y firma con OpenSSL
│
├── Consultas
│   ├── ConsultarA5() - Datos de contribuyentes
│   ├── ConsultarUltimoNumero() - Último comprobante autorizado
│   └── ConsultarMontoObligadoRecepcion() - Validación FCE
│
├── Facturación Electrónica
│   └── SolicitarCAE() - Solicitud de CAE para facturas
│
└── Gestión XML
    ├── CrearXML() - Generación de SOAP requests
    ├── ProcesarRespuesta() - Parseo de respuestas
    └── ProcesarErrores() - Manejo de errores SOAP
```

## 📦 Archivos del Proyecto

| Archivo | Descripción |
|---------|-------------|
| `AJEImpositivoAPIClass.clw` | Implementación de la clase (métodos) |
| `AJEImpositivoAPIClass.INC` | Definiciones de tipos, grupos y queues |
| `AJEImpositivoAPIClass.DEF` | Estructura del archivo VTokenSignImpositivo |
| `CLAUDE.md` | Guía técnica para desarrollo con Claude Code |

## 🚀 Uso Básico

### 1. Autenticación

```clarion
ImpositivoAPI   AJEImpositivoApiClass

CODE
    ImpositivoAPI.Construct()
    ImpositivoAPI.Modo = True  ! Production (False = Homologacion)
    ImpositivoAPI.PathCertificado = 'C:\Certificados\'

    ! Obtener Token y Sign
    ImpositivoAPI.LoginTicket('FE', CodigoConfiguracion)

    IF ImpositivoAPI.ErrorG.ErrorSOAP
        Message('Error: ' & ImpositivoAPI.ErrorG.ErrorSOAPMessage)
    END
```

### 2. Consultar Datos de Contribuyente (A5)

```clarion
CUIT            STRING(11)

CODE
    CUIT = '20123456789'
    ImpositivoAPI.ConsultarA5(CUIT)

    ! Acceder a datos
    Message('Razón Social: ' & ImpositivoAPI.A5DatosGeneralesG.razonSocial)
    Message('Domicilio: ' & ImpositivoAPI.A5DomicilioFiscalG.direccion)
```

### 3. Solicitar CAE para Factura

```clarion
CODE
    ! Configurar datos de factura
    ImpositivoAPI.FacturaElectronicaG.FeCAEReqG.FeCabReqG.CantidadRegistros = 1
    ImpositivoAPI.FacturaElectronicaG.FeCAEReqG.FeCabReqG.PuntoVenta = 1
    ImpositivoAPI.FacturaElectronicaG.FeCAEReqG.FeCabReqG.ComprobanteTipo = 6

    ! Configurar detalle del comprobante
    ImpositivoAPI.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.Concepto = 1
    ImpositivoAPI.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.DocumentoTipo = 80
    ImpositivoAPI.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.Documento = '20123456789'
    ! ... más campos ...

    ! Agregar alícuotas de IVA
    CLEAR(ImpositivoAPI.AlicuotasIVAQ)
    ImpositivoAPI.AlicuotasIVAQ.Id = 5  ! IVA 21%
    ImpositivoAPI.AlicuotasIVAQ.BaseImp = 1000.00
    ImpositivoAPI.AlicuotasIVAQ.Importe = 210.00
    ADD(ImpositivoAPI.AlicuotasIVAQ)

    ! Solicitar CAE
    ImpositivoAPI.SolicitarCAE()

    ! Verificar resultado
    IF ImpositivoAPI.FacturaElectronicaResponseG.FECAESolicitarResultG.FeCabRespG.Resultado = 'A'
        Message('CAE: ' & ImpositivoAPI.FacturaElectronicaResponseG.FECAESolicitarResultG.FeDetRespG.FEDetResponseG.CAE)
    ELSE
        Message('Error en solicitud de CAE')
    END
```

## 🔧 Requisitos

### Software Requerido

- **Clarion 6.0 o superior**
- **OpenSSL** (openssl.exe debe estar accesible en el PATH)
- Bibliotecas requeridas:
  - `StringTheory`
  - `xFiles`
  - `jFiles`
  - `OddJob`
  - `UltimateDebug`
  - `AJEBaseApiClass`

### Certificados AFIP

Necesitas obtener certificados digitales de AFIP:

1. Generar clave privada (.key)
2. Crear CSR (.csr)
3. Solicitar certificado en AFIP
4. Descargar certificado (.crt)

Más información: [Guía de certificados AFIP](https://www.afip.gob.ar/ws/)

## ⚙️ Configuración

### Ambientes

La clase soporta dos ambientes:

- **Producción** (`Modo = True`)
  - URLs: wsaa.afip.gov.ar, servicios1.afip.gov.ar, etc.

- **Homologación** (`Modo = False`)
  - URLs: wsaahomo.afip.gov.ar, wswhomo.afip.gov.ar, etc.

### Almacenamiento de Tokens

Los tokens se almacenan en el archivo `VTokenSignImpositivo.TPS` con:
- Token y Sign (credenciales)
- Fecha y hora de expiración
- Configuración de certificados
- CUIT del contribuyente

## 📝 Convenciones de Código

Este proyecto sigue convenciones específicas de Clarion. Ver `CLAUDE.md` para detalles completos:

- Variables globales: `GLO:` prefix
- Variables locales: `LOC:` prefix
- Parámetros: `p` prefix (ejemplo: `pData`, `pCuit`)
- Groups TYPE: sufijo `GT`
- Queues TYPE: sufijo `QT`
- StringTheory variables: prefijo `s` (ejemplo: `sResponse`)

## 🤝 Contribuir

Este proyecto utiliza **Pull Requests** con las siguientes reglas:

- ✅ **2 aprobaciones requeridas** antes de merge
- ✅ **Historial lineal** (solo rebase merge)
- ✅ **No push directo a main** (branch protegida)

Ver `WORKFLOW.md` para el proceso completo de contribución.

### Proceso de Desarrollo

1. Crear rama desde `main`:
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```

2. Realizar cambios siguiendo las convenciones

3. Commit con mensaje descriptivo:
   ```bash
   git commit -m "Descripción del cambio"
   ```

4. Push y crear PR:
   ```bash
   git push -u origin feature/nueva-funcionalidad
   gh pr create
   ```

5. Esperar 2 aprobaciones y hacer merge

## 📚 Documentación

- **CLAUDE.md** - Guía técnica completa para desarrollo
- **WORKFLOW.md** - Proceso de Git y Pull Requests
- **Documentación AFIP** - [Web Services AFIP](https://www.afip.gob.ar/ws/)

## 🐛 Reportar Problemas

Para reportar bugs o solicitar features:

1. Verificar que no exista un issue similar
2. Crear un nuevo issue con:
   - Descripción clara del problema
   - Pasos para reproducir
   - Versión de Clarion
   - Ambiente (Producción/Homologación)

## 📄 Licencia

Copyright © 2025 DeveloperTeam Software Solutions
Todos los derechos reservados.

## 👤 Autor

**Alejandro J. Elías**
Director - DeveloperTeam Software Solutions
- Website: [www.developerteam.com.ar](http://www.developerteam.com.ar)
- Email: aje.elias@gmail.com

## 🙏 Agradecimientos

- AFIP por la documentación de web services
- Comunidad Clarion por las bibliotecas de soporte

---

**Nota**: Esta biblioteca es para uso con servicios AFIP de Argentina. Se requiere estar registrado en AFIP y tener certificados digitales válidos para utilizar los servicios.
