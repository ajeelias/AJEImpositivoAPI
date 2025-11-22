!region Begin Comments
!!>Product         BASE API Class
!!>Author          Alejandro J. Elías
!!>Company         DeveloperTeam
!!>Copyright       @2024
!!>Version         001.0
!!>Template        
!!>Company URL     www.developerteam.com.ar
!!>Created         MAY 31,2024
!!>Modified        MAY 31,2024
!endregion End Comments

                    MEMBER()

    omit('***',_c55_)
_ABCDllMode_        EQUATE(0)
_ABCLinkMode_       EQUATE(1)
    ***

    INCLUDE('AJEBaseApiClass.INC'),ONCE
    INCLUDE('CWSYNCHM.INC'),ONCE
    INCLUDE('UltimateDebug.INC'),ONCE
    INCLUDE('jFiles.INC'),ONCE
    INCLUDE('EQUATES.CLW'),ONCE
    INCLUDE('ERRORS.CLW'),ONCE
    INCLUDE('KEYCODES.CLW'),ONCE
    INCLUDE('NetAll.INC'),ONCE
    INCLUDE('Netwww.INC'),ONCE
    INCLUDE('abwindow.INC'),once       
    INCLUDE('aberror.INC'),once            

EW_GUID             GROUP,TYPE
Data1                   ULONG
Data2                   USHORT
Data3                   USHORT
Data4                   BYTE,DIM(8)
                    END
AlreadyActive       LONG,STATIC

                    MAP

ProgressBar             PROCEDURE()

                        MODULE('Win32API')
                            OutputDebugString(*CSTRING),PASCAL,RAW,NAME('OutputDebugStringA')
                            AJEShellExecute(long hwnd, <*cstring lpOperation>, *cstring lpFile, <*cstring lpParameters>, <*cstring lpDirectory>, signed nShowCmd), unsigned, raw, pascal, proc, name('ShellExecuteA')
                            ew_CoCreateGuid(*EW_GUID),Long,Proc,Raw,Pascal,Name('CoCreateGuid')
                            ew_StringFromGuid2(*EW_GUID,*CString,Long),Long,Raw,Pascal,Proc,Name('StringFromGuid2')
                            !--------------------------------------------------------------------
                            ! The MultiByteToWideChar function maps a character string to a
                            ! wide-character (Unicode) string. The character string mapped by
                            ! this function is not necessarily from a multibyte character set,
                            ! it can be from the ANSI character set.  See MSDN for more info.
                            !--------------------------------------------------------------------
                            EW_MultiByteToWideChar(|
                                ULONG CodePage,          |   ! code page to map characters from
                                ULONG dwFlags,           |   ! character-type options
                                LONG lpMultiByteStr,     |   ! address of string to map
                                LONG cbMultiByte,        |   ! number of bytes in string
                                LONG lpWideCharStr,      |   ! address of wide-character buffer
                                LONG cchWideChar         |   ! size of buffer
                                ),LONG,PASCAL,RAW,PROC,Name('MultiByteToWideChar')
                            !-----------------------------------------------------------------------
                            ! The WideCharToMultiByte function maps a wide-character string to a
                            ! new character string. The new character string is not necessarily
                            ! from a multibyte character set, it can be from the ANSI character set.
                            !-----------------------------------------------------------------------
                            EW_WideCharToMultiByte(UNSIGNED CodePage, UNSIGNED dwFlags,        | ! performance and mapping flags
                                *CString lpWideCharStr,  | ! wide-character string
                                LONG cchWideChar,        | ! number of characters in string (-1 means Null terminated)
                                *CSTRING lpMultiByteStr, | ! the ANSI string
                                LONG cbMultiByte,        | ! size of buffer for new string
                                LONG lpDefaultChar=0,    | ! address of default for unmappable characters
                                LONG lpUsedDefaultChar=0 | ! address of flag set when default characters used
                                ),LONG,PASCAL,RAW,PROC,Name('WideCharToMultiByte')       ! Returns number of bytes written (including null) or 0 on failure
                        END!MODULE
                        MODULE('Kernel')
                            AJE:GetTimeZoneInformation(*TimeZoneInfoGT),LONG,PASCAL,RAW,PROC,NAME('GetTimeZoneInformation')
                            AJE:Sleep(LONG dwMilliseconds),PASCAL,NAME('SLEEP')
                            AJE:GetSystemTime(*NET_SYSTEMTIME lpSystemTime),PASCAL,RAW,NAME('GetSystemTime'),DLL(dll_mode)
                        END!Module
                    END!MAP

ud                  UltimateDebug,THREAD

sDebug              StringTheory
API                 &AJEBaseApiClass

ErrorG              GROUP,NAME('ErrorG')
Codigo                  CSTRING(255),Name('error_codigo')
Descripcion             CSTRING(1024),Name('error_descripcion')
                    END!G
RespuestaG          GROUP,NAME('RespuestaG')

                    END!G

!-----------------------------------------------------------------
AJEBaseApiClass.Construct   PROCEDURE()
!-----------------------------------------------------------------
    CODE
        API                 &= SELF    
        RETURN
!-----------------------------------------------------------------
AJEBaseApiClass.Destruct    PROCEDURE()
!-----------------------------------------------------------------
    CODE
        API                 &= NULL
        DISPOSE(API)
        RETURN
!---------------------------------------------------------
AJEBaseApiClass.RaiseError  PROCEDURE(STRING pErrorMsg)
!---------------------------------------------------------
    CODE
        IF SELF.InDebug = TRUE
            
        END
        SELF.Trace(pErrorMsg)
        
        RETURN
!---------------------------------------------------------
AJEBaseApiClass._Request    PROCEDURE(string pAction)
!---------------------------------------------------------
    CODE        
        RETURN    
!---------------------------------------------------------
AJEBaseApiClass.DateTime    PROCEDURE(STRING pDateTimeSQL)
!---------------------------------------------------------
sDateTime                       StringTheory
    CODE
        !YYYY-MM-DDTHH:mm:ss.sssZ. ISO 8601  
        sDateTime.SetValue(pDateTimeSQL)
        sDateTime.Replace('<32>','T')
        IF sDateTime.Len() > 6 THEN
            sDateTime.Append('Z')
        END!IF
        
        IF sDateTime.Instring('T00:00:00.000Z') THEN
            sDateTime.Replace('T00:00:00.000Z','T12:00:00.000Z')
        END!IF
        sDateTime.Replace('.000Z','Z')
        RETURN sDateTime.GetVal()        
!---------------------------------------------------------
AJEBaseApiClass.DateTime    PROCEDURE(LONG pDate,LONG pTime)
!---------------------------------------------------------
sDateTime                       StringTheory
    CODE
        !YYYY-MM-DDTHH:mm:ss.sssZ. ISO 8601  
        sDateTime.SetValue(FORMAT(pDate,@D10-))
        sDateTime.Append('T')
        sDateTime.Append(FORMAT(pTime,@T04))        
        sDateTime.Append('.000Z')        
        RETURN sDateTime.GetVal()
        
!---------------------------------------------------------
AJEBaseApiClass.ClarionToUnixDate   PROCEDURE(LONG pDate,LONG pTime)
!---------------------------------------------------------
sUnixTime                               StringFormat
    CODE
        
        RETURN sUnixTime.ClarionToUnixDate(pDate,pTime)  
!---------------------------------------------------------
AJEBaseApiClass.ClarionToUTCUnixDate        PROCEDURE(LONG pDate,LONG pTime)
!---------------------------------------------------------
    CODE
        
        RETURN SELF.ClarionToUnixDate(pDate,pTime)+SELF.CalcTimeZoneBiasFromUTC()
!---------------------------------------------------------
AJEBaseApiClass.GetElapsedTimeUTC   PROCEDURE(Long pBaseDate=61730)!,LONG
!---------------------------------------------------------
msPerDay                                real(24 * 60 * 60 * 1000)    ! don't make this an equate, needs to force the calc below to be real.
msPerHour                               equate     (60 * 60 * 1000)
msPerMinute                             equate          (60 * 1000)
msPerSecond                             equate               (1000)
today                                   long
ans                                     Real
tim                                     Group(NET_SYSTEMTIME).

    CODE
        AJE:GetSystemTime(tim)   ! returned time is for UTC not local time
        today = date(tim.wMonth,tim.wDay,tim.wYear)
        ans = (( today - pBaseDate ) * msPerDay ) + (tim.wHour * msPerHour) + (tim.wMinute * msPerMinute) + (tim.wSecond * msPerSecond) + tim.wMilliseconds
        RETURN ans
        
        
!----------------------------------------------------
AJEBaseApiClass.CalcTimeZoneBiasFromUTC     PROCEDURE()
!----------------------------------------------------
    CODE
        RETURN(SELF.CalcTimeZoneBiasToUTC())

!--------------------------------------------------
AJEBaseApiClass.CalcTimeZoneBiasToUTC       PROCEDURE()
!--------------------------------------------------
pRetVal                                         LONG,AUTO

pTimeZoneInfo                                   GROUP(TimeZoneInfoGT),PRE(pcvTZ)
                                                END
st                                              StringTheory

    CODE
        CASE AJE:GetTimeZoneInformation(pTimeZoneInfo)
        OF 0
            pRetVal = 0
        OF 1
            pRetVal = ((pTimeZoneInfo.Bias + pTimeZoneInfo.StandardBias) * 60)
        OF 2
            pRetVal = CHOOSE(pTimeZoneInfo.DayLightDate.dd_Month <> 0, ((pTimeZoneInfo.Bias + pTimeZoneInfo.DayLightBias) * 60), 0)
        END

        IF pRetVal < 0
            pRetVal -= 1
        ELSIF pRetVal > 0
            pRetVal += 1
        END

        RETURN(pRetVal)        
!--------------------------------------------------
AJEBaseApiClass.Time        PROCEDURE(LONG InHour, LONG InMin, LONG InSec,LONG InHS=0)!LONG
!--------------------------------------------------
BTTime                          TIME,AUTO
BT                              GROUP,OVER(BTTime)  !Note Little Endian reversal
HS                                  BYTE
Sec                                 BYTE
Min                                 BYTE
Hour                                BYTE
                                END
    CODE
        BT.HS   = InHS
        BT.Sec  = InSec
        BT.Min  = InMin
        BT.Hour = InHour
 
        RETURN BTTime   !Converts TIME to (Clarion Standard Time)
 

!---------------------------------------------------------
AJEBaseApiClass.SetLog      PROCEDURE(BYTE pActive,BYTE pTypeLog,STRING pApplicationINI)!,VIRTUAL
!---------------------------------------------------------!
    CODE
        SELF.ActiveLog      = pActive
        SELF.TypeLog        = pTypeLog
        SELF.ApplicationINI = CLIP(pApplicationINI)

        API.ActiveLog      = pActive
        API.TypeLog        = pTypeLog
        API.ApplicationINI = CLIP(pApplicationINI)
        
        RETURN
!---------------------------------------------------------
AJEBaseApiClass.SetFileLog  PROCEDURE(*FILE pTable)!,VIRUTAL
!---------------------------------------------------------
    CODE
        SELF.FileLog &= pTable
        API.FileLog  &= pTable
        RETURN
!---------------------------------------------------------
AJEBaseApiClass.SetFileLog  PROCEDURE(STRING pFileName)!,VIRUTAL
!---------------------------------------------------------
    CODE
        SELF.FileNameLog = CLIP(pFileName)
        API.FileNameLog = CLIP(pFileName)
        RETURN        
!---------------------------------------------------------
AJEBaseApiClass.AddLog      PROCEDURE(STRING pText)!,VIRTUAL        
!---------------------------------------------------------
sLog                            StringTheory
lRecord                         &GROUP
lFieldValue                     ANY
    CODE
        IF SELF.ActiveLog = true THEN
            CASE SELF.TypeLog
            OF 1 !Tabla
                DO AddFileLog
            OF 2 !File
                DO AddLog 
            OF 3 !Table & File
                DO AddFileLog
                DO AddLog
            OF 4 !Debugview
                SELF.Trace(pText)
            OF 5 !ALL
                DO AddFileLog
                DO AddLog
                !ud.Debug(pText)
            END!C
        END!IF
        
        RETURN

AddFileLog          ROUTINE
    OPEN(SELF.FileLog)
    IF ERRORCODE() THEN MESSAGE(ERROR() &' '&ERRORFILE()&' '&FILEERROR()&' '&FILEERRORCODE()).
    lRecord &= SELF.FileLog{PROP:Record} 
                
    lFieldValue &= WHAT(lRecord,1) !Guid
    lFieldValue = sLog.MakeGuid()
    lFieldValue &= WHAT(lRecord,2) !GuidCompany
    lFieldValue =   CLIP(GETINI('SETTINGS','GuidCompany','',SELF.ApplicationINI))
    lFieldValue &= WHAT(lRecord,3) !codigoEmpresa
    sLog.SetValue(CLIP(GETINI('SETTINGS','BASE','',SELF.ApplicationINI)))
    sLog.Replace('MT','')
    lFieldValue = sLog.GetVal() !solo numeros
    lFieldValue &= WHAT(lRecord,4) !ts
    lFieldValue = SELF.GetElapsedTimeUTC()
    lFieldValue &= WHAT(lRecord,7) !Date
    lFieldValue = TODAY()
    lFieldValue &= WHAT(lRecord,8) !Time
    lFieldValue = CLOCK()
    lFieldValue &= WHAT(lRecord,9) !Log
    lFieldValue = CLIP(pText)
                
    ADD(SELF.FileLog)
    IF ERRORCODE() THEN MESSAGE(ERROR() &' '&ERRORFILE()&' '&FILEERROR()&' '&FILEERRORCODE()).
    lFieldValue &= NULL
                
    CLOSE(SELF.FileLog)
AddLog              ROUTINE
    sLog.LoadFile(CHOOSE(SELF.FileNameLog='',LONGPATH()&'\Log'&FORMAT(TODAY(),@D06-)&'.Log',SELF.FileNameLog))
    sLog.Append(FORMAT(TODAY(),@D06)&'<9>'&FORMAT(CLOCK(),@T01)&'<9>'&pText&'<13,10>')
    sLog.SaveFile(CHOOSE(SELF.FileNameLog='',LONGPATH()&'\Log'&FORMAT(TODAY(),@D06-)&'.Log',SELF.FileNameLog))
        
!region GuidClass
!-----------------------------------
AJEBaseApiClass.WideCharToANSI      PROCEDURE(*CString WideString)!,STRING
!-----------------------------------
ANSIString                              CString(1024)
wcReturn                                Long
    CODE
        wcReturn = ew_WideCharToMultiByte(0,    | CP_ACP
        0,    | WC_NONE
        WideString,         |
            -1,    | !Null Terminated input
            ANSIString,       |
            SIZE(ANSIString), |
            0,    |WC_NULL
        0     |WC_NULL
        )
        If wcReturn = 0
            ANSIString = ''
        End
        
        Return ANSIString
!-----------------------------------
AJEBaseApiClass.GetGUID     PROCEDURE() !,STRING
!-----------------------------------
GUID                            LIKE(EW_GUID)                         ! 
szGUID                          CSTRING(256),AUTO                     ! 
szReturnGUID                    CSTRING(128),AUTO                     ! 
i                               LONG                                  ! 
j                               LONG                                  ! 
ThisAllowed                     LONG                                  ! 
ThisAllowedString               STRING(252)                           !  contains the users access rights
ds_Control                      SHORT  
ANSIString                      CSTRING(1024)
wcReturn                        LONG
    CODE
        szGUID       = All('<0>', Size(szGUID))
        szReturnGUID = All('<0>', Size(szReturnGUID))
        EW_CoCreateGUID(GUID)
        EW_StringFromGUID2(GUID, szGUID, Size(szGUID))

        szGUID = SELF.WideCharToANSI(szGUID)
        szGUID = Upper(szGUID)

        j# = 1
        Loop i# = 1 TO Len(szGUID)
            Case szGUID[i#]
            Of '{{'
                Cycle
            Of '}'
                Break
            End
            szReturnGUID[j#] = szGUID[i#]
            j# += 1
        End
        
        Return szReturnGUID		
!endregion		
!---------------------------------------------------
AJEBaseApiClass.Trace       PROCEDURE(STRING pText)
!---------------------------------------------------
szMsg                           CSTRING(size(pText)+12)
    CODE
        szMsg = '[APIClass] ' & Clip(pText)
        OutputDebugString(szMsg)
        RETURN
       
!---------------------------------------------------
AJEBaseApiClass.AnswerRequest       PROCEDURE(*StringTheory pAnswer,STRING pMethod)!,VIRTUAL
!---------------------------------------------------
    CODE
        RETURN
!---------------------------------------------------
ProgressBar         PROCEDURE()
!---------------------------------------------------
LocalRequest            LONG                                  ! 
OriginalRequest         LONG                                  ! 
LocalResponse           LONG                                  ! 
FilesOpened             LONG                                  ! 
WindowOpened            LONG                                  ! 
WindowInitialized       LONG                                  ! 
ForceRefresh            LONG                                  
QuickWindow             WINDOW('Requesting....'),AT(,,261,39),CENTER,GRAY,IMM,SYSTEM, |
                            FONT('Segoe UI',10,,FONT:regular,CHARSET:DEFAULT),TIMER(10), |
                            RESIZE
                            PROGRESS,AT(12,12,236,15),USE(?ProgressBar),RANGE(0,100)
                        END
ProgressIndicator       ProgressUTClass
    CODE
        ForceRefresh = False
        IF KEYCODE() = MouseRight
            SETKEYCODE(0)
        END
        DO PrepareProcedure
        ACCEPT
            CASE EVENT()
            OF EVENT:CloseDown
            OF EVENT:CloseWindow
                DO ProcedureReturn
            OF EVENT:OpenWindow
                IF NOT WindowInitialized
                    DO InitializeWindow
                    WindowInitialized = True
                END
            OF EVENT:Timer
                ProgressIndicator.TakeTimerEvent()
            END
        END
        DO ProcedureReturn
!---------------------------------------------------------------------------
PrepareProcedure    ROUTINE
    FilesOpened = TRUE
    OPEN(QuickWindow)
    QuickWindow{PROP:HIDE} = false
    WindowOpened=True
   
    ProgressIndicator.init(?ProgressBar)
    ProgressIndicator.StartProgress()
   
!---------------------------------------------------------------------------
ProcedureReturn     ROUTINE
    IF WindowOpened
        ProgressIndicator.EndProgress()
        CLOSE(QuickWindow)
    END
    RETURN
!---------------------------------------------------------------------------
InitializeWindow    ROUTINE
    DO RefreshWindow
!---------------------------------------------------------------------------
RefreshWindow       ROUTINE
    IF QuickWindow{Prop:AcceptAll} THEN EXIT.
    DISPLAY()
    ForceRefresh = False

!-------------------------------------------	
AJEBaseApiClass.SendTCP     PROCEDURE(STRING pUrl,STRING pPort,STRING pPostString,<LONG pProgressBar>,<*LONG pResponseCode>,<STRING pClientCertificate>,<STRING pPrivateClientKey>) !este se puede derivar para cuestiones especificas
!-------------------------------------------
        OMIT('NoNetTalk12Present',_NT12_)
        COMPILE('NetTalk11Present',_NT11_=1)
    CODE
        NetTalk11Present
        NoNetTalk12Present
COMPILE('NetTalk12Present',_NT12_=1)
Window                          WINDOW('Sending Request'),AT(,,261,39),GRAY,IMM,ICON(ICON:Application),FONT('MS Sans Serif',8,,FONT:regular),TOOLBOX
                                    PROGRESS,AT(12,12,236,15),USE(?PROGRESS1),RANGE(0,100)
                                END

ThisWindow                      CLASS(WindowManager)
Init                                PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
Kill                                PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
TakeEvent                           PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
TakeWindowEvent                     PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
                                END
TCP                             CLASS(NetSimple)                      ! Generated by NetTalk Extension (Class Definition)
ErrorTrap                           PROCEDURE(string errorStr,string functionName),DERIVED
Process                             PROCEDURE(),DERIVED
                                END!C
ProgressIndicator               ProgressUTClass
sPostUrl                        StringTheory
sPostString                     StringTheory
sResponse                       StringTheory
LOC:TIMER                       LONG
    CODE
        I# = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop
        RETURN sResponse.GetValue()   

SendData            ROUTINE
    CLEAR(TCP.Packet)

    TCP.Packet.BinData    = pPostString
    TCP.Packet.BinDataLen = len(clip(TCP.Packet.BinData))

    TCP.Send()
!-------------------------------------------------------------------
Disconnect          Routine
    TCP.Close()        ! Tell the object to close the connection.
    
        
ThisWindow.Init     PROCEDURE
ReturnValue             BYTE,AUTO
    CODE    
        ReturnValue =  PARENT.Init()
        IF ReturnValue THEN RETURN ReturnValue.
        SELF.FirstField =  1
        SELF.Open(Window)                                        ! Open window

!        TCP.SuppressErrorMsg = 1    ! No Object Generated Error Messages ! Generated by NetTalk Extension
        TCP.Init(NET:SimpleClient)  ! TCP mode
        if TCP.error <> 0
        end
        
        TCP.DontErrorTrapInSendIfConnectionClosed = 1 ! We want to trap for this error ourselves. The error if it occurs is ERROR:ClientNotConnected
      
        TCP.AsyncOpenUse = 0
        TCP.AsyncOpenTimeOut = 900 
        TCP.InActiveTimeout  = 400
        
        TCP.Open(pUrl,pPort,2)
        
        IF NOT OMITTED(pProgressBar) THEN
            Window{Prop:Hide}=True
        END
        
        DO SendData
        
        SELF.SetAlerts()
        RETURN ReturnValue
        
ThisWindow.Kill     PROCEDURE
ReturnValue             BYTE,AUTO
    CODE
        TCP.Kill()                              ! Generated by NetTalk Extension
        ProgressIndicator.EndProgress()
        ReturnValue =  PARENT.Kill()
        IF ReturnValue THEN RETURN ReturnValue.
        RETURN ReturnValue

ThisWindow.TakeEvent        PROCEDURE
ReturnValue                     BYTE,AUTO
Looped                          BYTE
    CODE
        LOOP                                                     ! This method receives all events
            IF Looped
                RETURN Level:Notify
            ELSE
                Looped =  1
            END
            TCP.TakeEvent()                 ! Generated by NetTalk Extension
        
            ReturnValue =  PARENT.TakeEvent()
            RETURN ReturnValue
        END
        ReturnValue =  Level:Fatal
        RETURN ReturnValue


ThisWindow.TakeWindowEvent  PROCEDURE
ReturnValue                     BYTE,AUTO
Looped                          BYTE
    CODE
        LOOP                                                     ! This method receives all window specific events
            IF Looped
                RETURN Level:Notify
            ELSE
                Looped =  1
            END
            ReturnValue =  PARENT.TakeWindowEvent()
            CASE EVENT()
            OF EVENT:OpenWindow
!                DO SendRequest
            OF EVENT:Timer
                IF LOC:Timer = 60 THEN
                    POST(EVENT:CloseWindow)
                ELSE
                    LOC:Timer += 1
                END!IF
        
                UD.Debug('Timer='&LOC:Timer)
                ProgressIndicator.TakeTimerEvent()     
            END
            RETURN ReturnValue
        END
        ReturnValue =  Level:Fatal
        RETURN ReturnValue
        
TCP.ErrorTrap   PROCEDURE(string errorStr,string functionName)
    CODE
        PARENT.ErrorTrap(errorStr,functionName)
        MESSAGE('ERROR='&errorStr&' -- '&functionName)
        POST(EVENT:CloseWindow)
TCP.Process     PROCEDURE()
    CODE
        PARENT.Process()
        DO Disconnect
        POST(EVENT:CloseWindow)
        RETURN
        
 NetTalk12Present    
!-------------------------------------------	
AJEBaseApiClass.SendRequest PROCEDURE(STRING pApiUrl,STRING pPostString,STRING pAction,<STRING pCustomHeader>,<STRING pContentType>,<LONG pProgressBar>,<*LONG pResponseCode>,<STRING pClientCertificate>,<STRING pPrivateClientKey>,<STRING pFileName>) !este se puede derivar para cuestiones especificas
!-------------------------------------------

LocalRequest                    LONG                                  
OriginalRequest                 LONG                                  
LocalResponse                   LONG                                   
FilesOpened                     LONG                                   
WindowOpened                    LONG                                   
WindowInitialized               LONG                                  
ForceRefresh                    LONG                            

sHtml                           StringTheory
sTable                          StringTheory
sFilter                         StringTheory
sOrder                          StringTheory
sLanguage                       StringTheory
sResponse                       StringTheory
ProgressIndicator               ProgressUTClass
PostUrl                         StringTheory
PostString                      StringTheory
Window                          WINDOW('Sending Request'),AT(,,261,39),GRAY,IMM,ICON(ICON:Application),FONT('MS Sans Serif',8,,FONT:regular),TOOLBOX
                                    PROGRESS,AT(12,12,236,15),USE(?PROGRESS1),RANGE(0,100)
                                END

ThisWindow                      CLASS(WindowManager)
Init                                PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
Kill                                PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
TakeEvent                           PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
TakeWindowEvent                     PROCEDURE(),BYTE,PROC,DERIVED       ! Method added to host embed code
                                END

Request                         CLASS(NetWebClient)                   ! Generated by NetTalk Extension (Class Definition)
ErrorTrap                           PROCEDURE(string errorStr,string functionName),DERIVED
PageReceived                        PROCEDURE(),DERIVED

                                END 

ACounter                        LONG

Loc:Timer                       LONG
    CODE   
    
        i# = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop
        RETURN sResponse.GetValue()
        
SendRequest         ROUTINE
    ProgressIndicator.Init(?PROGRESS1)
    ProgressIndicator.StartProgress()

    Request.SetAllHeadersDefault()
    Request.Pragma_ 		= 'No-Cache'  ! Force any proxies to not use their cache. Uses more bandwidth but will contact the webserver directly which is what we want.
    Request.CacheControl 	= 'No-Cache'  ! Force any proxies to not use their cache. Uses more bandwidth but will contact the webserver directly which is what we want.
     
    Request.ContentType=CHOOSE(CLIP(pContentType)='','application/json',CLIP(pContentType))
    Request.HTTPVersion='HTTP/1.0'
	
    Request.SSLCertificateOptions.CertificateFile = CLIP(pClientCertificate)
    
    IF NOT OMITTED(pPrivateClientKey) THEN
        Request.SSLCertificateOptions.PrivateKeyFile  = CLIP(pPrivateClientKey)
    ELSE
        Request.SSLCertificateOptions.PrivateKeyFile  = CLIP(pClientCertificate)
    END!IF
    
    UD.Debug('SendRequest CertificateFile='&CLIP(pClientCertificate))
    UD.Debug('SendRequest PrivateKeyFile='&CLIP(pPrivateClientKey)&'-->'&CLIP(pClientCertificate))
    
    Request.AsyncOpenUse = true
    
    IF pCustomHeader THEN
        Request.CustomHeader = CLIP(pCustomHeader)
        IF INSTRING('Accept: application/json',Request.CustomHeader,1,1) THEN
            Request.SetAccept('json')
        END!IF
    END
    
    IF pFileName THEN
        Request.FreeFieldsQueue()
        Request.SetValue('purpose','assistants')
        Request.SetValue('file', pFileName, net:AsFile, 'application/pdf')
    END!IF
    
    
    UD.Debug('SendRequest='&pApiUrl&' Post='&clip(pPostString)&' ContentType='&pContentType)
    
    CASE pAction
    OF 'GET'
        ProgressIndicator.Progress=50
        Request.Fetch(pApiUrl)
    OF 'PATCH'
        ProgressIndicator.Progress=50
        Request.Patch(pApiUrl,pPostString)
    OF 'PUT'
        ProgressIndicator.Progress=50
        Request.Put(pApiUrl,pPostString)
    OF 'POST'
        ProgressIndicator.Progress=50
        Request.POST(pApiUrl,pPostString)
    OF 'ACT'
        ProgressIndicator.Progress=50
        Request.Fetch(pApiUrl)
    OF 'HEAD'
        ProgressIndicator.Progress=50
        Request.HeaderOnly = True
        Request.Fetch(pApiUrl)
        
    END!C
    
ThisWindow.Init     PROCEDURE

ReturnValue             BYTE,AUTO

    CODE    
        ReturnValue =  PARENT.Init()
        IF ReturnValue THEN RETURN ReturnValue.
        SELF.FirstField =  1
        SELF.Open(Window)                                        ! Open window
!    0{PROP:Hide                  } =  TRUE
        Request.SuppressErrorMsg = 1         ! No Object Generated Error Messages ! Generated by NetTalk Extension
        Request.init()
        if Request.error <> 0
        end
	
        IF NOT OMITTED(pProgressBar) THEN
            Window{Prop:Hide}=True
        END
        SELF.SetAlerts()
        RETURN ReturnValue
        
ThisWindow.Kill     PROCEDURE

ReturnValue             BYTE,AUTO

    CODE
        Request.Kill()                              ! Generated by NetTalk Extension
        ProgressIndicator.EndProgress()
        ReturnValue =  PARENT.Kill()
        IF ReturnValue THEN RETURN ReturnValue.
        RETURN ReturnValue

ThisWindow.TakeEvent        PROCEDURE

ReturnValue                     BYTE,AUTO

Looped                          BYTE
    CODE
        LOOP                                                     ! This method receives all events
            IF Looped
                RETURN Level:Notify
            ELSE
                Looped =  1
            END
            Request.TakeEvent()                 ! Generated by NetTalk Extension
        
            ReturnValue =  PARENT.TakeEvent()
            RETURN ReturnValue
        END
        ReturnValue =  Level:Fatal
        RETURN ReturnValue


ThisWindow.TakeWindowEvent  PROCEDURE

ReturnValue                     BYTE,AUTO

Looped                          BYTE
    CODE
        LOOP                                                     ! This method receives all window specific events
            IF Looped
                RETURN Level:Notify
            ELSE
                Looped =  1
            END
            ReturnValue =  PARENT.TakeWindowEvent()
            CASE EVENT()
            OF EVENT:OpenWindow
                DO SendRequest
            OF EVENT:Timer
!                IF LOC:Timer = 60 THEN
!                    POST(EVENT:CloseWindow)
!                ELSE
!                    LOC:Timer += 1
!                END!IF
!        
!                UD.Debug('Timer='&LOC:Timer)
!                ProgressIndicator.TakeTimerEvent()     
            END
            RETURN ReturnValue
        END
        ReturnValue =  Level:Fatal
        RETURN ReturnValue

    
Request.ErrorTrap   PROCEDURE(string errorStr,string functionName)
Temp2                   String(2000)
StError                 StringTheory
    CODE
        UD.Debug('Error='&errorStr&' '&functionName)
        
        temp2 = self.InterpretError()
        if self.error = 0
            temp2 = clip(errorStr) & '.'
        else
            temp2 = clip(errorStr) & '.' & ' The error number was ' & self.error & ' which means ' & clip(temp2) & '.'
        end
        if self.error = ERROR:OpenTimeOut or (self.Error >= ERROR:SSLGeneralFailure and self.Error < ERROR:NetTalkObjectAndDLLDontMatch)
  			! Also list the WinSock or SSL Errors
            if self.WinSockError
!				temp2 = clip(temp2) & ' - [WinSock Error = ' & self.WinSockError & ' : ' & clip (NetErrorStr (self.)) & ']'
            end
            if self.SSLError
                temp2 = clip(temp2) & ' - [SSL Error = ' & self.SSLError & ']'
            end
        end
        PARENT.ErrorTrap(errorStr,functionName)
        if self.Packet.PacketType = |
            NET:SimpleAsyncOpenFailed
            UD.Debug ('Connection failed to'&|
                ' open.' & |
                ' NetError = ' & |
                self.packet.NetError & |
                ' SSLError = ' & |
                self.packet.SSLError & |
                ' WinSockError = ' & |
                self.packet.WinSockError)
        end

        UD.Debug('ErrorTrap was called.' & |
            '<13,10>Error Code: ' & self.error & |
            '<13,10>Error Message: ' & clip(temp2) & |
            '<13,10,13,10>Passed Message: '& clip(errorStr) & |
            '<13,10>Function: ' & clip(functionName) & |
            '<13,10>Host: ' & CLIP(self.Host) & |
            '<13,10>_Command: ' & clip(self._CommandText.GetValue()) & |
            '')
        StError.Append('ErrorTrap',1,'|')
        StError.Append('Error Code:' & self.error,1,'|')
        StError.Append('Error Message:' & clip(temp2),1,'|')
        StError.Append('Passed Message: '& clip(errorStr),1,'|')
        StError.Append('Function:' & clip(functionName),1,'|')
        StError.Append('Host:' & CLIP(self.Host),1,'|')
        StError.Append('Command:' & clip(self._CommandText.GetValue()),1)
        
        sResponse.SetValue(StError.GetValue())
        ProgressIndicator.EndProgress()
        POST(EVENT:CloseWindow)

Request.PageReceived        PROCEDURE
Response                        StringTheory
St                              StringTheory
StResult                        StringTheory
    CODE
        if self.HeaderOnly = 1
            self.abort()
        end

        
!        IF OMITTED(pResponseCode) = FALSE
!            IF SELF.ServerResponse = 200 OR SELF.ServerResponse=201 THEN
!                pResponseCode   = NET:OK
!            ELSE
!                pResponseCode   = NET:NOTOK
!            END
!            SELF.Debug('ResponseCode='&pResponseCode)
!        END
        
        
        PARENT.PageReceived
		
!        SELF.RemoveHeader()
        
        Response.SetValue(SELF.ThisPage.GetValue(),True)
        
        sResponse.SetValue(Response.GetValue())
        
        UD.Debug('Respuesta='&Response.GetVal())
  		  		
        ProgressIndicator.EndProgress()
        
        POST(EVENT:CloseDown)




ProgressUTClass.Construct   PROCEDURE()
    CODE
        SELF.Controls &= NEW AJEUProgressQT
  
ProgressUTClass.Destruct    PROCEDURE()
    CODE
        FREE(SELF.Controls)
        DISPOSE(SELF.Controls)

ProgressUTClass.init        PROCEDURE(LONG p_ProgressFeq)
    CODE
        SELF.Feq = p_ProgressFeq
  
ProgressUTClass.AddControl  PROCEDURE(LONG p_Feq)
    CODE
        SELF.Controls.Feq = p_Feq
        GET(SELF.Controls, SELF.Controls.Feq)
        if errorcode()
            CLEAR(SELF.Controls)
            SELF.Controls.Feq = p_Feq
            ADD(SELF.Controls, SELF.Controls.Feq)
        end!if

ProgressUTClass.StartProgress       PROCEDURE()
    CODE
        SELF.Running = true
        UNHIDE(SELF.Feq)
        SELF.Progress = 50
        SELF.Feq{PROP:RangeHigh} = 100
        SELF.Feq{prop:Progress} = SELF.Progress
        SELF.OldTimer = 0{prop:Timer}
        0{prop:Timer} = 100    
  
        SELF.DisableControls(true)
  
ProgressUTClass.EndProgress PROCEDURE()
    CODE
        SELF.Running = false
        HIDE(SELF.Feq)
        0{prop:Timer} = SELF.OldTimer
        SELF.DisableControls(false)
  
ProgressUTClass.DisableControls     PROCEDURE(BYTE p_Disable)
a                                       LONG
    CODE
        LOOP a = 1 to Records(SELF.Controls)
            GET(SELF.Controls,a)
            if p_Disable
                DISABLE(SELF.Controls.Feq)
            ELSE
                ENABLE(SELF.Controls.Feq)
            end!If
        end!loop  

ProgressUTClass.TakeTimerEvent      PROCEDURE()
    CODE
        if SELF.Running
            SELF.Progress += 1
            if SELF.Progress >= 100
                SELF.Progress = 1
            end!If
            SELF.Feq{PROP:Progress} = SELF.Progress
        end!If  
!  
