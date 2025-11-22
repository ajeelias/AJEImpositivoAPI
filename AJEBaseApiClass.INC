!region Begin Comments

!!>Product         Base API Class
!!>Author          Alejandro J. Elías
!!>Company         DeveloperTeam
!!>Copyright       @2024
!!>Version         001.0
!!>Template        
!!>Company URL     www.developerteam.com.ar
!!>Created         JAN 18,2024
!!>Modified        JAN 18,2024
!endregion End Comments
    INCLUDE('cwsynchc.inc'),ONCE
!    INCLUDE('ULTIMATESQL.INC'),ONCE

!region Equates
AJEBaseApi:GET      EQUATE('GET')
AJEBaseApi:POST     EQUATE('POST')
AJEBaseApi:PUT      EQUATE('PUT')
AJEBaseApi:PATCH    EQUATE('PATCH')
AJEBaseApi:HEAD     EQUATE('HEAD')
AJEBaseApi:OPTIONS  EQUATE('OPTIONS')


!endregion

TimeZoneInfoGT      GROUP,TYPE
Bias                    LONG
StandardName            USHORT,DIM(32)
StandardDate            GROUP,PRE(nysTZIDDTZISD)
sd_Year                     USHORT
sd_Month                    USHORT
sd_DayOfWeek                USHORT
sd_Day                      USHORT
sd_Hour                     USHORT
sd_Minute                   USHORT
sd_Second                   USHORT
sd_MilliSecond              USHORT
                        END
StandardBias            LONG
DayLightName            USHORT,DIM(32)
DayLightDate            GROUP,PRE(nysTZIDD)
dd_Year                     USHORT
dd_Month                    USHORT
dd_DayOfWeek                USHORT
dd_Day                      USHORT
dd_Hour                     USHORT
dd_Minute                   USHORT
dd_Second                   USHORT
dd_MilliSecond              USHORT
                        END
DayLightBias            LONG
                    END!GT

AJEBaseApiClass  CLASS,TYPE,THREAD,MODULE('AJEBaseApiClass.CLW'),LINK('AJEBaseApiClass.CLW',_ABCLinkMode_),DLL(_ABCDllMode_)
!----------
!Properties
!----------
InDebug                 BYTE

locker                  &ICriticalSection,PROTECTED
ActiveLog               BYTE
TypeLog                 BYTE
FileLog                 &FILE
FileNameLog             CSTRING(1024)
ApplicationINI          CSTRING(1024)
!----------
!Methods
!----------
Construct               PROCEDURE()
Destruct                PROCEDURE()
RaiseError              PROCEDURE(STRING pErrorMsg)

_Request                PROCEDURE(STRING pAction)
DateTime                PROCEDURE(LONG pDate,LONG pTime),STRING,PROC,VIRTUAL
DateTime                PROCEDURE(STRING pDateTimeSQL),STRING,PROC,VIRTUAL
ClarionToUnixDate       PROCEDURE(LONG pDate,LONG pTime),REAL,PROC,VIRTUAL
ClarionToUTCUnixDate    PROCEDURE(LONG pDate,LONG pTime),REAL,PROC,VIRTUAL
GetElapsedTimeUTC       PROCEDURE(LONG pBaseDate=61730),LONG,PROC,VIRTUAL
CalcTimeZoneBiasToUTC   PROCEDURE(),REAL,PROC,VIRTUAL
CalcTimeZoneBiasFromUTC PROCEDURE(),REAL,PROC,VIRTUAL
GetGUID                 PROCEDURE(),STRING
WideCharToANSI          PROCEDURE(*CString WideString),STRING,PROC
SendTCP                 PROCEDURE(STRING pUrl,STRING pPort,STRING pPostString,<LONG pProgressBar>,<*LONG pResponseCode>,<STRING pClientCertificate>,<STRING pPrivateClientKey>),STRING,PROC,VIRTUAL
SendRequest             PROCEDURE(STRING pApiUrl,STRING pPostString,STRING pAction,<STRING pCustomHeader>,<STRING pContentType>,<LONG pProgressBar>,<*LONG pResponseCode>,<STRING pClientCertificate>,<STRING pPrivateClientKeypPrivateClientKey>,<STRING pFileName>),PROC,VIRTUAL,STRING
SetLog                  PROCEDURE(BYTE pActive,BYTE pTypeLog,STRING pApplicationINI),VIRTUAL
SetFileLog              PROCEDURE(*FILE pTable),VIRTUAL
SetFileLog              PROCEDURE(STRING pFileName),VIRTUAL
AddLog                  PROCEDURE(STRING pText),VIRTUAL
Time                    PROCEDURE(LONG InHour, LONG InMin, LONG InSec,LONG InHS=0),LONG
Trace                   PROCEDURE(STRING pText)
!Virtual Proc
AnswerRequest           PROCEDURE(*StringTheory pAnswer,STRING pMethod),VIRTUAL
                    END!CLASS

AJEUProgressQT      QUEUE,PRE(PQE),TYPE
Feq                     LONG
                    END!Q
ProgressUTClass     CLASS,TYPE,MODULE('AJEBaseApiClass.CLW'),LINK('AJEBaseApiClass.CLW',_ABCLinkMode_),DLL(_ABCDllMode_)

Feq                     LONG
Progress                LONG
OldTimer                LONG
Controls                &AJEUProgressQT
Running                 BYTE

Construct               PROCEDURE()
Destruct                PROCEDURE()

init                    PROCEDURE(LONG ProgressFeq)
AddControl              PROCEDURE(LONG p_Feq)

StartProgress           PROCEDURE()
EndProgress             PROCEDURE()

DisableControls         PROCEDURE(BYTE p_Disable)
TakeTimerEvent          PROCEDURE()
                    END!CLASS