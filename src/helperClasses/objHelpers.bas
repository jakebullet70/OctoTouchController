B4J=true
Group=HELPERS
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
'Static code module
Sub Process_Globals
	Private Const mModule As String = "objHelper" 'ignore
End Sub


public Sub Map2Json(m As Map) As String
	
	Dim gen As JSONGenerator
	gen.Initialize(m)
	Return gen.ToString
	
End Sub

public Sub List2Json(lst As List) As String
	
	Dim gen As JSONGenerator
	gen.Initialize2(lst)
	Return gen.ToString
	
End Sub

'Convert a map into a list
'if KeyList = True, then return a list of keys, otherwise a list of values
public Sub Map2List(myMap As Map, KeyList As Boolean) As List
	Dim lst As List : lst.Initialize
	If KeyList Then
		For Each item As Object In myMap.Keys
			lst.Add(item)
		Next
	Else
		For Each item As Object In myMap.Values
			lst.Add(item)
		Next
	End If
	Return lst
End Sub


Public Sub CopyMap(original As Map) As Map 'ignore
	Dim m As Map : m.Initialize
	For Each k As Object In original.Keys
		m.Put(k, original.Get(k))
	Next
	Return m
End Sub


Public Sub ConcatMaps(maps() As Map) As Map 'ignore
	Dim retMap As Map : retMap.Initialize
	For Each m As Map In maps
		For Each k As Object In m.Keys
			retMap.Put(k, m.Get(k))
		Next
	Next
	Return retMap
End Sub






