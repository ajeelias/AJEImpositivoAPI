# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Clarion library** for integrating with Argentina's AFIP (Administración Federal de Ingresos Públicos) web services for tax-related operations including electronic invoicing (Factura Electrónica), taxpayer data queries, and authentication.

### Key Components

- **AJEImpositivoApiClass.clw**: Main implementation file containing the API class methods
- **AJEImpositivoApiClass.INC**: Class definition with type declarations (Groups, Queues)
- **AJEImpositivoApiClass.DEF**: File structure definition for VTokenSignImpositivo (token/signature storage)

## Architecture

### Class Hierarchy
- `AJEImpositivoApiClass` extends `AJEBaseApiClass`
- Handles SOAP-based web service communication with AFIP
- Uses StringTheory for string manipulation and xFileXML for XML processing

### Core Functional Areas

1. **Authentication (LoginTicket)**
   - Token and signature generation using OpenSSL
   - Token caching in VTokenSignImpositivo.TPS file
   - Automatic token refresh when expired
   - Supports both Production and Homologation (testing) modes

2. **Web Services Supported**
   - `wsfe`: Electronic invoicing (Factura Electrónica)
   - `wsfecred`: Credit-based electronic invoicing
   - `ws_sr_constancia_inscripcion` (A5): Taxpayer registration data queries
   - `ws_sr_padron_a13` (A13): Tax ID validation
   - `LoginCms`: WSAA authentication service

3. **XML Management**
   - Dynamic SOAP envelope generation via `CrearXML()`
   - Method-specific boundaries configured in `GetBoundariesByMethod()`
   - Response parsing with `ProcesarRespuesta()` and error handling via `ProcesarErrores()`

4. **Key Operations**
   - `ConsultarA5()`: Query taxpayer details (nombre, CUIT, domicilio fiscal, impuestos, etc.)
   - `ConsultarUltimoNumero()`: Get last authorized invoice number
   - `SolicitarCAE()`: Request CAE (Código de Autorización Electrónico) for invoices
   - `ConsultarMontoObligadoRecepcion()`: Check if amount requires electronic credit invoice

### Data Structures

**Important Type Naming Conventions:**
- Groups ending in `GT`: TYPE definitions (e.g., `ErrorGT`, `FacturaElectronicaGT`)
- Groups ending in `G`: Regular group instances
- Queues ending in `QT`: TYPE definitions (e.g., `AlicuotasIvaQT`, `ErrorsQT`)
- Queues ending in `Q`: Regular queue instances

**Key Queue Types:**
- `AlicuotasIvaQT`: VAT rate details (Id, BaseImp, Importe)
- `TributosQT`: Tax/tribute details
- `OpcionalesQT`: Optional invoice fields
- `CompradoresQT`: Buyer information
- `ComprobantesAsociadosQT`: Associated vouchers
- `ErrorsQT`: SOAP error messages

## Clarion-Specific Rules

### File Encoding
- **CRITICAL**: Clarion does NOT support UTF-8 with BOM
- All .clw, .inc, .def files MUST be UTF-8 without BOM

### Syntax Requirements

1. **IF statements**: MUST include `THEN`
   ```clarion
   IF ERRORCODE() THEN
   ```

2. **END statements**: MUST include comment suffix
   ```clarion
   END!IF    ! for IF blocks
   END!C     ! for CASE blocks
   END!L     ! for LOOP blocks
   END!G     ! for GROUP definitions
   END!QT    ! for QUEUE TYPE definitions
   END!M     ! for MAP blocks
   ```

3. **String literals with braces**: Must escape with double braces
   ```clarion
   ! Wrong: Message('{data}')
   ! Correct: Message('{{data}}')
   ```

4. **StringTheory variables**: Must prefix with lowercase 's'
   ```clarion
   sLine StringTheory
   sResponse StringTheory
   ```

### Naming Conventions

**Variables:**
- Global: `GLO:` prefix + CamelCase starting with uppercase (e.g., `GLO:CustomerName`)
- Local: `LOC:` prefix + CamelCase starting with uppercase (e.g., `LOC:Counter`)

**Parameters:**
- Always lowercase 'p' prefix: `pData`, `pCuit`, `pMethod`
- GROUP parameters: `pPatientG`
- QUEUE parameters: `pPatientQ`

**Types:**
- GROUP TYPE: suffix `GT` (e.g., `ErrorGT`)
- GROUP: suffix `G` (e.g., `ErrorG`)
- QUEUE TYPE: suffix `QT` (e.g., `AlicuotasIvaQT`)
- QUEUE: suffix `Q` (e.g., `AlicuotasIvaQ`)

### Code Modification Protocol

**MANDATORY for every code change:**
1. Add dated comment in file header showing modification date/time
2. Update version number in header comments
3. Follow existing code formatting patterns precisely

Example header format:
```clarion
!region Begin Comments
!!>Product         Impositivo API Class
!!>Author          Alejandro J. Elías
!!>Company         DeveloperTeam
!!>Copyright       @2025
!!>Version         001.0
!!>Created         JAN 10,2025
!!>Modified        JAN 10,2025
!endregion End Comments
```

## Common Development Workflows

### OpenSSL Integration
The library uses external OpenSSL executables for certificate signing:
- Creates XML login ticket request
- Signs with `openssl.exe cms -sign` to create .crt file
- Encodes to base64 with `openssl.exe base64`
- Sends signed request to WSAA service

### Token Management Flow
1. Check `VTokenSignImpositivo` table for cached token
2. Validate token expiration (date + time)
3. If expired or missing, generate new LoginTicket
4. Cache new token/sign with expiration time (+12 hours max)

### Environment Modes
- **Production** (`Modo = True`): Uses production AFIP URLs
- **Homologation** (`Modo = False`): Uses testing AFIP URLs

URLs configured in `GetUrl()` method based on `SELF.Modo` property.

## Dependencies

External libraries referenced:
- `StringTheory.INC`: String manipulation
- `xFiles.INC`: XML file handling (xFileXML class)
- `jFiles.INC`: JSON handling
- `OddJob.INC`: Process execution (JobObject for OpenSSL calls)
- `UltimateDebug.INC`: Debugging utilities
- `CWSYNCHM.INC`: Thread synchronization

## Important Implementation Notes

1. **Virtual Methods**: Most methods are marked VIRTUAL for inheritance/override capability
2. **Memory Management**: Constructor allocates reference variables with NEW(), Destructor must DISPOSE() and FREE()
3. **Error Handling**: Check `SELF.ErrorG.ErrorSOAP` flag and `ErrorSOAPMessage` after operations
4. **File Operations**: Uses `LONGPATH()` for current directory, paths stored in VTokenSignImpositivo table
5. **Character Encoding**: Response XML converted from UTF-8 to ISO-8859-1 using `sResponse.ToUnicode()`

---

**Signature**: Alejandro J. Elías -- Director -- DeveloperTeam Software Solutions
