B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  Forum / sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/30/2022
#End Region

Sub Class_Globals
End Sub

Public Sub Initialize
End Sub


Public Sub GetInfo() As Map 
	
	Dim m As Map, p As Phone, os As OperatingSystem
	m.Initialize
	os.Initialize("")
	
	Try
		
		m.Put("Manufacturer",p.Manufacturer)
		m.Put("Model",p.Model)
		m.Put("Product",p.Product)
		m.Put("SDK",p.SdkVersion)
	
		m.Put("Total internal memory size (MB)", Round2(os.TotalInternalMemorySize/(1024*1024),0))
		m.Put("Available internal memory (MB)", Round2(os.AvailableInternalMemorySize/(1024*1024),0))
		m.Put("Total external memory size (MB)", Round2(os.TotalExternalMemorySize/(1024*1024),0))
		m.Put("External memory available", os.externalMemoryAvailable)
	
		m.Put("Display logical density (DPI)", os.densityDpi)
		m.Put("Font scaled density", os.scaledDensity)
		m.Put("Screen width (pixels)", os.widthPixels)
		m.Put("Screen height (pixels)", os.heightPixels)
		m.Put("Pixels per inch (x-direction)", Round2(os.xdpi,0))
		m.Put("Pixels per inch (y-direction)", Round2(os.ydpi,0))
		m.Put("Physical screen width (DPI*Pixels)", Round2(os.physicalScreenWidth,0))
		m.Put("Physical screen height (DPI*Pixels)", Round2(os.physicalScreenHeight,0))
		
		Dim CPU() As String : CPU = Regex.Split( CRLF,os.ReadCPUinfo)
		If CPU.Length > 2 Then 
			m.Put("CPU Information1", CPU(0))
			m.Put("CPU Information2", CPU(1))
		End If
		
	Catch
		Log(LastException)
	End Try
	
	Return m
	
End Sub


Public Sub GetInfo2() As B4XOrderedMap
	
	Dim m As Map = GetInfo
	Dim out As B4XOrderedMap : out.Initialize
	
	For Each theKey As Object In m.Keys
		out.Put(theKey,m.Get(theKey))
	Next
	
	Return out
	
End Sub


Public Sub ConvertMap2Str(m As Map) As String
	
	Dim s As StringBuilder : s.Initialize
	For Each theKey As Object In m.Keys
		s.Append(theKey).Append(":").Append(m.Get(theKey)).Append(CRLF)
	Next
	
	Return s.ToString
	
End Sub






