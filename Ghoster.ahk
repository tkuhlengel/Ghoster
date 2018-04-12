;Ghoster.ahk
; Dims inactive windows, shows a transparent image across the desktop, 
;Skrommel @2005
;tkuhlengel Revised 2018

#NoEnv
#SingleInstance,Force
SetBatchLines,-1
SetWindelay,0

applicationname=Ghoster2

OnExit,EXIT

START:
Gosub,READINI
Gosub,TRAYMENU
CoordMode,Mouse,Screen
WinGet,progmanid,Id,ahk_class Progman

WinGet,oldid,ID,A
WinGet,oldtop,ExStyle,ahk_id %oldid%
oldtop:=oldtop & 0x8

params=
If multimon=1
{
;  SysGet,nMon,MonitorCount
 SysGet,desktopw,78
 SysGet,desktoph,79
 SysGet,LeftCoord,76
 SysGet,TopCoord,77
;,SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN 
}
Else
{
  desktopw=%desktopw%
  desktoph=%desktoph%
  LeftCoord:=0
  TopCoord:=0
}
If stretchwidth=1
{
  width=%desktopw%
  x=%LeftCoord%
}
If stretchheight=1
{
  height=%desktoph%
  y=%TopCoord%
}
If keepaspect=1
  If width<>
    height=-1
  Else
    width=-1
If x<>
  params=%params% X%x%
If y<>
  params=%params% Y%y%
If width<>
  params=%params% W%width%
If height<>
  params=%params% H%height%
  
Gui,+ToolWindow -Disabled -SysMenu -Caption +E0x20 AlwaysOnTop 
Gui,Margin,0,0
If backcolor<>
  Gui,Color,%backcolor% 
If image<>
  Gui,Add,Picture,%params%,%image%
Gui,Show,X%LeftCoord% Y%TopCoord% W%desktopw% H%desktoph%, %applicationname%Window
Gui,+LastFound
guiid:=WinExist("A")
WinSet,Transparent,%transparency%,%applicationname%Window
WinGetPos,Xlast,Ylast,Wlast,Hlast,A
IsHidden:=0
DesktopActive:=0
LoopCounter:=0
ForceRedraw:=1
OnTopArray := [] ; or Array := Array()


LOOP:
; Sleep,%UpdateCheckInterval%
If (IsHidden=1)
{
	Sleep,%UpdateCheckInterval%
	Goto,LOOP
}
LoopCounter:= LoopCounter+UpdateCheckInterval
If(LoopCounter > RefreshInterval)
{
	ForceRedraw:=1
	Gosub,REDRAW
	LoopCounter:=0
}

WinGet,winid,ID,A
WinGet,wintopstyle,ExStyle,ahk_id %winid%
WinGetTitle,winActiveTitle,A
wintop:=wintopstyle & 0x8

If (showdesktop) 
{
	if (winActiveTitle=%applicationname% or winActiveTitle="Program Manager") 
	{
		DesktopActive:=1
		WinHide,%applicationname%Window
	}
    Else If (oldTitle=%applicationname% or oldTitle="Program Manager")
	{
			;WinMove,%LeftCoord%,%TopCoord%,,,%applicationname%Window
			;WinSet,Transparent,%transparency%,%applicationname%Window
			WinShow,%applicationname%Window
			DesktopActive:=0
	}
}
Else
{
	If (winActiveTitle=%applicationname%) 
	{
		DesktopActive:=1
	}
	Else If (oldTitle=%applicationname%) 
	{
		DesktopActive:=0
	}
}
If (jump) ; and !(winid=%progmanid%))
{  ;Show the active window on top of the ghosting.
	If (!wintop and DesktopActive!=1)
	{
		WinSet,AlwaysOnTop,On,ahk_id %winid%
		LoopCounter:=0
	}
}
If (showontop){
	;WinSet,Top,,%applicationname%Window
	SWP_NOMOVE=2 
	SWP_NOSIZE=1 
	SWP_NOACTIVATE=0x10 
	DllCall("SetWindowPos",Uint,WinExist("ahk_class Shell_TrayWnd"),Uint,guiid,Int,0,Int,0,Int,0,Int,0 ,Uint,SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE) 
}
Else
{
	SWP_NOMOVE=2 
	SWP_NOSIZE=1 
	SWP_NOACTIVATE=0x10 
	; WinSet,AlwaysOnTop,On,ahk_id %winid%
	DllCall("SetWindowPos",Uint,guiid ,Uint,winid,Int,0,Int,0,Int,0,Int,0,Uint,SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE) 

}
If winid<>%oldid%
{
	If (!oldtop) 
	{
		WinSet,AlwaysOnTop,Off,ahk_id %oldid%
	}
	Else  ;I'm ignoring the cases where you have a window being forced on top.
	{
		WinSet,AlwaysOnTop,Off,ahk_id %oldid%
	}
	oldid=%winid%
	oldtop=%wintop%
	oldTitle=%winActiveTitle%
	WinGetPos,Xlast,Ylast,Wlast,Hlast,A  ; needed for REDRAW
}
If (IsHidden<>1)
{
	Gosub,REDRAW
}
Sleep,%UpdateCheckInterval%
Goto,LOOP

REDRAW:
	WinGetPos,Xcurr,Ycurr,Wcurr,Hcurr,A
	; If the window moved.
	if(ForceRedraw=1 or Xcurr<>Xlast or Ycurr<>Ylast or Wlast<>Wcurr or Hlast<>Hcurr)
	{
		WinSet,Redraw,,%applicationname%Window
		;WinSet,AlwaysOnTop,On,ahk_id %winid%
		;WinHide,%applicationname%Window
		;WinShow,%applicationname%Window
		LoopCounter:=0
		ForceRedraw:=0
	}
	Xlast=%Xcurr%
	Ylast=%Ycurr%
	Wlast=%Wcurr%
	Hlast=%Hcurr%
	
Return
	
HIDE:
	;MsgBox(Ctrl+Shift+` clicked,,Note,1)
	If (IsHidden=0)
	{
		IsHidden:=1
		WinHide,%applicationname%Window
		WinSet,AlwaysOnTop,Off,ahk_id %winid%
		WinSet,AlwaysOnTop,Off,ahk_id %oldid%
		;WinSet,Transparent,0,%applicationname%Window
	}
	Else
	{
		IsHidden:=0
		;WinSet,Transparent,%transparency%,%applicationname%Window
		WinShow,%applicationname%Window
	}
	;Goto,LOOP
Return
READINI:
IfNotExist,%applicationname%.ini 
{
  ini=;%applicationname%.ini
  ini=%ini%`n`;backcolor=000000-FFFFFF or leave blank to speed up screen redraw.
  ini=%ini%`n`;image=                     Path to image or leave blank to speed up screen redraw.
  ini=%ini%`n`;x=any number or blank      Moves the image to the right.
  ini=%ini%`n`;y=any number or blank      Moves the image down.
  ini=%ini%`n`;width=any number or blank  Makes the image wider.
  ini=%ini%`n`;height=any number or blank Makes the image taller.
  ini=%ini%`n`;stretchwidth=1 or 0        Makes the image fill the width of the screen.
  ini=%ini%`n`;stretchheight=1 or 0       Makes the image fill the height of the screen.
  ini=%ini%`n`;keepaspect=1               Keeps the image from distorting.
  ini=%ini%`n`;RefreshInterval=3000       Number of Milliseconds between force redraw of the overlay screen.
  ini=%ini%`n`;UpdateCheckInterval=50     Time in milliseconds between loop iterations.  Longer values slow updating of the top window, shorter ones require more CPU time.
  ini=%ini%`n`;transparency=0-255         Makes the ghosting more or less translucent. 255 = opaque
  ini=%ini%`n`;jump=1 or 0                Makes the active window show through the ghosting.
  ini=%ini%`n`;showdesktop=1 or 0         Removes the ghosting when the desktop is active.
  ini=%ini%`n`;showontop=1 or 0           Removes ghosting from ontop windows like the taskbar.
  ini=%ini%`n`;multimon=1 or 0            Dim all monitors in a multimonitor system
  ini=%ini%`n
  ini=%ini%`n[Settings]
  ini=%ini%`nbackcolor=000000
  ini=%ini%`nimage=%A_WinDir%\Bubbles.bmp
  ini=%ini%`nx=
  ini=%ini%`ny=
  ini=%ini%`nwidth=
  ini=%ini%`nheight=
  ini=%ini%`nstretchwidth=1
  ini=%ini%`nstretchheight=1
  ini=%ini%`nkeepaspect=1
  ini=%ini%`nRefreshInterval=3000
  ini=%ini%`nUpdateCheckInterval=50
  ini=%ini%`ntransparency=150
  ini=%ini%`njump=1
  ini=%ini%`nshowdesktop=1
  ini=%ini%`nshowontop=0
  ini=%ini%`nmultimon=1
  ini=%ini%`n
  FileAppend,%ini%,%applicationname%.ini
  ini=
}
IniRead,backcolor,%applicationname%.ini,Settings,backcolor
IniRead,image,%applicationname%.ini,Settings,image
IniRead,x,%applicationname%.ini,Settings,x
IniRead,y,%applicationname%.ini,Settings,y

IniRead,width,%applicationname%.ini,Settings,width
IniRead,height,%applicationname%.ini,Settings,height
IniRead,stretchwidth,%applicationname%.ini,Settings,stretchwidth
IniRead,stretchheight,%applicationname%.ini,Settings,stretchheight
IniRead,keepaspect,%applicationname%.ini,Settings,keepaspect
IniRead,RefreshInterval,%applicationname%.ini,Settings,RefreshInterval
IniRead,UpdateCheckInterval,%applicationname%.ini,Settings,UpdateCheckInterval
IniRead,transparency,%applicationname%.ini,Settings,transparency
IniRead,jump,%applicationname%.ini,Settings,jump
IniRead,showdesktop,%applicationname%.ini,Settings,showdesktop
IniRead,showontop,%applicationname%.ini,Settings,showontop
IniRead,multimon,%applicationname%.ini,Settings,multimon
Return


TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,&Restart,RESTART
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,%applicationname%
Return


SETTINGS:
Run,%applicationname%.ini
Return


RESTART:
Gosub,DESTROY
Goto,START


DESTROY:
If oldtop
  WinSet,AlwaysOnTop,On,ahk_id %oldid%
Else
  WinSet,AlwaysOnTop,Off,ahk_id %oldid%
WinSet,AlwaysOnTop,Off,ahk_id %winid%
Gui,Destroy
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v2.0
Gui,99:Font
Gui,99:Add,Text,y+10,Dims inactive windows and shows a transparent image across the screen
Gui,99:Add,Text,y+10,- Change the image and other settings using Settings in the tray menu

Gui,99:Add,Picture,xm y+20 Icon5,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,99:Font
Gui,99:Add,Text,y+10,For more tools, information and donations, please visit 
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 G1HOURSOFTWARE,www.1HourSoftware.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon7,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,DonationCoder
Gui,99:Font
Gui,99:Add,Text,y+10,Please support the contributors at
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GDONATIONCODER,www.DonationCoder.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon6,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,AutoHotkey
Gui,99:Font
Gui,99:Add,Text,y+10,This tool was made using the powerful
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GAUTOHOTKEY,www.AutoHotkey.com
Gui,99:Font

Gui,99:Show,,%applicationname% About
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE") 
Return

1HOURSOFTWARE:
  Run,http://www.1hoursoftware.com,,UseErrorLevel
Return

DONATIONCODER:
  Run,http://www.donationcoder.com,,UseErrorLevel
Return

AUTOHOTKEY:
  Run,http://www.autohotkey.com,,UseErrorLevel
Return

99GuiClose:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static8,Static12,Static16
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


; Ctrl+Shift+I: Temporary tool to display information about the active window
; ^+i::Goto,WINDOWINFO

; Exit macro Ctrl+Shift+Q
^+q::Goto,EXIT

^+`::Goto,HIDE





EXIT:
WinActivate,ahk_class Shell_TrayWnd
WinWaitActive,ahk_class Shell_TrayWnd,,1
Gosub,DESTROY
WinSet,AlwaysOnTop,Off,ahk_id %oldid%
WinSet,AlwaysOnTop,Off,ahk_id %winid%
WinActivate,ahk_id %oldid%
ExitApp 


