;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         David <tchepak@gmail.com>
;
; Script Function:
;   Provides an Emacs-like keybinding emulation mode that can be toggled on and off using
;   the CapsLock key.
;


;==========================
;Initialise
;==========================
#SingleInstance ignore ; Only run a single instance of script.
;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FilteredWindowList:=[]
FilterWindowMatchMode:=[]
FilteredWindowCount := 0
enabledIcon := "keyboard_on_icn.ico"
disabledIcon := "keyboard_off_icn.ico"
IsInEmacsMode := true
SetEmacsMode(IsInEmacsMode)
SetCapsLockState, AlwaysOff


;==========================
;Filtered Out Windows
;==========================
f_AddFilterWindow( "ahk_class PuTTY" )
f_AddFilterWindow( "ahk_class Emacs" )
f_AddFilterWindow( " - Conkeror$", "RegEx" )
f_AddFilterWindow("ahk_class SWT_Window0")
;f_AddFilterWindow( "NetBeans IDE [0-9\.]*$", "RegEx" )
f_AddFilterWindow( "ahk_class illustrator" )
f_AddFilterWindow( "ahk_class photoshop" )
f_AddFilterWindow( "Blender" )
f_AddFilterWindow( "ahk_class mintty" )

;==========================
;Functions
;==========================
SetEmacsMode(toActive) {
  local iconFile := toActive ? enabledIcon : disabledIcon
  local state := toActive ? "ON" : "OFF"

  IsInEmacsMode := toActive
  ;TrayTip, Keyboard Modifier, State: %state%, 1, 1
  Menu, Tray, Icon, %iconFile%,
  Menu, Tray, Tip, Keyboard Modifier: %state%

  Send {Shift Up}
}

SendCommand(emacsKey, translationToWindowsKeystrokes, secondWindowsKeystroke="") {
  global IsInEmacsMode
  if( IsInEmacsMode && f_IsFilteredWindow( ) == false )
  {
    Send, %translationToWindowsKeystrokes%
    if secondWindowsKeystroke != ""
	{
      Send, %secondWindowsKeystroke%
    }
  }
  else
  {
    Send, %emacsKey% ;passthrough original keystroke
  }
  return
}

f_AddFilterWindow( windowTitle, matchMode=1 )
{
  global ; Sets entire function global
	;global FilteredWindowList
	;global FilterWindowMatchMode

	;global FilteredWindowCount

	FilteredWindowList[FilteredWindowCount] := windowTitle
	FilterWindowMatchMode[FilteredWindowCount] := matchMode
	FilteredWindowCount++
}

f_IsFilteredWindow( )
{
	global ;FilteredWindowCount
  ;global FilteredWindowList
  ;global FilterWindowMatchMode
	local retVal := 0

	Loop, % FilteredWindowMatchMode.MaxIndex()
	{
    MsgBox, % FilterWindowMatchMode[A_Index - 1]
		;SetTitleMatchMode % FilterWindowMatchMode[A_Index -1]
		filteredWindow := FilteredWindowList[A_Index - 1]
		IfWinActive, %filteredWindow%
		{
			retVal := 1
			break
		}
	}
	return retVal
}

f_EmacsInputCommand(emacsKey)
{
	global IsInEmacsMode

	if(IsInEmacsMode && f_IsFilteredWindow( ) == false ){
		Input, UserInput, T1.5 L1 I,{esc}{Enter}
		Send % "^" . UserInput
	} else {
		Send, %emacsKey%
	}
	return
}

f_SendInputMF( p_key )
{
	m_ctrl_state := GetKeyState("Ctrl") ? "^" : ""
	m_alt_state := GetKeyState("LAlt", "P") ? "!" : ""
	m_shift_state := GetKeyState("Shift") ? "+" : ""
	m_modifier_prefix := m_ctrl_state . m_alt_state . m_shift_state . p_key
	SendInput, %m_modifier_prefix%

	return
}

;==========================
;Function Keys Modifiers
;==========================
*<#1::f_SendInputMF("{F1}")
*<#2::f_SendInputMF("{F2}")
*<#3::f_SendInputMF("{F3}")
*<#4::f_SendInputMF("{F4}")
*<#5::f_SendInputMF("{F5}")
*<#6::f_SendInputMF("{F6}")
*<#7::f_SendInputMF("{F7}")
*<#8::f_SendInputMF("{F8}")
*<#9::f_SendInputMF("{F9}")
*<#0::f_SendInputMF("{F10}")
*<#-::f_SendInputMF("{F11}")
*<#=::f_SendInputMF("{F12}")
<#Backspace::f_SendInputMF("{DEL}")

<!<#::MsgBox "Worked"
;==========================
;Ctrl Alt Delete
;==========================
^!Backspace::
run, Taskmgr.exe
return

$^x::f_EmacsInputCommand("^x")
$^s::SendCommand("^s", "^f")
;==========================
;Emacs mode toggle
;==========================

CapsLock::
+CapsLock::
!CapsLock::
^CapsLock::
#CapsLock::
AppsKey::
  SetEmacsMode(!IsInEmacsMode)
return

;==========================
;Character navigation
;==========================

$^p::SendCommand("^p","{Up}")

$^n::SendCommand("^n","{Down}")

$^f::SendCommand("^f","{Right}")

$^b::SendCommand("^b","{Left}")

;==========================
;Word Navigation
;==========================

$!p::SendCommand("!p","^{Up}")

$!n::SendCommand("!n","^{Down}")

$!f::SendCommand("!f","^{Right}")

$!b::SendCommand("!b","^{Left}")

;==========================
;Line Navigation
;==========================

$^a::SendCommand("^a","{Home}")

$^e::SendCommand("^e","{End}")

;==========================
;Page Navigation
;==========================

;Ctrl-V disabled. Too reliant on that for pasting :$
;$^v::SendCommand("^v","{PgDn}")
;$!v::SendCommand("!v","{PgUp}")

$!<::SendCommand("!<","^{Home}")

$!>::SendCommand("!>","^{End}")

;==========================
;Undo
;==========================

$^/::SendCommand("^/","^z")

;==========================
;Killing and Deleting
;==========================

$^d::SendCommand("^d","{Delete}")

$!d::SendCommand("!d","^+{Right}","{Delete}")

$!Delete::SendCommand("!{Del}","^+{Left}","{Del}")

$^k::SendCommand("^k","+{End}","{Delete}")

$^w::SendCommand("^w","+{Delete}","{Shift Up}") ;cut region

$!w::SendCommand("!w","^{Insert}","{Shift Up}") ;copy region

$^y::SendCommand("^y","+{Insert}") ;paste

;==========================
;Cancel
;==========================
$^g::SendCommand("^g","{ESC}")
