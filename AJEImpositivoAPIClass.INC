!region Begin Comments
!!>Product         Impositivo API Class
!!>Author          Alejandro J. Elías
!!>Company         DeveloperTeam
!!>Copyright       @2025
!!>Version         001.0
!!>Template        
!!>Company URL     www.developerteam.com.ar
!!>Created         JAN 10,2025
!!>Modified        JAN 10,2025
!endregion End Comments
    INCLUDE('cwsynchc.inc'),ONCE
    INCLUDE('ULTIMATESQL.INC'),ONCE
    INCLUDE('AJEBaseApiClass.INC'),ONCE

!region Equates
AJEImpClass:LoginTicketUrlProduccion        EQUATE('wsaa.afip.gov.ar')
AJEImpClass:LoginTicketUrlHomologacion      EQUATE('wsaahomo.afip.gov.ar')
!endregion

!region Groups
ErrorGT             GROUP,TYPE,NAME('ErrorSOAPG')
ErrorSOAP               BYTE
ErrorSOAPMessage        CSTRING(2048)
                    END!G
A5DatosGeneralesGT  GROUP,TYPE,NAME('A5DatosGeneralesGT')
apellido                CSTRING(255),NAME('apellido')  !                     
nombre                  CSTRING(255),NAME('nombre')    !                     
domicilioFiscal         CSTRING(256),NAME('domicilioFiscal') !                     
estadoClave             CSTRING(256),NAME('estadoClave') !                     
fechaContratoSocial     CSTRING(256),NAME('fechaContratoSocial') !                     
idPersona               CSTRING(256),NAME('idPersona') !                     
mesCierre               CSTRING(256),NAME('mesCierre') !                     
razonSocial             CSTRING(256),NAME('razonSocial') !                     
tipoClave               CSTRING(256),NAME('tipoClave') !                     
tipoPersona             CSTRING(256),NAME('tipoPersona') !                     
                    END!G
A5ImpuestosGT       GROUP,TYPE,NAME('A5ImpuestosG')
idPersona               STRING(255),NAME('idPersona')  !                     
descripcionImpuesto     STRING(255),NAME('descripcionImpuesto') !                     
idImpuesto              STRING(255),NAME('idImpuesto') !                     
periodo                 STRING(255),NAME('periodo')    !                     
                    END!G

A5DomicilioFiscalGT GROUP,TYPE,NAME('A5DomicilioFiscalGT')                     
idPersona               CSTRING(256),NAME('idPersona') !                     
codPostal               CSTRING(256),NAME('codPostal') !                     
localidad               CSTRING(256),NAME('localidad') !                     
datoAdicional           CSTRING(256),NAME('datoAdicional') !                     
descripcionProvincia    CSTRING(256),NAME('descripcionProvincia') !                     
direccion               CSTRING(256),NAME('direccion') !                     
idProvincia             CSTRING(256),NAME('idProvincia') !                     
tipoDatoAdicional       CSTRING(256),NAME('tipoDatoAdicional') !                     
tipoDomicilio           CSTRING(256),NAME('tipoDomicilio') !                     
                    END!G

A5ErrorConstanciaGT GROUP,TYPE,NAME('A5ErrorConstanciaGT')
apellido                CSTRING(256)                   !                     
error                   CSTRING(256)                   !                     
idPersona               CSTRING(256)                   !                     
nombre                  CSTRING(256)                   !                     
                    END!G

A5ActividadMonotributistaGT GROUP,TYPE,NAME('A5ActividadMonotributistaGT')
descripcionActividad            CSTRING(256),NAME('descripcionActividad') !                     
idPersona                       STRING(13)                     !                     
idActividad                     CSTRING(256),NAME('idActividad') !                     
nomenclador                     CSTRING(256),NAME('nomenclador') !                     
orden                           CSTRING(256),NAME('orden')     !                     
periodo                         CSTRING(256),NAME('periodo')   !                     
                            END!G

A5CategoriaMonotributoGT    GROUP,TYPE,NAME('A5CategoriaMonotributoGT')
idPersona                       STRING(13)                     !                     
descripcionCategoria            CSTRING(256),NAME('descripcionCategoria') !                     
idCategoria                     CSTRING(256),NAME('idCategoria') !                     
idImpuesto                      CSTRING(256),NAME('idImpuesto') !                     
periodo                         CSTRING(256),NAME('periodo')   !                     
                            END!G

UltimoAutorizadoGT  GROUP,NAME('UltimoAutorizadoGT')
PtoVta                  SHORT,NAME('PtoVta')
CbteTipo                SHORT,NAME('CbteTipo')
CbteNro                 LONG,NAME('CbteNro')
                    END!G

FacturaElectronicaGT        GROUP,TYPE,NAME('FacturaElectronicaGT')
AuthG                           GROUP,NAME('ar:Auth')
Token                               CSTRING(2048),NAME('ar:Token')
Sign                                CSTRING(2048),NAME('ar:Sign')
cuitRepresentada                    CSTRING(21),NAME('ar:Cuit')
                                END!G

FeCAEReqG                       GROUP,NAME('ar:FeCAEReq')
FeCabReqG                           GROUP,NAME('ar:FeCabReq')
CantidadRegistros                       LONG,NAME('ar:CantReg')
PuntoVenta                              LONG,NAME('ar:PtoVta')
ComprobanteTipo                         LONG,NAME('ar:CbteTipo')
                                    END!G
FeDetReqG                           GROUP,NAME('ar:FeDetReq')
FECAEDetRequestG                        GROUP,NAME('ar:FECAEDetRequest')
Concepto                                    LONG,NAME('ar:Concepto | @N02')
DocumentoTipo                               LONG,NAME('ar:DocTipo | @N02')
Documento                                   STRING(13),NAME('ar:DocNro')
ComprobanteDesde                            CSTRING(21),NAME('ar:CbteDesde')
ComprobanteHasta                            CSTRING(21),NAME('ar:CbteHasta')
ComprobanteFecha                            CSTRING(21),NAME('ar:CbteFch')
ImporteTotal                                DECIMAL(18,2),NAME('ar:ImpTotal | @N_016.2')
ImporteTotalConcepto                        DECIMAL(18,2),NAME('ar:ImpTotConc | @N_016.2')
ImporteNeto                                 DECIMAL(18,2),NAME('ar:ImpNeto | @N_016.2')
ImporteOperacionExenta                      DECIMAL(18,2),NAME('ar:ImpOpEx | @N_016.2')
ImporteTributos                             DECIMAL(18,2),NAME('ar:ImpTrib | @N_016.2')
ImporteIVA                                  DECIMAL(18,2),NAME('ar:ImpIVA | @N_016.2')
FechaServicioDesde                          CSTRING(21),NAME('ar:FchServDesde | @D012')
FechaServicioHasta                          CSTRING(21),NAME('ar:FchServHasta | @D012')
FechaVencimientoPago                        CSTRING(21),NAME('ar:FchVtoPago | @D012')
MonedaId                                    CSTRING(11),NAME('ar:MonId')
MonedaCotiza                                CSTRING(21),NAME('ar:MonCotiz')
CondicionIVAReceptorId                      LONG,NAME('ar:CondicionIVAReceptorId')
AlicuotasIvaQ                               CSTRING(2),NAME('AlicuotasIvaQ')
ComprobantesAsociadosQ                      CSTRING(2),NAME('ComprobantesAsociadosQ')
TributosQ                                   CSTRING(2),NAME('TributosQ')
CompradoresQ                                CSTRING(2),NAME('CompradoresQ')
OpcionalesQ                                 CSTRING(2),NAME('OpcionalesQ')
                                        END!G
                                    END!G
                                END!G
                            END!G

AlicuotasIvaQT      QUEUE,TYPE,NAME('ar:Iva')
Id                      LONG,NAME('ar:Id')    ! Por ejemplo: "05"
BaseImp                 DECIMAL(18,2),NAME('ar:BaseImp')
Importe                 DECIMAL(18,2),NAME('ar:Importe')
                    END!QT

OpcionalesQT        QUEUE,TYPE,NAME('ar:Opcional')
Id                      LONG,NAME('ar:Id')    ! Por ejemplo: "05"
Valor                   DECIMAL(18,2),NAME('ar:Valor')
                    END!QT

CompradoresQT       QUEUE,TYPE,NAME('CompradoresQT')
DocumentoTipo           LONG
DocumentoNumero         CSTRING(255)
Porcentaje              DECIMAL(13,2)
                    END!QT
TributosQT          QUEUE,TYPE,NAME('TributosQT')
Id                      CSTRING(256)
Descripcion             CSTRING(256)
BaseImponible           DECIMAL(13,2)
Alicuota                DECIMAL(7,2)
Importe                 DECIMAL(13,2)
                    END!QT
ComprobantesAsociadosQT     QUEUE,TYPE,NAME('ar:CbtesAsoc')
Tipo                            SHORT
PtoVta                          LONG
Nro                             LONG
                            END!QT
ErrorsQT            QUEUE,TYPE,NAME('ErrorsQT')        ! 
Codigo                  CSTRING(31),NAME('Code')               ! 
Descripcion             CSTRING(2048),NAME('Msg')               ! 
                    END!QT  


FacturaElectronicaResponseGT        GROUP,TYPE,NAME('FECAESolicitarResponse')
FECAESolicitarResultG                   GROUP,NAME('FECAESolicitarResult')
FeCabRespG                                  GROUP,NAME('FeCabResp')
Cuit                                            LONG,NAME('Cuit')
PtoVta                                          LONG,NAME('PtoVta')
CbteTipo                                        LONG,NAME('CbteTipo')
FchProceso                                      STRING(14),NAME('FchProceso')
CantReg                                         LONG,NAME('CantReg')
Resultado                                       STRING(1),NAME('Resultado')
                                            END
FeDetRespG                                  GROUP,NAME('FeDetResp')
FEDetResponseG                                  GROUP,NAME('FECAEDetResponse')
Concepto                                            SHORT,NAME('Concepto')
DocTipo                                             SHORT,NAME('DocTipo')
DocNro                                              LONG,NAME('DocNro')
CbteDesde                                           LONG,NAME('CbteDesde')
CbteHasta                                           LONG,NAME('CbteHasta')
FDRResultado                                        STRING(1),NAME('Resultado')
CAE                                                 STRING(14),NAME('CAE')
CbteFch                                             STRING(8),NAME('CbteFch')
CAEFchVto                                           STRING(8),NAME('CAEFchVto')
OBS                                                 GROUP,NAME('Obs')
ObservacionesG                                          GROUP,NAME('Observaciones')
Code                                                        SHORT,NAME('Code')
Msg                                                         STRING(255),NAME('Msg')
                                                        END
                                                    END
                                                END
                                            END
EventsG                                     GROUP,NAME('Events')
EvtG                                            GROUP,NAME('Evt')
EveCode                                             SHORT,NAME('Code')
EveMsg                                              STRING(255),NAME('Msg')
                                                END
                                            END
                                        END
                                    END!GT

ConsultarMontoObligadoGT    GROUP,TYPE,NAME('ConsultarMontoObligadoGT')
obligado                        STRING(1),NAME('obligado')  !                     
montoDesde                      CSTRING(256),NAME('montoDesde') !                     
                            END!GT

!endRegion

AJEImpositivoApiClass       CLASS(AJEBaseApiClass),TYPE,MODULE('AJEImpositivoAPIClass.CLW'),LINK('AJEImpositivoAPIClass.CLW',_ABCLinkMode_),DLL(_ABCDllMode_)
!----------
!Properties
!----------
sBasicAuth                      &stringTheory
sPost                           &stringTheory
ErrorG                          GROUP(ErrorGT)
                                END!G
A5DatosGeneralesG               GROUP(A5DatosGeneralesGT)
                                END!G
A5ImpuestosG                    GROUP(A5ImpuestosGT)
                                END!G
A5DomicilioFiscalG              GROUP(A5DomicilioFiscalGT)
                                END!G
A5ErrorConstanciaG              GROUP(A5ErrorConstanciaGT)
                                END!G
A5ActividadMonotributistaG      GROUP(A5ActividadMonotributistaGT)
                                END!G
A5CategoriaMonotributoG         GROUP(A5CategoriaMonotributoGT)
                                END!G
UltimoAutorizadoG               GROUP(UltimoAutorizadoGT)
                                END!G
FacturaElectronicaG             GROUP(FacturaElectronicaGT)
                                END!G
FacturaElectronicaResponseG     GROUP(FacturaElectronicaResponseGT)
                                END!G
ConsultarMontoObligadoG         GROUP(ConsultarMontoObligadoGT)
                                END!G

AlicuotasIVAQ                   &AlicuotasIvaQT
TributosQ                       &TributosQT
OpcionalesQ                     &OpcionalesQT
CompradoresQ                    &CompradoresQT
ComprobantesAsociadosQ          &ComprobantesAsociadosQT
ErrorsQ                         &ErrorsQT
Token                           CSTRING(2048)
Sign                            CSTRING(2048)
CUIT                            CSTRING(21)
Modo                            BYTE
CodigoConfiguracion             LONG
RecordBoundary                  PSTRING(252) !segun xfiles
RecordBoundaryAttribute         CSTRING(4096)
SOAPEnvelopeBoundaryAttribute   CSTRING(4096)
SOAPAction                      CSTRING(1024)
FileBoundary                    CSTRING(4096)
SOAPEnvelopeBoundary            CSTRING(4096)
SOAPHeader                      CSTRING(4096)
PathCertificado                 CSTRING(1024)
WebServices                     CSTRING(256)
OmitXMLHeader                   LONG(0)
!----------
!Methods
!----------
Construct                       PROCEDURE()
Destruct                        PROCEDURE()
LoginTicket                     PROCEDURE(STRING pWebServices,STRING pCodigoConfiguracion),PROC,VIRTUAL
CreateXMLA5                     PROCEDURE(STRING pCuit),STRING,PROC,VIRTUAL
CreateXMLConsultarUltimoNumero  PROCEDURE(LONG pPuntoVenta,LONG pComprobanteTipo),STRING,PROC,VIRTUAL
ConsultarA5                     PROCEDURE(STRING pCuit),STRING,PROC,VIRTUAL
ConsultarUltimoNumero           PROCEDURE(LONG pPuntoVenta,LONG pComprobanteTipo),STRING,PROC,VIRTUAL
SolicitarCAE                    PROCEDURE(),PROC,VIRTUAL
CreateXMLFacturaElectronica     PROCEDURE(),STRING,PROC,VIRTUAL
CrearXML                        PROCEDURE(*GROUP pGroup,STRING pMethod),STRING,PROC,VIRTUAL
GetBoundariesByMethod           PROCEDURE(STRING pMethod),VIRTUAL
GetUrl                          PROCEDURE(),STRING,VIRTUAL
ProcesarRespuesta               PROCEDURE(STRING pRespuesta,STRING pMethod),STRING,PROC,VIRTUAL
ProcesarRequest                 PROCEDURE(STRING pRequest,STRING pMethod),STRING,PROC,VIRTUAL
ProcessRequest                  PROCEDURE(*StringTheory pRequest,STRING pMethod),PROC,VIRTUAL
ProcesarErrores                 PROCEDURE(*StringTheory pObject),VIRTUAL
GetTableState                   PROCEDURE (*FILE pTable),STRING,PROC,VIRTUAL
CloseTable                      PROCEDURE (*FILE pTable),STRING,PROC,VIRTUAL
ErrorTrap                       PROCEDURE(STRING methodName, STRING errorMessage)
TestLoadXML                     PROCEDURE() !VIRTUAL
CreateXMLMontoObligadoRecepcion PROCEDURE(STRING pCuit,LONG pFecha),STRING,PROC,VIRTUAL
ConsultarMontoObligadoRecepcion PROCEDURE(STRING pCuit,LONG pFecha),LONG,PROC,VIRTUAL
                            END!CLASS
