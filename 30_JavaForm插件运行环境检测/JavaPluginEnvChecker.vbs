REM "=================================================================="
REM ' Oracle ERP 11i/R12 中的Form打开时需要调用jre的插件同时该插件需要进'
REM ' 行一些环境设置,本程序即为展示这些参数，方便检查'
REM ' '
REM ' 声明:以下程序中部分代码片段取自网络，如果有版本争议，本人可清理'
REM ' freeya at 2020-11-23 19:17 '
REM "==================================================="
FMSChar = "FMSAPP"
REG_FILE="d:\reg.log"
strComputer = "."
outmsg="OracleERP 运行环境检查"&VBCR
outmsg= outmsg & "--------------------------"&VBCR
outmsg= outmsg & "1.操作系统" &VBCR
Dim WshShell
Set WshShell = CreateObject("WScript.Shell")

'======================================================================
'   操作系统位数   '
'======================================================================
For Each objOS in GetObject( _
    "winmgmts:").InstancesOf ("Win32_OperatingSystem")
outmsg=outmsg& "=" & objOS.Caption & "Version = " & objOS.Version &VBCR _
           & "=" & objOS.RegisteredUser        
Next
 
OsType = WshShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")
 outmsg=outmsg &VBCR
If OsType = "x86" then
outmsg=outmsg& "="& "Windows 32bit system detected" 
elseif OsType = "AMD64" then
outmsg=outmsg&"="& "Windows 64bit system detected" 
end if

'======================================================================
'   IE版本信息   '
'======================================================================
outmsg=outmsg &VBCR
Dim name
Set name=WScript.CreateObject("WScript.Shell")
Dim ComputerName,RegPath
' RegPath="HKLM\System\CurrentControlSet\Control\ComputerName\ComputerName\ComputerName"
RegPath="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\svcVersion"
iechar=name.RegRead(RegPath)
RegPath="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\svcUpdateVersion"
iechar = iechar + "  UpdateVer:" &name.RegRead(RegPath)
RegPath="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\svcKBNumber"
iechar = iechar + " >" &name.RegRead(RegPath)
outmsg=outmsg&"=IE版本=" & iechar&VBCR

' Dim WshShell, oExec
' Set WshShell = WScript.CreateObject("WScript.Shell") 
' Set oExec = shell.Exec("reg query ""HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\xx.com"" >d:\reg.log")
' xx.com 为指定公司的域名,根据需要进行修改
WshShell.Run "cmd /c reg query "&Chr(34)&"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\xx.com"&Chr(34)&" >d:\reg.log",0,true 
' x = oExec.StdOut.ReadLine
Set fso  = CreateObject("Scripting.FileSystemObject")
If fso.FileExists(REG_FILE) Then
  Set objFile = fso.GetFile(REG_FILE)
  if objFile.Size > 0 then 
    Set file = fso.OpenTextFile(REG_FILE, 1) 
    regsite = file.ReadAll
    file.Close 
    regsite = Replace( regsite , "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\"," ")
  else
      regsite = " ***无法获取注册表信息或未添加可信站点,请人工核实***"  &VBCR
  end if
else
  regsite = "未查询到记录,请手工查询" &VBCR
end if
WshShell.Run "cmd /c del d:\reg.log"
outmsg= outmsg  &"=IE信任站点:"
outmsg= outmsg &regsite

'======================================================================
'   安装的程序列表   '
'======================================================================
outmsg= outmsg &VBCR
outmsg= outmsg & "2.安装的Java程序列表" &VBCR
outmsg=outmsg&"------------------------"
Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE
strComputer = "."
strKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
strEntry1a = "DisplayName"
strEntry1b = "QuietDisplayName"
strEntry2 = "InstallDate"
strEntry3 = "VersionMajor"
strEntry4 = "VersionMinor"
strEntry5 = "EstimatedSize"

Set objReg = GetObject("winmgmts://" & strComputer & _
 "/root/default:StdRegProv")
objReg.EnumKey HKLM, strKey, arrSubkeys
' WScript.Echo "Installed Applications" & VbCrLf
' outmsg=outmsg&"Installed Applications" & VbCrLf
softList=""
For Each strSubkey In arrSubkeys
    intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey, _
strEntry1a, strValue1)
If intRet1 <> 0 Then
objReg.GetStringValue HKLM, strKey & strSubkey, _
strEntry1b, strValue1
End If
If left(strValue1,4) = "Java" then 
If strValue1 <> "" Then
softList = softList & ">>" & strValue1
' WScript.Echo VbCrLf & "Display Name: " & strValue1
End If
objReg.GetStringValue HKLM, strKey & strSubkey, _
strEntry2, strValue2
If strValue2 <> "" Then
softList = softList & " Date: " & strValue2
' WScript.Echo "Install Date: " & strValue2
End If
objReg.GetDWORDValue HKLM, strKey & strSubkey, _
strEntry3, intValue3
objReg.GetDWORDValue HKLM, strKey & strSubkey, _
strEntry4, intValue4
' If intValue3 <> "" Then
' softList = softList & "Version: " & intValue3 & "." & intValue4
' WScript.Echo "Version: " & intValue3 & "." & intValue4
' End If
objReg.GetDWORDValue HKLM, strKey & strSubkey, _
strEntry5, intValue5
If intValue5 <> "" Then
softList = softList & " Size: " & Round(intValue5/1024, 3) & " M"
' WScript.Echo "Estimated Size: " & Round(intValue5/1024, 3) & " megabytes"
End If 
softList = softList & VBCR
end if
Next
outmsg = outmsg & VBCR & softList
'======================================================================
'   读取Host   '
'======================================================================
outmsg= outmsg &VBCR
outmsg= outmsg & "3."&FMSChar&" 环境Host配置检查" &VBCR
outmsg=outmsg&"------------------------"
Dim fileRead
  Dim FSO
  Set FSO = CreateObject("Scripting.FileSystemObject")
  ' Set WshShell = CreateObject("WScript.Shell")
  WinDir =WshShell.ExpandEnvironmentStrings("%WinDir%")
  HostsFile = WinDir & "\System32\Drivers\etc\Hosts"
'   Wscript.Echo HostsFile
  Set fileRead = FSO.OpenTextFile(HostsFile)
  Dim strContent
  strContent = fileRead.ReadAll()
'   Wscript.Echo strContent
  fileRead.Close
  Dim ArrayLine
  line=""
  ArrayLine = Split(strContent, vbCrlf, -1, 1)
  Dim i
  Dim strArrayEachLine
  For i = 0 To UBound(ArrayLine)
    ArrayLine(i) = Trim(ArrayLine(i))
    If Not Left(ArrayLine(i), 1) = "#" Then
        if instr(Ucase(ArrayLine(i)) , FMSChar) > 0 then 
            line = line & ArrayLine(i) &VBCR
        end if
    End If
  Next
  outmsg = outmsg & VBCR &line

'======================================================================
'   java例外站点   '
'======================================================================
 outmsg= outmsg &VBCR
 outmsg= outmsg & "4.Java安全性例外站点" &VBCR
 outmsg=outmsg&"------------------------"
  'Dim fileRead
  'Dim FSO
  Set FSO = CreateObject("Scripting.FileSystemObject")
  ' Set WshShell = CreateObject("WScript.Shell")
  WinDir =WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
  exceptionFile = WinDir & "\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"
  roamingFile = WinDir & "\AppData\Roaming\Sun\Java\Deployment\security\exception.sites"
  If FSO.FileExists(exceptionFile) Then 
    Set fileRead = FSO.OpenTextFile(exceptionFile)
    strContent = fileRead.ReadAll()
    outmsg = outmsg & VBCR &strContent 
  elseif FSO.FileExists(roamingFile) then 
      Set fileRead = FSO.OpenTextFile(roamingFile)
      strContent = fileRead.ReadAll()
      outmsg = outmsg & VBCR &strContent
  else
     outmsg = outmsg & VBCR & " 未找到 例外站点文件"
  end if

'======================================================================
'   最终输出   '
'======================================================================
Wscript.Echo outmsg 
