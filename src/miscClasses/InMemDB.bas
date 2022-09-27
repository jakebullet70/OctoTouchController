B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0	Sept/27/2022
#End Region

Sub Class_Globals
	Private Const mModule As String = "InMemDB" 'ignore
	Public sql As SQL
End Sub

Public Sub Initialize
	
	'--- init in memory DB
	sql.Initialize("", ":memory:", True) 
	BuildTable
	
End Sub

Public Sub BuildTable
	sql.ExecNonQuery("DROP TABLE IF EXISTS files;")
	sql.ExecNonQuery("CREATE TABLE files(file_name TEXT,hash TEXT,date_added TEXT);")
End Sub

Public Sub SeedTable(fm As Map)
	sql.BeginTransaction
	For Each f As tOctoFileInfo In fm.Values
		InsertFileRec(f.Name,f.hash,f.Date)
	Next
	sql.TransactionSuccessful
	sql.EndTransaction
End Sub

Public Sub InsertFileRec(fname As String,hash As String,date_added As String)
	
	sql.ExecNonQuery($"INSERT INTO FILES ('file_name','hash','date_added') 
										  VALUES ("${fname}","${hash}","${date_added}");"$)
End Sub

Public Sub GetTotalRecs() As Int
	Return sql.ExecQuerySingleResult("Select COUNT(*) FROM files;").As(Int)
End Sub

Public Sub DeleteFileRec(fname As String)
	sql.ExecNonQuery($"DELETE FROM FILES WHERE file_name = "${fname}";"$)
End Sub

