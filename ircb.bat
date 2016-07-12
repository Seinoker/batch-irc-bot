@echo off
::run this with nc -vv -e ircb.bat <host> <port>
::@chcp 65001
::utf8
setlocal EnableDelayedExpansion
set "botnick=<nick>"
set "botusername=<nick>"
set "severpass=<nick>"
set "nickservpass="
set "channel=<channel>"
set "authbase64=<base64>"
::botnick+nul+botusername+nul+password
::end of config

echo CAP REQ :sasl
echo NICK !botnick!
echo USER !botusername! 8 * :BatchIRCbot
ping -n 3 localhost > nul
echo AUTHENTICATE PLAIN
ping -n 2 localhost > nul
echo AUTHENTICATE !authbase64!
ping -n 2 localhost > nul
echo CAP END
ping -n 2 localhost > nul
echo JOIN !channel!
ping -n 4 localhost > nul
set stdin=":foo!~foo@bar NOTPRIVMSG #channel :foobar
::" to escape special char
:endless_loop
set /p stdin=
::recieve input
echo !stdin! > con
::redirect raw log to console
:: :foo!~foo@bar PRIVMSG #foochannel :foobar message
:: 1             2      3            *
for /f "tokens=1,2,3,*" %%a in ("!stdin!") do (
    set "msg_source=%%c"
    if "%%a"=="PING" echo PONG %%b & goto endfor
	if NOT "%%b"=="PRIVMSG" goto endfor
    if NOT "%%c"=="!channel!" goto endfor
    ::start parsing username
    for /f "tokens=1,2,* delims=:!~@" %%u in ("%%a") do ( :: get nick, realname, hostname
        set "msg_nick=%%u"
		set "msg_realname=%%v"
		set "msg_hostname=%%w"
	)
	set msg="%%d
	:: " to escape special character 
	set msg=!msg:~2!
	:: cut the character ":
	call :solvemsg
	goto endfor
	)
:endfor

goto endless_loop

echo -----DISCONNECTED-----
goto :eof

::functions

:solvemsg
if "!msg_nick!"=="!botnick!" goto :eof
::ignore itself
if "!msg_nick:~-3!"=="bot" goto :eof
::ignore user with bot suffix
if /i "!msg!"=="ping" call :say !msg_source! "pong...的說^!" & goto :eof
::channel pong

goto :eof


:say
echo PRIVMSG %~1 :%~2
goto :eof


::Variables:
:: !msg_nick!
:: !msg_realname!
:: !msg_hostname!
:: !msg_source!
