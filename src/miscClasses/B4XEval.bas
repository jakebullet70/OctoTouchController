B4J=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.83
@EndOfDesignText@
'version 2.01
#Event: Function(Name As String, Values As List) As Double
Sub Class_Globals
	Private Const NUMBER_TYPE = 1, OPERATOR_TYPE = 2 As Int
	Type ParsedNode (Operator As String, Left As ParsedNode, Right As ParsedNode, _
		NodeType As Int, Value As Double)
	Type OrderData (Index As Int, Level As Int, Added As Int)
	Private root As ParsedNode
	Private ParseIndex As Int
	Private Nodes As List
	Private OperatorLevel As Map
	Public Error As Boolean
	Private mCallback As Object
	Private mEventName As String
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mCallback = Callback
	mEventName = EventName
	OperatorLevel = CreateMap("+": 1, "-": 1, "*":2, "/": 2)
End Sub

Public Sub Eval(Expression As String) As Double
	Error = False
	Expression = Expression.Replace(" ", "").ToLowerCase.Replace("-(", "-1*(")
	Return EvalHelper(Expression)
End Sub

Private Sub PrepareExpression(expr As String) As String
	Dim m As Matcher = Regex.Matcher("(\w*)\(", expr)
	Dim sb As StringBuilder
	sb.Initialize
	Dim lastMatchEnd As Int = 0
	Do While m.Find
		Dim currentStart As Int = m.GetStart(0)
		If currentStart < lastMatchEnd Then Continue
		sb.Append(expr.SubString2(lastMatchEnd, currentStart))
		Dim functionCall As Boolean
		Dim args As List
		If m.Match.Length > 1 Then
			args.Initialize
			functionCall = True
		End If
		Dim level As Int
		Dim start As Int = m.GetEnd(0)
		For i = start To expr.Length - 1
			If expr.CharAt(i) = "(" Then
				level = level + 1
			Else if expr.CharAt(i) = "," And level = 0 Then
				args.Add(CalcSubExpression(expr.SubString2(start, i)))
				start = i + 1
			Else if expr.CharAt(i) = ")" Then
				level = level - 1
				If level = -1 Then
					Dim d As Double = CalcSubExpression(expr.SubString2(start, i))
					If functionCall Then
						args.Add(d)
						d = CallSub3(mCallback, mEventName & "_Function", m.Match.SubString2(0, m.Match.Length - 1), args)
					End If
					sb.Append(NumberFormat2(d, 1, 15, 0, False))
					lastMatchEnd = i + 1
					Exit
				End If
			End If
		Next
	Loop
	If lastMatchEnd < expr.Length Then sb.Append(expr.SubString(lastMatchEnd))
	Return sb.ToString 
End Sub

Private Sub CalcSubExpression (expr As String) As Double
	Dim be As B4XEval
	be.Initialize (mCallback, mEventName)
	Dim d As Double = be.EvalHelper(expr)
	If be.Error Then
		Error = True
		Return 0
	End If
	Return d
End Sub

'only evaluates numbers and operators. No functions or parenthesis here.
Private Sub EvalHelper (expr As String) As Double
	'Log("Expr: " & expr)
	ParseIndex = 0
	Dim root As ParsedNode
	root.Initialize
	expr = PrepareExpression(expr)
	If Error Then Return 0
	Dim m As Matcher = Regex.Matcher("[\.\d]+", expr)
	Nodes.Initialize
	Dim lastIndex As Int = 0
	Dim currentOrderData As OrderData
	currentOrderData.Initialize
	Nodes.Add(CreateOperatorNode("("))
	Do While m.Find
		Dim Operator As String = expr.SubString2(lastIndex, m.GetStart(0))
		Dim rawNumber As String = m.Match
		If Operator.EndsWith("-") Then
			Dim lastNode As ParsedNode = Nodes.Get(Nodes.Size - 1)
			If lastNode.Operator = "(" Or Operator.Length > 1 Then 
			'handle negative numbers: (-2 + 1, 1/-2
				Operator = Operator.SubString2(0, Operator.Length - 1)
				rawNumber = "-" & rawNumber
			End If
		End If
		lastIndex = m.GetEnd(0)
		If Operator.Length > 0 Then
			Dim level As Int = OperatorLevel.Get(Operator)
			If currentOrderData.Level > 0 Then
				If currentOrderData.Level < level Then
					Nodes.InsertAt(currentOrderData.Index, CreateOperatorNode("("))
					currentOrderData.Added = currentOrderData.Added + 1
				Else if currentOrderData.Level > level Then
					If currentOrderData.Added > 0 Then
						Nodes.Add(CreateOperatorNode(")"))
						currentOrderData.Added = currentOrderData.Added - 1 
					End If
				End If
			End If
			currentOrderData.Level = level
			currentOrderData.Index = Nodes.Size + 1
			Nodes.Add(CreateOperatorNode(Operator))
		End If
		Dim d As Double = rawNumber
		Nodes.Add(CreateNumberNode(d))
	Loop
	For i = 1 To currentOrderData.Added
		Nodes.Add(CreateOperatorNode(")"))
	Next
	Nodes.Add(CreateOperatorNode(")"))
	root = BuildTree
	Return EvalNode(root)
End Sub

private Sub BuildTree As ParsedNode
	Dim rt As ParsedNode
	Do While ParseIndex < Nodes.Size
		Dim pn As ParsedNode = TakeNextNode
		Dim built As Boolean
		If pn.Operator = ")" Then 
			Exit
		Else If pn.Operator = "(" Then 
			pn = BuildTree
			built = True
		End If
		If pn.NodeType = NUMBER_TYPE Or built Then
			If rt.IsInitialized Then
				rt.Right = pn
			Else
				rt = pn
			End If
		Else if pn.NodeType = OPERATOR_TYPE Then
			pn.Left = rt
			rt = pn
		End If
	Loop
	If rt.IsInitialized = False Then rt = pn
	Return rt
End Sub

Private Sub EvalNode (pn As ParsedNode) As Double
	If pn.NodeType = NUMBER_TYPE Then Return pn.Value
	Dim left As Double = EvalNode(pn.Left)
	Dim right As Double = EvalNode(pn.Right)
	Select pn.Operator
		Case "+"
			Return left + right
		Case "-"
			Return left - right
		Case "*"
			Return left * right
		Case "/"
			Return left / right
		Case Else
			Log("Syntax error: " & pn.Operator)
			Return "error"
	End Select
End Sub

private Sub TakeNextNode As ParsedNode
	Dim pn As ParsedNode = Nodes.Get(ParseIndex)
	ParseIndex = ParseIndex + 1
	Return pn
End Sub

Private Sub CreateOperatorNode(operator As String) As ParsedNode
	Dim pn As ParsedNode
	pn.Initialize
	pn.NodeType = OPERATOR_TYPE
	pn.Operator = operator
	Return pn
End Sub

Private Sub CreateNumberNode (d As Double) As ParsedNode
	Dim pn As ParsedNode
	pn.Initialize
	pn.NodeType = NUMBER_TYPE
	pn.Value = d
	Return pn
End Sub
