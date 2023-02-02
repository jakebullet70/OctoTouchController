B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Feb/02/2023
#End Region

Sub Class_Globals
   	Private data As List
End Sub

Public Sub getSize() As Int '--- property
	Return data.Size
End Sub

Public Sub Initialize
   	data.Initialize
End Sub

Public Sub Push(o As Object)
   	data.Add(o)
End Sub

Public Sub Pop() As Object
   	Dim o As Object = data.Get(data.Size - 1)
   	data.RemoveAt(data.Size - 1)
   	Return o
End Sub

Public Sub Peak() As Object
   	Return data.Get(data.Size - 1)
End Sub

Public Sub Clear
	data.Initialize
End Sub

