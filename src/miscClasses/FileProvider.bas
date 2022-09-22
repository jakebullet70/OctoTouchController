B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
'v1.00
Sub Class_Globals
	Public SharedFolder As String
	Public UseFileProvider As Boolean
	Private rp As RuntimePermissions
End Sub

Public Sub Initialize
	Dim p As Phone
	If p.SdkVersion >= 24 Or File.ExternalWritable = False Then
		UseFileProvider = True
		SharedFolder = File.Combine(File.DirInternal, "shared")
		File.MakeDir("", SharedFolder)
	Else
		UseFileProvider = False
		SharedFolder = rp.GetSafeDirDefaultExternal("shared")
	End If
	Log($"Using FileProvider? ${UseFileProvider}"$)
End Sub

'Returns the file uri.
Public Sub GetFileUri (FileName As String) As Object
	
	If UseFileProvider = False Then
		Dim uri As JavaObject
		Return uri.InitializeStatic("android.net.Uri").RunMethod("parse", Array("file://" & File.Combine(SharedFolder, FileName)))
	Else
		Dim f As JavaObject
		f.InitializeNewInstance("java.io.File", Array(SharedFolder, FileName))
		Dim fp As JavaObject
		Dim context As JavaObject
		context.InitializeContext
		fp.InitializeStatic("android.support.v4.content.FileProvider")
		Return fp.RunMethod("getUriForFile", Array(context, Application.PackageName & ".provider", f))
	End If
End Sub

'Replaces the intent Data field with the file uri.
'Resets the type field. Make sure to call Intent.SetType after calling this method
Public Sub SetFileUriAsIntentData (Intent As Intent, FileName As String)
	Dim jo As JavaObject = Intent
	jo.RunMethod("setData", Array(GetFileUri(FileName)))
	Intent.Flags = Bit.Or(Intent.Flags, 1) 'FLAG_GRANT_READ_URI_PERMISSION
End Sub