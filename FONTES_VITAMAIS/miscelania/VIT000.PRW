user function VIT000()
    Local cModulo 	:= 'SIGAFAT' //Defino em qual módulo irei abrir a minha função
    MsApp():New(cModulo) //
    oApp:cInternet := NIL     
    oApp:CreateEnv()
    PtSetTheme("OCEAN")
    oApp:cStartProg    	:= 'u_VITMIS11'//'u_AGRA02'//'U_AGR002'
    oApp:lMessageBar	:= .T. 
    oApp:cModDesc		:= cModulo
    __lInternet 		:= .T.
    lMsFinalAuto 		:= .F.
    oApp:lMessageBar	:= .T. 
    oApp:Activate()
Return
