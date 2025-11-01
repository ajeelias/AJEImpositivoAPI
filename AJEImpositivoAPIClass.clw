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

                    MEMBER()

    omit('***',_c55_)
_ABCDllMode_        EQUATE(0)
_ABCLinkMode_       EQUATE(1)
    ***

    INCLUDE('AJEBaseApiClass.INC'),ONCE
    INCLUDE('AJEImpositivoApiClass.INC'),ONCE
    INCLUDE('AJEImpositivoApiClass.DEF'),ONCE
    INCLUDE('CWSYNCHM.INC'),ONCE
    INCLUDE('jFiles.INC'),ONCE
    INCLUDE('EQUATES.CLW'),ONCE
    INCLUDE('ERRORS.CLW'),ONCE
    INCLUDE('KEYCODES.CLW'),ONCE
    INCLUDE('StringTheory.INC'),ONCE
    INCLUDE('OddJob.INC'),ONCE
    INCLUDE('xFiles.INC'),ONCE
    INCLUDE('UltimateDebug.INC'),ONCE
                    MAP
                    END!MAP
UD                  UltimateDebug
!-----------------------------------------------------------------
AJEImpositivoApiClass.Construct    PROCEDURE()
!-----------------------------------------------------------------
    CODE
        SELF.sPost          &= NEW(StringTheory)
        SELF.sBasicAuth     &= NEW(StringTheory)
        SELF.ErrorsQ        &= NEW ErrorsQT
        SELF.Modo            = True !por defecto la inicializo en production
        SELF.AlicuotasIVAQ  &= NEW(AlicuotasIVAQT)
        SELF.CompradoresQ   &= NEW(CompradoresQT)
        SELF.OpcionalesQ    &= NEW(OpcionalesQT)
        SELF.TributosQ      &= NEW(TributosQT)
        SELF.ComprobantesAsociadosQ &= NEW(ComprobantesAsociadosQT)
        RETURN
!-----------------------------------------------------------------
AJEImpositivoApiClass.Destruct     PROCEDURE()
!-----------------------------------------------------------------
    CODE
        DISPOSE(SELF.sPost)
        DISPOSE(SELF.sBasicAuth)
        FREE(SELF.ErrorsQ)
        DISPOSE(SELF.ErrorsQ)
        FREE(SELF.AlicuotasIVAQ)
        DISPOSE(SELF.AlicuotasIVAQ)
        
        FREE(SELF.CompradoresQ)
        DISPOSE(SELF.CompradoresQ)
        FREE(SELF.OpcionalesQ)
        DISPOSE(SELF.OpcionalesQ)
        FREE(SELF.TributosQ)
        DISPOSE(SELF.TributosQ)
        FREE(SELF.ComprobantesAsociadosQ)
        DISPOSE(SELF.ComprobantesAsociadosQ)
        
        RETURN
!Region Impositivo API
!---------------------------------------------------------
AJEImpositivoApiClass.ProcesarRespuesta        PROCEDURE(STRING pRespuesta,STRING pMethod) !VIRTUAL
!---------------------------------------------------------
Method                                              EQUATE('ProcesarRespuesta')
json                                                jsonClass
sResponse                                           StringTheory
xXML                                                CLASS(xFileXML)
                                                    END!C
    CODE
        sResponse.Start()
        sResponse.SetValue(pRespuesta,st:Clip)
        
        SELF.AnswerRequest(sResponse,pMethod)
        sResponse.SaveFile('Response-'&pMethod&'.xml')
        
        CASE pMethod
        OF 'LoginTicket'
!            sResponse.SaveFile('Response-LoginTicket.xml')
        OF 'ConsultarUltimoNumero'
!            sResponse.SaveFile('Response-ConsultarUltimoNumero.xml')
        OF 'ConsultarA5'
!            sResponse.SaveFile('A5Response.xml')
        OF 'ConsultarMontoObligadoRecepcion'
            CLEAR(SELF.ConsultarMontoObligadoG)
            xXML.Start()
            IF sResponse.Instring('HTTP/1.1 200 OK') THEN
                xXML.Load(SELF.ConsultarMontoObligadoG,sResponse.GetValuePtr(),sResponse.Len(),'','consultarMontoObligadoRecepcionReturn') 
            ELSE
                IF sResponse.Instring('<faultstring>') THEN
                    SELF.Trace('Error consultando ConsultarMontoObligadoRecepcion='&sResponse.Between('<faultstring>','</faultstring>'))
                END!IF
            END!IF
        END!C
        RETURN sResponse.GetValue()
!---------------------------------------------------------
AJEImpositivoApiClass.ProcesarRequest        PROCEDURE(STRING pRequest,STRING pMethod) !VIRTUAL
!---------------------------------------------------------
Method                                              EQUATE('ProcesarRequest')
json                                                jsonClass
sRequest                                            StringTheory
    CODE
        sRequest.Start()
        sRequest.SetValue(pRequest,st:Clip)
        
        SELF.ProcessRequest(sRequest,pMethod)
        sRequest.SaveFile('Request-'&pMethod&'.xml')
        CASE pMethod
        OF 'LoginTicket'
            sRequest.SaveFile('LoginTicket.txt')
        OF 'ConsultarA5'
        END!C
        RETURN sRequest.GetValue()
        

!---------------------------------------------------------
AJEImpositivoApiClass.ProcesarErrores        PROCEDURE(*StringTheory pObject) !VIRTUAL
!---------------------------------------------------------
Method                                              EQUATE('ProcesarErrores')
sResponse                                           StringTheory
xXml                                                xFileXML
    CODE
        sResponse.Start()
        sResponse.SetValue(pObject,st:Clip)
        FREE(SELF.ErrorsQ)
        xXml.Load(SELF.ErrorsQ, sResponse.GetValuePtr(),sResponse.Len(),'Err','SoapFault')
        LOOP II# = 1 to RECORDS(SELF.ErrorsQ)
            GET(SELF.ErrorsQ, II#)
            SELF.ErrorG.ErrorSOAPMessage = CLIP(SELF.ErrorG.ErrorSOAPMessage) & 'Codigo: '&SELF.ErrorsQ.Codigo  & '|' & |
                'Motivo: '&SELF.ErrorsQ.Descripcion    & '|' & |
                ALL('-', 78) & '|'
            SELF.ErrorG.ErrorSOAP = 1
        END!L
!        xXml.Load(SELF.ErrorsQ, sResponse.GetValuePtr(),sResponse.Len(),'Err','SoapFault')
        RETURN
!---------------------------------------------------------
AJEImpositivoApiClass.LoginTicket        PROCEDURE(STRING pWebServices,STRING pCodigoConfiguracion) !VIRTUAL
!---------------------------------------------------------
Method                                      EQUATE('LoginTicket')
FileName                                    CSTRING(1024)
FechaInicial                                CSTRING(255)
FechaFinal                                  CSTRING(255)
sBase64                                     StringTheory
sDate                                       StringTheory
sPostString                                 StringTheory
sProcData                                   StringTheory
sExecute                                    StringTheory
sResponse                                   StringTheory
sLog                                        StringTheory
sOldPath                                    StringTheory
sUrl                                        StringTheory
sLogin                                          StringTheory
PathOfFileToRun                             CSTRING(252)

HeaderG                                     GROUP,PRE(),NAME('header')            ! 
source                                          STRING(250),NAME('source')            ! 
destination                                     STRING(250),NAME('destination')       ! 
                                            END                                   ! 
credentialsG                                GROUP,PRE(),NAME('credentials')       ! 
token                                           CSTRING(2048),NAME('token')           ! 
sign                                            CSTRING(2048),NAME('sign')            ! 
                                            END                                   ! 
SoapEnvFaultG                               GROUP,PRE()                           ! 
faultcode                                       CSTRING(2048),NAME('faultcode')       ! 
faultstring                                     CSTRING(2048),NAME('faultstring')     ! 
detail                                          &QUEUE,NAME('detail')                 ! 
                                            END                                   ! 
SoapFaultG                                  GROUP,PRE(),NAME('SoapFault')         ! 
codigo                                          STRING(30),NAME('codigo')             ! 
Descripcion                                     STRING(255),NAME('Descripción')       ! 
                                            END  
loginTicketRequestG                         GROUP,PRE(),NAME('loginTicketRequest') ! 
headerG                                         GROUP,PRE(),NAME('header')            ! 
uniqueId                                            CSTRING(2048),NAME('uniqueId')        ! 
generationTime                                      CSTRING(256),NAME('generationTime')    ! 
expirationTime                                      CSTRING(256),NAME('expirationTime')    ! 
                                                END                                   ! 
service                                         CSTRING(1024),NAME('service')         ! 
                                            END                                   ! 
wsaa:loginCmsG                              GROUP,PRE(),NAME('wsaa:loginCms')     ! 
wsaa:in0                                        CSTRING(65535),NAME('wsaa:in0')       ! 
                                            END                                   ! 


xResponse                                   xFileXML
wsXML                                       CLASS(xFileXML)
!SaveTweakSettings                               PROCEDURE () ,VIRTUAL
                                            END!C
xLogin                                      CLASS(xFileXML)
SaveTweakSettings                               PROCEDURE () ,VIRTUAL
                                            END!C
Job                                         CLASS(JobObject)
                                            END!C
Host                                        CSTRING(1024)
                    MAP
ProcessResponse         PROCEDURE()
                    END!M


    CODE
        VTokenSignImpositivo{PROP:Name} = LONGPATH()&'\VTokenSignImpositivo.TPS'
        
        SELF.CodigoConfiguracion = pCodigoConfiguracion
        SELF.GetTableState(VTokenSignImpositivo)

        VTI:Codigo_Configuracion = SELF.CodigoConfiguracion
        VTI:WebServices = CLIP(pWebServices)
        GET(VTokenSignImpositivo,VTI:ConfKey) 
        IF ERRORCODE() THEN 
            SELF.Trace('Error VtokenSign='&ERROR()&' '&ERRORCODE()&' '&FILEERROR())
            CLEAR(VTokenSignImpositivo)
            VTI:Codigo_Configuracion = SELF.CodigoConfiguracion
            VTI:WebServices = pWebServices
            VTI:MODO = 1 !Produccion por defecto
            VTI:PathCE = CHOOSE(SELF.PathCertificado='',LONGPATH()&'\',SELF.PathCertificado)
            ADD(VTokenSignImpositivo)
        ELSE
            SELF.Trace('WS='&VTI:WebServices&' - FECHA='&VTI:FECHA_A&' -- HORA:'&VTI:HORA_EX&' -- TODAY='&TODAY()&' -- CLOCK='&CLOCK())
            
            IF VTI:FECHA_A = TODAY() THEN
                IF VTI:HORA_EX > = CLOCK() THEN
                    SELF.Token   = CLIP(VTI:TOKEN)
                    SELF.Sign    = CLIP(VTI:SIGN)
                    SELF.CUIT    = CLIP(VTI:CUIT)
                    SELF.Modo    = CLIP(VTI:Modo)
                    Result# = 0
                     SELF.Trace('STAGE 1')
                ELSE
                    Result# = 1
                    SELF.Trace('STAGE 2')
                END
            ELSIF VTI:FECHA_A > TODAY() THEN   
!                IF VTI:HORA_EX < = CLOCK() THEN
                    SELF.Token   = CLIP(VTI:TOKEN)
                    SELF.Sign    = CLIP(VTI:SIGN)
                    SELF.CUIT    = CLIP(VTI:CUIT)
                    SELF.Modo    = CLIP(VTI:Modo)
                    Result# = 0
                    SELF.Trace('STAGE 3')
!                ELSE
!                    Result# = 1
!                    SELF.Trace('STAGE 4')
!                END!IF
            ELSE
                Result# = 1 !cambió de fecha necesitamos pedir el token
                SELF.Trace('STAGE 5')
            END!IF
        END!IF
        SELF.CUIT    = CLIP(VTI:CUIT)
        SELF.Trace('CUIT='&SELF.CUIT)
        
        IF Result# = 1 THEN
    		
            SELF.Trace('Excute pathCE:'&VTI:PathCE)
            
            FileName = CLIP(VTI:PATHCE)&'TicketR.crt'     !Todos estos caminos, deberian guardarse en el ini y ser parametrizables
            REMOVE(FileName)
        
            FileName = CLIP(VTI:PATHCE)&'TicketR.b64'
            REMOVE(FileName)
        
            FechaInicial = YEAR(TODAY())&'-'&FORMAT(MONTH(TODAY()),@N02)&'-'&FORMAT(DAY(TODAY()),@N02)&'T'&FORMAT(CLOCK(),@T04)&'-03:00'
            FechaFinal = YEAR(TODAY())&'-'&FORMAT(MONTH(TODAY()),@N02)&'-'&FORMAT(DAY(TODAY()),@N02)&'T'& |
                FORMAT(CHOOSE(CLOCK()+4320000 > 8640000, 8640000, CLOCK()+4320000),@T04)&'-03:00'
        
    
            loginTicketRequestG.headerG.uniqueId       = TODAY()&SUB(Format(Clock(),@n07),5,2)
            loginTicketRequestG.headerG.generationTime = CLIP(FechaInicial)
            loginTicketRequestG.headerG.expirationTime = CLIP(FechaFinal)
        
            IF CLIP(pWebServices)       = 'A5' THEN
                loginTicketRequestG.service = 'ws_sr_constancia_inscripcion'
            ELSIF CLIP(pWebServices)    = 'A13' THEN
                loginTicketRequestG.service = 'ws_sr_padron_a13'
            ELSIF CLIP(pWebServices)    = 'FCRED' THEN
                loginTicketRequestG.service = 'wsfecred'
            ELSIF CLIP(pWebServices)    = 'FE' THEN
                loginTicketRequestG.service = 'wsfe'    
            ELSIF CLIP(pWebServices)    = 'CPE' THEN
                loginTicketRequestG.service = 'wscpe'    
            ELSIF CLIP(pWebServices)    = 'LPG' THEN
                loginTicketRequestG.service = 'wslpg'    
            END!IF
            SELF.WebServices = 'LoginTicket'
            
            xLogin.start()
            
            sLogin.SetValue(SELF.CrearXML(loginTicketRequestG,Method))
            ud.Debug('waas='&CLIP(VTI:PATHCE)&'TicketR1.XML')
            xLogin.Save(loginTicketRequestG,CLIP(VTI:PATHCE)&'TicketR.XML')
!            sLogin.SaveFile(CLIP(VTI:PATHCE)&'TicketR1.XML')
!            sLogin.SaveFile(loginTicketRequestG,CLIP(VTI:PATHCE)&'TicketR.XML')
!            ud.DebugGroup(loginTicketRequestG,'login')
    		
            sExecute.SetValue('openssl.exe cms -sign -in "'&CLIP(VTI:PATHCE)&'TicketR.xml" -signer "'&CLIP(VTI:PATHCE)&CLIP(VTI:NOMBRE_CRT)&'" -inkey "'&CLIP(VTI:PATHCE)&CLIP(VTI:NOMBRE_KEY)&'" -nodetach -out "'&CLIP(VTI:PATHCE)&'TicketR.crt" -outform der',st:clip)
            SELF.Trace('Excute openSSL 1:'&'openssl.exe cms -sign -in "'&CLIP(VTI:PATHCE)&'TicketR.xml" -signer "'&CLIP(VTI:PATHCE)&CLIP(VTI:NOMBRE_CRT)&'" -inkey "'&CLIP(VTI:PATHCE)&CLIP(VTI:NOMBRE_KEY)&'" -nodetach -out "'&CLIP(VTI:PATHCE)&'TicketR.crt" -outform der')
            PathOfFileToRun = LONGPATH()
            Job.CreateProcess(sExecute.GetValue(), jo:SW_HIDE, false, PathOfFileToRun, , , , sProcData, 0, 1)
        
            SELF.Trace('sProcData 2:'&sProcData.GetValue())
        
            LOOP UNTIL sProcData.Len() <> 0 OR EXISTS(CLIP(VTI:PATHCE)&'TicketR.crt')
                YIELD()
            END
        
            SELF.Trace(sProcData.GetVal()) !directo al log...nunca aparecerá
        				
            sExecute.SetValue('openssl.exe base64 -in "'&CLIP(VTI:PATHCE)&'TicketR.crt" -out "'&CLIP(VTI:PATHCE)&'TicketR.b64" -e',1)	
        
            PathOfFileToRun = LONGPATH()
            Job.CreateProcess(sExecute.GetValue(), jo:SW_HIDE, false, PathOfFileToRun, , , , sProcData, 0, 1)
        
        
            SELF.Trace(sProcData.GetValue()) !directo al log...
        				
!        SETPATH(sOldPath.GetValue())
        				
            sBase64.LoadFile(VTI:PATHCE&'TicketR.b64')
        
            wsaa:loginCmsG.wsaa:in0 = sBase64.GetVal()
            sPostString.SetValue(SELF.CrearXML(wsaa:loginCmsG,'WSAA-CMS'))
  
  !    		
            IF ~ErrorCode() THEN
                sPostString.SaveFile('LoginRequest.xml')
            ELSE
                MESSAGE('ERROR, en lectura TicketR.b64 ' & Error())
                SELF.ErrorG.ErrorSOAP = 1
            END
    
!            IF CLIP(VTI:Modo) = 0 !Testing
!                sUrl.SetValue('https://wsaahomo.afip.gov.ar/ws/services/LoginCms')
!            ELSE !Production
!                sUrl.SetValue('https://wsaa.afip.gov.ar/ws/services/LoginCms')
!            END
    		
            sLog.Append(sPostString)
            sLog.SaveFile('TokenRequest.log')
    	   
            sResponse.SetValue(SELF.SendRequest(SELF.GetUrl(),sPostString.GetVal(),'POST','SOAPAction: ""'))
        				
            ProcessResponse()
        

            SELF.ProcesarRespuesta(sResponse.GetValue(),Method)   
        END!IF
        RETURN 

ProcessResponse     PROCEDURE()
ST                      StringTheory
    CODE
        sResponse.XMLDecode()
        xResponse.Start()
  		
        wsXml.Load(HeaderG, sResponse.GetValuePtr(),sResponse.Len(),'','header') 
        wsXml.Load(CredentialsG, sResponse.GetValuePtr(),sResponse.Len(),'','credentials') 
		
        sResponse.SaveFile('.\LoginTicketPageReceived.TxT')
  
        IF credentialsG.token = '' THEN
            IF sResponse.Between('<faultcode xmlns:ns1="http://sXml.apache.org/axis/">','</faultcode>') THEN
                SoapEnvFaultG.faultcode	=sResponse.Between('<faultcode xmlns:ns1="http://sXml.apache.org/axis/">','</faultcode>')
                SoapEnvFaultG.faultstring 	=sResponse.Between('<faultstring>','</faultstring>')
  			
                ST.SerializeGroup(SoapEnvFaultG,'|')
                SELF.Trace('Token Vacio='&ST.GetVal())
            END!IF
            SELF.ProcesarErrores(sResponse)
        ELSIF credentialsG.token <> ''
            IF SELF.ErrorG.ErrorSOAP = 1 THEN
                SELF.Trace('Error obteniendo Token ='&SELF.ErrorG.ErrorSOAPMessage)
            ELSE                     ! SI NO ES ERROR ASIGNA EL TOKEN Y SIGN
                SELF.Token 	= CLIP(CredentialsG.token)
                SELF.Sign 	= CLIP(CredentialsG.sign)
                
                IF SELF.Token<>'' AND SELF.Sign <>'' THEN
                    St.SetValue(loginTicketRequestG.headerG.expirationTime)
                    St.SetValue(st.Between('T','.')) !<expirationTime>2018-12-17T19:06:22.945-03:00
    
                    sdate.SetValue(loginTicketRequestG.headerG.expirationTime)
                    sdate.Split('T')
                    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    CLEAR(VTokenSignImpositivo)
                    VTI:Codigo_Configuracion = SELF.CodigoConfiguracion
                    VTI:WebServices = CLIP(pWebServices)
                    GET(VTokenSignImpositivo,VTI:ConfKey) 
                    IF ERRORCODE() THEN 
                        VTI:Codigo_Configuracion = SELF.CodigoConfiguracion
                        VTI:TOKEN = CLIP(SELF.Token)
                        VTI:SIGN  = CLIP(SELF.Sign)
                        VTI:FECHA_A = DEFORMAT(sDate.GetLine(1),@D10-)
                        VTI:STATION  = 'WSID'
                        VTI:HORA_EX  = CHOOSE(CLOCK()+4320000 > 8640000, 8640000, CLOCK()+4320000)
                        ADD(VTokenSignImpositivo)
                        IF ERRORCODE() THEN SELF.Trace('Error ADD ProcessResponse='&ERROR()).
                    ELSE
                        VTI:Codigo_Configuracion = SELF.CodigoConfiguracion
                        VTI:TOKEN = CLIP(SELF.Token)
                        VTI:SIGN  = CLIP(SELF.Sign)
                        VTI:FECHA_A = DEFORMAT(sDate.GetLine(1),@D10-)
                        VTI:HORA_EX  = CHOOSE(CLOCK()+4320000 > 8640000, 8640000, CLOCK()+4320000)
                        PUT(VTokenSignImpositivo)
                        IF ERRORCODE() THEN SELF.Trace('Error PUT ProcessResponse='&ERROR()).
                    END
                    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    IF ERROR() THEN
                        SELF.Trace('Error al actualizar TOKEN y SIGN  en VTokenSignImpositivo, '&ERROR())
                    ELSE
                        SELF.ErrorG.ErrorSOAP = 0
                    END
                ELSE
                    SELF.Trace('Atención !!! No se obtuvo el Token y Sign desde el Servidor.|Realice el envio nuevamente en unos minutos.|Ejecute en forma Manual la Sincronización de Hora|con el servidor de la AFIP en:|Ajustar Fecha y Hora, Hora de Internet, Actualizar Ahora.')
                    SELF.ErrorG.ErrorSOAP = 1
                END
            END
        ELSE         ! POR SI NO SE COMUNICA
            SELF.Trace('Atención !!!  No se obtuvo respuesta del Servidor')
            SELF.ErrorG.ErrorSOAP = 1
        END!IF     
!-------------------------------------------        
xLogin.SaveTweakSettings    PROCEDURE ()
    CODE
        PARENT.SaveTweakSettings ()
        SELF.SOAPEnvelope 				= 1
        SELF.SaveEncoding 				= 'UTF-8' !Ver segun la doc mejor ISO-8859-1
        SELF._pFileBoundary 			= ''
        SELF._pRecordBoundary 			= ''
        SELF.RecordBoundaryAttribute 	= ''
        SELF.TagCase 					= XF:CaseAsIs
        SELF.SOAPEnvelopeBoundary 		= 'loginTicketRequest'
        SELF.SOAPEnvelopeBoundaryAttribute = 'version="1.0"'
        SELF.SOAPBodyBoundary 			= ''
        SELF.SOAPHeader 				= ''
!---------------------------------------------------------
AJEImpositivoApiClass.CrearXML      PROCEDURE(*GROUP pGroup,STRING pMethod) !VIRTUAL
!---------------------------------------------------------
xXml                                    CLASS(xFileXML)
                                        END!C
Method                                  EQUATE('CrearXML')
    CODE
        SELF.GetBoundariesByMethod(pMethod)
        xXml.SaveTweakSettings()
        
        xXml.SOAPEnvelope 				    = true
        xXml.SaveEncoding 				    = 'UTF-8' !Ver segun la doc mejor ISO-8859-1
        xXml._pFileBoundary 			    = SELF.FileBoundary
        xXml._pRecordBoundary 			    = SELF.RecordBoundary
        xXml.RecordBoundaryAttribute 	    = SELF.RecordBoundaryAttribute
        xXml.TagCase 					    = XF:CaseAsIs
        xXml.SOAPEnvelopeBoundary 		    = SELF.SOAPEnvelopeBoundary
        xXml.SOAPEnvelopeBoundaryAttribute  = SELF.SOAPEnvelopeBoundaryAttribute
        xXml.SOAPBodyBoundary 			    = ''
        xXml.SOAPHeader 				    = SELF.SOAPHeader
        xXml.saveToString                   = true  
        xXml.OmitXMLHeader                  = SELF.OmitXMLHeader
        xXml.SetDontReplaceColons(true)
        
!        xXml.DontSaveBlanks = TRUE 
        xXml.Save(pGroup)
        SELF.ProcesarRequest(xXml.xmlData,pMethod)
        RETURN xXml.xmlData
!---------------------------------------------------------
AJEImpositivoApiClass.GetBoundariesByMethod      PROCEDURE(STRING pMethod) !VIRTUAL
!---------------------------------------------------------
Method                                                  EQUATE('GetBoundariesByMethod')
sXml                                                    StringTheory       
                                                        
    CODE
        self.Trace('pMethod='&pMethod)
        SELF.FileBoundary           = 'soapenv:Body'
        SELF.SOAPEnvelopeBoundary   = 'soapenv:Envelope'
        SELF.SOAPHeader             = '<soapenv:Header/>'
        SELF.RecordBoundaryAttribute= ''
        CASE lower(pMethod)
        OF 'loginticket'
            SELF.FileBoundary                  = ''
            SELF.SOAPEnvelopeBoundary          = 'loginTicketRequest'
            SELF.SOAPEnvelopeBoundaryAttribute = 'version="1.0"'
            SELF.SOAPHeader                    = ''
            SELF.RecordBoundary                = ''
            SELF.SOAPAction                    = '""'
        OF 'wsaa-cms'
            SELF.RecordBoundary 			   = 'wsaa:loginCms'
            SELF.SOAPEnvelopeBoundary 		   = 'soapenv:Envelope'
            SELF.SOAPEnvelopeBoundaryAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsaa="http://wsaa.view.sua.dvadac.desein.afip.gov"'
            SELF.SOAPHeader 				   = '<soapenv:Header/>'
        OF 'createxmla5'
            SELF.RecordBoundary                = 'a5:getPersona'
            SELF.SOAPEnvelopeBoundaryAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:a5="http://a5.soap.ws.server.puc.sr/"'
            SELF.SOAPAction                    = '""'
        OF 'createxmlconsultarultimonumero'
            SELF.RecordBoundary                = 'ar:FECompUltimoAutorizado'
            SELF.SOAPEnvelopeBoundaryAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ar="http://ar.gov.afip.dif.FEV1/"'
            SELF.SOAPAction                    = '"http://ar.gov.afip.dif.FEV1/FECompUltimoAutorizado"'
        OF 'createxmlfacturaelectronica'
            SELF.RecordBoundary                = 'ar:FECAESolicitar'
            SELF.SOAPEnvelopeBoundaryAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ar="http://ar.gov.afip.dif.FEV1/"'
            SELF.SOAPAction                    = '"http://ar.gov.afip.dif.FEV1/FECAESolicitar"'
        OF 'createxmlmontoobligadorecepcion'
            SELF.RecordBoundary                = 'fec:consultarMontoObligadoRecepcionRequest'
            SELF.SOAPEnvelopeBoundaryAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:fec="http://ar.gob.afip.wsfecred/FECredService/"'
            SELF.SOAPAction                    = '"http://ar.gob.afip.wsfecred/FECredService/consultarMontoObligadoRecepcion"'    
        END!C
        self.Trace('RecordBoundary='&SELF.RecordBoundary)
        self.Trace('SOAPEnvelopeBoundaryAttribute='&SELF.SOAPEnvelopeBoundaryAttribute)
        !AQUI PUEDO USAR POR EJEMPLO DESDE UNA TABLA TRAER TODOS LOS DATOS POR ESO LO METO EN UN METODO
        RETURN
!---------------------------------------------------------
AJEImpositivoApiClass.GetUrl      PROCEDURE() !VIRTUAL
!---------------------------------------------------------
Method                                  EQUATE('GetUrl')
sXml                                    StringTheory       
Host                                    CSTRING(2048)
sUrl                                    StringTheory
    CODE
        self.Trace('WebServices='&SELF.WebServices)
        
        CASE lower(SELF.WebServices)
        OF 'loginticket'
            IF SELF.Modo = True THEN
                Host = AJEImpClass:LoginTicketUrlProduccion!Production
            ELSE
                Host = AJEImpClass:LoginTicketUrlHomologacion!Homologacion
            END!IF
            sUrl.SetValue('https://'&Host&'/ws/services/LoginCms')
        OF 'wsfe'
            IF SELF.Modo = True THEN
                Host = 'servicios1.afip.gov.ar'!Production
            ELSE
                Host = 'wswhomo.afip.gov.ar'!Homologacion
            END!IF
            sUrl.SetValue('https://'&Host&'/wsfev1/service.asmx')
        OF 'ws_sr_constancia_inscripcion'
            IF SELF.Modo = True THEN
                Host = 'aws.afip.gov.ar'!Production
            ELSE
                Host = 'awshomo.afip.gov.ar'!Homologacion
            END!IF
            sUrl.SetValue('https://'&Host&'/sr-padron/webservices/personaServiceA5') !Production
        OF 'wsfecred'
            IF SELF.Modo = True THEN
                Host = 'serviciosjava.afip.gob.ar'!Production
            ELSE
                Host = 'fwshomo.afip.gov.ar'!Homologacion !FALTA PONER BIEN
            END!IF
            sUrl.SetValue('https://'&Host&'/wsfecred/FECredService') !Production
        END!C
        
        !AQUI PUEDO USAR POR EJEMPLO DESDE UNA TABLA TRAER TODOS LOS DATOS POR ESO LO METO EN UN METODO
        RETURN sUrl.GetValue()

!---------------------------------------------------------
AJEImpositivoApiClass.CreateXMLMontoObligadoRecepcion      PROCEDURE(STRING pCuit,LONG pFecha) !VIRTUAL
!---------------------------------------------------------
Method                                                          EQUATE('CreateXMLMontoObligadoRecepcion')
sXml                                                            StringTheory
GetOligadoG                                                     GROUP,NAME('fec:consultarMontoObligadoRecepcionRequest')
authRequestG                                                        GROUP,NAME('authRequest')
Token                                                                   CSTRING(2048),NAME('token')
Sign                                                                    CSTRING(2048),NAME('sign')
cuitRepresentada                                                        CSTRING(21),NAME('cuitRepresentada')
                                                                    END!G
cuitConsultada                                                      CSTRING(21),NAME('cuitConsultada')
fechaEmision                                                        CSTRING(21),NAME('fechaEmision')
                                                                END!G
    CODE
        GetOligadoG.authRequestG.Token            = SELF.Token
        GetOligadoG.authRequestG.Sign             = SELF.Sign
        GetOligadoG.authRequestG.cuitRepresentada = SELF.CUIT
        GetOligadoG.cuitConsultada                = pCuit
        GetOligadoG.fechaEmision                  = FORMAT(pFecha,@D10-)
        sXml.SetValue(SELF.CrearXML(GetOligadoG,Method))
        sXml.SaveFile('consultarMontoObligadoRecepcion.xml')
        SELF.ProcesarRequest(sXml.GetValue(),Method)
        RETURN sXml.GetValue()       
!---------------------------------------------------------
AJEImpositivoApiClass.ConsultarMontoObligadoRecepcion       PROCEDURE(STRING pCuit,LONG pFecha) !VIRTUAL
!---------------------------------------------------------
Method                                                          EQUATE('ConsultarMontoObligadoRecepcion')
sUrl                                                            StringTheory
sPostString                                                     StringTheory
sResponse                                                       StringTheory
ReturnValue                                                     BYTE
    CODE
        SELF.WebServices = 'wsfecred'
        
        sPostString.SetValue(SELF.CreateXMLMontoObligadoRecepcion(pCuit,pFecha))
        sResponse.SetValue(SELF.SendRequest(SELF.GetUrl(),sPostString.GetVal(),'POST','SOAPAction: ""','text/xml;charset=UTF-8'))
        
        sResponse.ToUnicode(st:EncodeUtf8,st:CP_ISO_8859_1)
        
        ReturnValue = FALSE
        

        
        SELF.ProcesarRespuesta(sResponse.GetValue(),Method)   
        SELF.ProcesarErrores(sResponse)
!        UD.DebugGroup(SELF.ConsultarMontoObligadoG,'')
    
        RETURN ReturnValue        
!---------------------------------------------------------
AJEImpositivoApiClass.CreateXMLA5      PROCEDURE(STRING pCuit) !VIRTUAL
!---------------------------------------------------------
Method                                      EQUATE('CreateXMLA5')
sXml                                        StringTheory
GetPersonaG                                 GROUP,NAME('a5:getPersona')
Token                                           CSTRING(2048),NAME('token')
Sign                                            CSTRING(2048),NAME('sign')
cuitRepresentada                                CSTRING(21),NAME('cuitRepresentada')
idPersona                                       CSTRING(21),NAME('idPersona')
                                            END!G
    CODE
        GetPersonaG.Token            = SELF.Token
        GetPersonaG.Sign             = SELF.Sign
        GetPersonaG.cuitRepresentada = SELF.CUIT
        GetPersonaG.idPersona        = pCuit
        sXml.SetValue(SELF.CrearXML(GetPersonaG,Method))
        sXml.SaveFile('getPersonaA5.xml')
        SELF.ProcesarRequest(sXml.GetValue(),Method)
        RETURN sXml.GetValue()
!---------------------------------------------------------
AJEImpositivoApiClass.ConsultarA5        PROCEDURE(STRING pCuit) !VIRTUAL
!---------------------------------------------------------
Method                                      EQUATE('ConsultarA5')
sUrl                                        StringTheory
sPostString                                 StringTheory
sResponse                                   StringTheory
DNI                                         CSTRING(255)
WS                                          CSTRING(255)
FechaEmision                                CSTRING(255)
CUIT                                        CSTRING(255)                          ! 
Empresa                                     LONG
xA5XML                                      CLASS(xFileXML)
                                            END!C
    CODE
        CLEAR(SELF.A5ActividadMonotributistaG)
        CLEAR(SELF.A5CategoriaMonotributoG)
        CLEAR(SELF.A5DatosGeneralesG)
        CLEAR(SELF.A5DomicilioFiscalG)
        CLEAR(SELF.A5ErrorConstanciaG)
        CLEAR(SELF.A5ImpuestosG)
        
        SELF.WebServices = 'ws_sr_constancia_inscripcion'
        
        sPostString.SetValue(SELF.CreateXMLA5(pCuit))
        sResponse.SetValue(SELF.SendRequest(SELF.GetUrl(),sPostString.GetVal(),'POST','SOAPAction: ""'))
        
        sResponse.ToUnicode(st:EncodeUtf8,st:CP_ISO_8859_1)
        
        IF sResponse.Instring('HTTP/1.1 200 OK') THEN
            xA5XML.Load(SELF.A5DatosGeneralesG,sResponse.GetValuePtr(),sResponse.Len(),'personaReturn','datosGenerales') 
            xA5XML.Load(SELF.A5ActividadMonotributistaG,sResponse.GetValuePtr(),sResponse.Len(),'','actividad') 
            xA5XML.Load(SELF.A5ImpuestosG,sResponse.GetValuePtr(),sResponse.Len(),'','impuesto') 
            xA5XML.Load(SELF.A5DomicilioFiscalG,sResponse.GetValuePtr(),sResponse.Len(),'','domicilioFiscal') 
            xA5XML.Load(SELF.A5ErrorConstanciaG,sResponse.GetValuePtr(),sResponse.Len(),'','errorConstancia')
            xA5XML.Load(SELF.A5ActividadMonotributistaG,sResponse.GetValuePtr(),sResponse.Len(),'','actividadMonotributista')
            xA5XML.Load(SELF.A5CategoriaMonotributoG,sResponse.GetValuePtr(),sResponse.Len(),'','categoriaMonotributo')
        ELSE
            IF sResponse.Instring('<faultstring>') THEN
                SELF.Trace('Error consultando A5='&sResponse.Between('<faultstring>','</faultstring>'))
            END
        END!IF
        
        SELF.ProcesarRespuesta(sResponse.GetValue(),Method)   
        SELF.ProcesarErrores(sResponse)
!        UD.DebugGroup(SELF.A5DatosGeneralesG,'')
!        sResponse.SaveFile('A5Response.xml')
    
        RETURN pCuit
!---------------------------------------------------------
AJEImpositivoApiClass.CreateXMLConsultarUltimoNumero      PROCEDURE(LONG pPuntoVenta,LONG pComprobanteTipo) !VIRTUAL
!---------------------------------------------------------
Method                                                          EQUATE('CreateXMLConsultarUltimoNumero')
sXml                                                            StringTheory
GetUltimoNumeroG                                                GROUP,NAME('GetUltimoNumeroG')
AuthG                                                               GROUP,NAME('ar:Auth')
Token                                                                   CSTRING(2048),NAME('ar:Token')
Sign                                                                    CSTRING(2048),NAME('ar:Sign')
cuitRepresentada                                                        CSTRING(21),NAME('ar:Cuit')
                                                                    END!G
PuntoVenta                                                          LONG,NAME('ar:PtoVta')
ComprobanteTipo                                                     LONG,NAME('ar:CbteTipo')
                                                                END!G
    CODE
        GetUltimoNumeroG.AuthG.Token            = SELF.Token
        GetUltimoNumeroG.AuthG.Sign             = SELF.Sign
        GetUltimoNumeroG.AuthG.cuitRepresentada = SELF.CUIT
        GetUltimoNumeroG.PuntoVenta             = pPuntoVenta
        GetUltimoNumeroG.ComprobanteTipo        = pComprobanteTipo

        sXml.SetValue(SELF.CrearXML(GetUltimoNumeroG,Method))
        sXml.SaveFile('getUltimoNumero.xml')
        SELF.ProcesarRequest(sXml.GetValue(),Method)
        RETURN sXml.GetValue()

!---------------------------------------------------------
AJEImpositivoApiClass.ConsultarUltimoNumero        PROCEDURE(LONG pPuntoVenta,LONG pComprobanteTipo) !VIRTUAL
!---------------------------------------------------------
Method                                      EQUATE('ConsultarUltimoNumero')
sUrl                                        StringTheory
sPostString                                 StringTheory
sResponse                                   StringTheory

xXml                                                    xFileXML
    CODE
        SELF.WebServices = 'wsfe'
        sPostString.SetValue(SELF.CreateXMLConsultarUltimoNumero(pPuntoVenta,pComprobanteTipo))
        sResponse.SetValue(SELF.SendRequest(SELF.GetUrl(),sPostString.GetVal(),'POST','SOAPAction: '&SELF.SOAPAction,'text/xml;charset=UTF-8'))
        sResponse.ToUnicode(st:EncodeUtf8,st:CP_ISO_8859_1)
        IF sResponse.Instring('HTTP/1.1 200 OK') THEN
            xXml.Load(SELF.UltimoAutorizadoG,sResponse.GetValuePtr(),sResponse.Len(),'','FECompUltimoAutorizadoResult') 
        ELSE
            IF sResponse.Instring('<faultstring>') THEN
                SELF.Trace('Error consultando A5='&sResponse.Between('<faultstring>','</faultstring>'))
            END
        END!IF
        SELF.ProcesarRespuesta(sResponse.GetValue(),Method)   
        SELF.ProcesarErrores(sResponse)
        RETURN SELF.UltimoAutorizadoG.CbteNro
!------------------------------------------------------------------------------------------------
AJEImpositivoApiClass.CreateXMLFacturaElectronica      PROCEDURE() !VIRTUAL
!------------------------------------------------------------------------------------------------
Method                                                      EQUATE('CreateXMLFacturaElectronica')
sXml                                                        StringTheory
sAlicuotaIvaXml                                             StringTheory
sOpcionalXml                                                StringTheory
sCbteAsocXml                                                StringTheory
sTributosXml                                                StringTheory
sCompradoresXml                                             StringTheory
LOC:Iva                                                     LONG,AUTO
LOC:Opcionales                                              LONG,AUTO
LOC:CbteAsoc                                                LONG,AUTO
LOC:Compradores                                             LONG,AUTO
LOC:Tributos                                                LONG,AUTO
    CODE
        SELF.GetBoundariesByMethod(Method)
        !en este punto tiene que cargar el usuario del lado de la aplicación, y si pone datos en token y sign o cuit, estos serán reemplazados por el correcto
        SELF.FacturaElectronicaG.AuthG.Token            = SELF.Token
        SELF.FacturaElectronicaG.AuthG.Sign             = SELF.Sign
        SELF.FacturaElectronicaG.AuthG.cuitRepresentada = SELF.CUIT
!        xXml.start()
!        xXml.SetTagCase(xf:CaseAsIs)
!        xXml.SetDontSaveBlanks(true)
!        xXml.SetDontSaveBlankGroups(true)
!        xXml.SetReplaceChars(false)
!        xxml.SetRemovePrefix(false)
        sXml.SetValue(SELF.CrearXML(SELF.FacturaElectronicaG,Method))
        
        Do CheckAlicuotasIva
        Do CheckCbtesAsoc
        Do CheckOpcionales !chequea y crea el xml
        Do CheckTributos
        Do CheckCompradores
        
        sXml.SaveFile('FacturaElectronicaG.xml')
        SELF.ProcesarRequest(sXml.GetValue(),Method)
        RETURN sXml.GetValue()
        
CheckAlicuotasIva        ROUTINE
    LOC:Iva = 0
    sAlicuotaIvaXml.SetValue('<ar:Iva><13,10>')
    LOOP I# = 1 TO RECORDS(SELF.AlicuotasIVAQ)
        GET(SELF.AlicuotasIVAQ,I#)
        sAlicuotaIvaXml.Append('<ar:AlicIva><13,10>')
        sAlicuotaIvaXml.Append('<ar:Id>'&SELF.AlicuotasIVAQ.Id&'</ar:Id><13,10>')
        sAlicuotaIvaXml.Append('<ar:BaseImp>'&SELF.AlicuotasIVAQ.BaseImp&'</ar:BaseImp><13,10>')
        sAlicuotaIvaXml.Append('<ar:Importe>'&SELF.AlicuotasIVAQ.Importe&'</ar:Importe><13,10>')
        sAlicuotaIvaXml.Append('</ar:AlicIva><13,10>')
        LOC:Iva = 1
    END!L
    sAlicuotaIvaXml.Append('</ar:Iva><13,10>')
    
    IF LOC:Iva = 1 THEN
        sXml.Replace('<AlicuotasIvaQ/>',sAlicuotaIvaXml.GetValue())
    END!IF
    
                                
CheckOpcionales     ROUTINE
    LOC:Opcionales = 0
    sOpcionalXml.SetValue('<ar:Opcionales>')
    LOOP I# = 1 TO RECORDS(SELF.OpcionalesQ)
        GET(SELF.OpcionalesQ,I#)
        sOpcionalXml.append('<ar:Opcional>',0,'<13,10>')
        sOpcionalXml.append('<ar:Id>'&SELF.OpcionalesQ.Id&'</ar:Id>',0,'<13,10>')
        sOpcionalXml.append('<ar:Valor>'&SELF.OpcionalesQ.Valor&'</ar:Valor>',0,'<13,10>')
        sOpcionalXml.append('</ar:Opcional>',0,'<13,10>')
        LOC:Opcionales = 1
    END!L
    sOpcionalXml.append('</ar:Opcionales>',0,'<13,10>')
    
    IF LOC:Opcionales = 1 THEN 
        sXml.Replace('<OpcionalesQ/>',sOpcionalXml.GetValue())
    END!IF
    
CheckCbtesAsoc     ROUTINE
    Loc:CbteAsoc = 0
    sCbteAsocXml.SetValue('<ar:CbtesAsoc>')
    LOOP I# = 1 TO RECORDS(SELF.ComprobantesAsociadosQ)
        GET(SELF.ComprobantesAsociadosQ,I#)
        sCbteAsocXml.append('<ar:CbteAsoc>',0,'<13,10>')
        sCbteAsocXml.append('<ar:Tipo>'&SELF.ComprobantesAsociadosQ.Tipo&'</ar:Tipo>',0,'<13,10>')
        sCbteAsocXml.append('<ar:PtoVta>'&SELF.ComprobantesAsociadosQ.PtoVta&'</ar:PtoVta>',0,'<13,10>')
        sCbteAsocXml.append('<ar:Nro>'&SELF.ComprobantesAsociadosQ.Nro&'</ar:Nro>',0,'<13,10>')
        sCbteAsocXml.append('</ar:CbteAsoc>',0,'<13,10>')
        Loc:CbteAsoc = 1
    END!L
    sCbteAsocXml.append('</ar:CbtesAsoc>',0,'<13,10>')
    IF Loc:CbteAsoc = 1 THEN 
        sXml.Replace('<ComprobantesAsociadosQ/>',sCbteAsocXml.GetValue())
    END!IF

CheckTributos       ROUTINE
    
    Loc:Tributos = 0
    LOOP I# = 1 TO RECORDS(SELF.TributosQ)
        GET(SELF.TributosQ,I#)
        sTributosXml.append('<ar:Tributo>',0,'<13,10>')
        sTributosXml.append('<ar:Id>'&SELF.TributosQ.Id&'</ar:Id>',0,'<13,10>')
        sTributosXml.append('<ar:Desc>'&SELF.TributosQ.Descripcion&'</ar:Desc>',0,'<13,10>')
        sTributosXml.append('<ar:BaseImp>'&SELF.TributosQ.BaseImponible&'</ar:BaseImp>',0,'<13,10>')
        sTributosXml.append('<ar:Alic>'&SELF.TributosQ.Alicuota&'</ar:Alic>',0,'<13,10>')
        sTributosXml.append('<ar:Importe>'&SELF.TributosQ.Importe&'</ar:Importe>',0,'<13,10>')
        sTributosXml.append('</ar:Tributo>',0,'<13,10>')
        Loc:Tributos = 1
    END!L
    sTributosXml.append('</ar:Tributos>',0,'<13,10>')
    
    IF Loc:Tributos = 1 THEN 
        sXml.Replace('<TributosQ/>',sTributosXml.GetValue())
    END!IF
        
CheckCompradores       ROUTINE
    
    Loc:Compradores = 0
!            
    LOOP I# = 1 TO RECORDS(SELF.CompradoresQ)
        GET(SELF.CompradoresQ,I#)

        sCompradoresXml.SetValue('<ar:Compradores>')
        sCompradoresXml.append('<ar:Comprador>',0,'<13,10>')
        sCompradoresXml.append('<ar:DocTipo>'&SELF.CompradoresQ.DocumentoTipo&'</ar:Id>',0,'<13,10>')
        sCompradoresXml.append('<ar:DocNro>'&SELF.CompradoresQ.DocumentoNumero&'</ar:DocNro>',0,'<13,10>')
        sCompradoresXml.append('<ar:Porcentaje>'&SELF.CompradoresQ.Porcentaje&'</ar:Porcentaje>',0,'<13,10>')
        sCompradoresXml.append('</ar:Comprador>',0,'<13,10>')
        Loc:Compradores = 1
    END!L
    sCompradoresXml.append('</ar:Compradores>',0,'<13,10>')
    
    IF Loc:Compradores = 1 THEN 
        sXml.Replace('<CompradoresQ/>',sCompradoresXml.GetValue())
    END!IF
            
!---------------------------------------------------------
AJEImpositivoApiClass.SolicitarCAE        PROCEDURE() !VIRTUAL
!---------------------------------------------------------
Method                                          EQUATE('SolicitarCAE')
sUrl                                            StringTheory
sPostString                                     StringTheory
sResponse                                       StringTheory
xXml                                            xFileXML
    CODE
        SELF.WebServices = 'wsfe'
        sPostString.SetValue(SELF.CreateXMLFacturaElectronica())
        sResponse.SetValue(SELF.SendRequest(SELF.GetUrl(),sPostString.GetVal(),'POST','SOAPAction: '&SELF.SOAPAction,'text/xml;charset=UTF-8'))
        
        sResponse.ToUnicode(st:EncodeUtf8,st:CP_ISO_8859_1)
        
        IF sResponse.Instring('HTTP/1.1 200 OK') THEN
            xXml.Load(SELF.FacturaElectronicaResponseG,sResponse.GetValuePtr(),sResponse.Len(),'FECAESolicitarResponse','') 
        ELSE
            IF sResponse.Instring('<faultstring>') THEN
                SELF.Trace('Error consultando FECAE='&sResponse.Between('<faultstring>','</faultstring>'))
            END
                 
        END!IF
        
        SELF.ProcesarRespuesta(sResponse.GetValue(),Method)   
        SELF.ProcesarErrores(sResponse)
    
        RETURN   
!---------------------------------------------------------
AJEImpositivoApiClass.TestLoadXML        PROCEDURE() !VIRTUAL
!---------------------------------------------------------
Method                                          EQUATE('TestLoadXML')
sUrl                                            StringTheory
sPostString                                     StringTheory
sResponse                                       StringTheory
xXml                                            xFileXML
    CODE
        
        
!        SELF.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.AlicuotasIvaQ &= NEW AlicuotasIvaQT
!        SELF.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.AlicuotasIvaQ.AlicIvaG.ID = 5
!        SELF.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.AlicuotasIvaQ.AlicIvaG.BaseImp = 12
!        SELF.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.AlicuotasIvaQ.AlicIvaG.Importe = 123.45
!        ADD(SELF.FacturaElectronicaG.FeCAEReqG.FeDetReqG.FECAEDetRequestG.AlicuotasIvaQ)
!        
        sResponse.SetValue(SELF.CreateXMLFacturaElectronica())
        
        sResponse.LoadFile(LONGPATH()&'\SolicitudCAE.Log')
        sResponse.ToUnicode(st:EncodeUtf8,st:CP_ISO_8859_1)
        
        
        IF sResponse.Instring('HTTP/1.1 200 OK') THEN
            xXml.Load(SELF.FacturaElectronicaResponseG,sResponse.GetValuePtr(),sResponse.Len(),'FECAESolicitarResponse','') 
            UD.DebugGroup(SELF.FacturaElectronicaResponseG,'FE1')
            xXml.Load(SELF.FacturaElectronicaResponseG,sResponse.GetValuePtr(),sResponse.Len(),'','FeCabResp') 
            UD.DebugGroup(SELF.FacturaElectronicaResponseG,'FE2')
        ELSE
            IF sResponse.Instring('<faultstring>') THEN
                SELF.Trace('Error consultando FE='&sResponse.Between('<faultstring>','</faultstring>'))
            END
                 
        END!IF
        
        SELF.ProcesarRespuesta(sResponse.GetValue(),Method)   
        SELF.ProcesarErrores(sResponse)
    
        RETURN           
!EndRegion
       
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------	
AJEImpositivoApiClass.GetTableState       PROCEDURE (*FILE pTable)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------	
ReturnValue                             LONG
ErrorText                               CSTRING(1024)
    CODE
        IF STATUS(pTable) = 0 THEN
            OPEN(pTable, 42h)
            IF ERRORCODE() = 2 THEN
                CREATE(pTable)
                SELF.GetTableState(pTable)
            ELSIF ERRORCODE() THEN
                ErrorText = 'Error on OPEN for table ' &  Errorcode() & ' ' & Error() & ' ' & FileErrorCode() & ' ' & FileError()
                SELF.ErrorTrap('GetTableState',ErrorText)
                RETURN ERRORCODE()
            END
            ReturnValue = TRUE
        END
        RETURN ReturnValue	        
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------	
AJEImpositivoApiClass.CloseTable  PROCEDURE (*FILE pTable)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------	
ReturnValue                             LONG
ErrorText                               CSTRING(1024)
    CODE
        IF STATUS(pTable) => 0 THEN
            CLOSE(pTable)
            IF ERRORCODE()
                ErrorText = 'Error on CLOSE for table ' &  Errorcode() & ' ' & Error() & ' ' & FileErrorCode() & ' ' & FileError()
                SELF.ErrorTrap('CloseTable',ErrorText)
                RETURN ERRORCODE()
            END
            ReturnValue = TRUE
        END
        RETURN ReturnValue	   
!---------------------------------------------------------        
AJEImpositivoApiClass.ErrorTrap   PROCEDURE(STRING methodName, STRING errorMessage)
!---------------------------------------------------------
sDebug                              StringTheory
    CODE
!        Message(self.GetDebugMode())
!        IF SELF.GetDebugMode() = True THEN
            sDebug.Trace('Method='&methodName&' Error='&ErrorMessage)
!        END
        RETURN
!---------------------------------------------------
AJEImpositivoApiClass.ProcessRequest       PROCEDURE(*StringTheory pRequest,STRING pMethod)!,VIRTUAL
!---------------------------------------------------
    CODE
        RETURN