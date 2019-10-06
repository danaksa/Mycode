Attribute VB_Name = "CalcInteropModule1"
Private calc As Object
Private ei As Object
'������ ������'
Public Function getversion() As String
    getversion = 47
End Function
'���������� ����� ������� �� ������� �������������� �� ���� 17216
Public Function CalcClassChist2(index As Double)
    CalcClassChist2 = GetEI().GetCalculations().CalcClassChist2(index)
End Function
'������������
Public Function Interpol(x As Double, x1 As Double, y1 As Double, x2 As Double, y2 As Double)
    Interpol = GetEI().Interpol(x, x1, y1, x2, y2)
End Function
'��������� ����� �� ������������ ���������� �������� ����, n - �����, Nznach - ���������� �������� ����'
Public Function OkrToZnach(n As String, Nznach As Integer)
    OkrToZnach = GetEI().GetCalculations().OkrToZnach(n, Nznach)
End Function
'������ ������ �� ������ ���������� ��� ���� 11382, docid - ���� ��������� � ������� ��� �������, x - ����������'
Public Function CalcVolume(docid As String, x As Double) As Double
    CalcVolume = GetEI().GetCalculations().CalcVolume(docid, x)
End Function
'��������� ����� �� ������������ ���������� �������� ����, Val - �����, Count - ���������� �������� ����'
'�� �������� �� ������ ������'
Public Function Substring(Val As String, count As Integer)
    Substring = GetEI().GetCalculations().Substring(Val, count, count)
End Function
'���������� �� ������ ����� ��� ����� ��������� �������� ���������� ���������� �� ����� ���������; ���������: batchno- ����� �����, key - ���� (��� ����� ���� ���� �������, ��������� �������, �����������, ���������� � �.�. �� ���������� ���������)'
Public Function getBatchDocByKey(batchno As String, key As String) As String
    getBatchDocByKey = GetWI().getBatchDocByKey(batchno, key)
End Function
'����������� ������ � ������ �������� �������� � ���������� ������� �������; str - ������, index - ����� �������� �������, delimeter - �����������'
Public Function SplitData(str As String, index As Long, delimeter As String) As String
    Dim a As Variant
    a = Split(str, delimeter)
    SplitData = a(index)
End Function
'���������� ���������� � ������� ���� �� ������ ���������; ���������: docid - ����� ���������, key - ����, defval - ������ ����'
Public Function getDocMetadataAsDate(docid As String, key As String, defval As Date) As Date
    getDocMetadataAsDate = tryToDate(GetBatchMetaData(docid, docid, key), defval)
End Function
'���������� ���������� � ������� �����; ���������: docid - ����� ���������, batchno - ����� �����, key - ����, defval - �������� �� ���������'
Public Function getBatchMetadataAsDouble(docid As String, batchno As String, key As String, defval As Double) As Double
    getBatchMetadataAsDouble = tryToNumber(GetBatchMetaData(docid, batchno, key), defval)
End Function
'���������� ���������� � ������� ����� �� ������ ���������; ���������: docid - ����� ���������, key - ����, defval - �������� �� ���������'
Public Function getDocBatchMetadataAsDouble(docid As String, key As String, defval As Double) As Double
    getDocBatchMetadataAsDouble = getBatchMetadataAsDouble(SplitData(docid, 0, "|"), SplitData(docid, 1, "|"), key, defval)
End Function
'���������� ���������� � ������� ����� �� ������ ���������; ���������: docid - ����� ���������, key - ����, defval - �������� �� ���������'
Public Function getDocMetadataAsDouble(docid As String, key As String, defval As Double) As Double
    getDocMetadataAsDouble = tryToNumber(GetBatchMetaData(docid, docid, key), defval)
End Function
'���������� ���������� �� ���� ������; ���������: docid - ����� ���������, batchno - ����� �����, key - ����'
Public Function GetBatchMetaData(docid As String, batchno As String, key As String) As String
    GetBatchMetaData = GetEI().GetCalculations().GetBatchMetaData(docid, batchno, key)
End Function
'���������� ������ ����������� �� �����; ���������: batchno - ����� �����
Public Function GetTestNamesByBatchNo(batchno As String) As String
    GetTestNamesByBatchNo = GetWI().GetTestNamesByBatchNo(batchno)
End Function
'���������� ���������� ��� ������� � ���������� �����������; ���������: dodcid - ����� ���������, batchno - ����� �����, key - ����, methodname - ��� ������, testname - ��� ����������, opr - ����� ����������� (� ������� 1��� � 2���)'
Public Function GetBatchMDtoMultiMethod(docid As String, batchno As String, key As String, methodname As String, testname As String, opr As String) As String
    GetBatchMDtoMultiMethod = GetEI().GetCalculations().GetBatchMDtoMultiMethod(docid, batchno, key, methodname, testname, opr)
End Function
'���������� �������� ���������� ���������; ���������: docid - ����� ���������, batchno - ����� �����, key - ����, methodname - ��� ������, testname - ��� ����������, opr - ����� �����������, kuv - ������� ������'
Public Function GetBatcOptPtoMultiMethod(docid As String, batchno As String, key As String, methodname As String, testname As String, opr As String, kuv As String) As String
    GetBatcOptPtoMultiMethod = GetEI().GetCalculations().GetBatcOptPtoMultiMethod(docid, batchno, key, methodname, testname, opr, kuv)
End Function
'���������� ���������� �� �����; docbatchid - ���� ��������� � �����, ����������� �������� |, key - ����'
Public Function GetDocBatchMetaData(docbatchid As String, key As String) As String
    GetDocBatchMetaData = GetEI().GetCalculations().GetDocBatchMetaData(docbatchid, key)
End Function
'����������� ���� �� �������� ������� � ������ ����; ���������: strdate - ���� � ��������� �������; defdateval - ��������, ��������� �� ���������'
Public Function tryToDate(strdate As String, defdateval As Date) As Date
    tryToDate = GetEI().GetCalculations().tryToDate(strdate, defdateval)
End Function
'���������� ���� � ��������� �������; ���������: str - ���� � ��������� �������, format - ������ ����'
Public Function tryToDateStr(str As String, format As String) As String
    tryToDateStr = GetEI().GetCalculations().tryToDateStr(str, format)
End Function
'���������� �����; ���������: strnum - ����� � ��������� �������, defnnum - �������� �� ���������'
Public Function tryToNumber(strnum As String, defnumber As Double) As Double
    tryToNumber = GetEI().GetCalculations().tryToNumber(strnum, defnumber)
End Function
'���������� ������; strnum - ����� � ��������� �������������, � - ������, ������������ ����� �� ������� ������������� ������ � �����'
Public Function trytodigit(strnum As String, C As String) As Variant
    trytodigit = GetEI().GetCalculations().trytodigit(strnum, C)
End Function
'������� ��������� ��������� ���� �����; ���������: r - ����� 1, rk - ����� 2, strformat - ������ ����� � ��������� �������������'
Public Function nervo(r As Double, rk As Double, strformat As String) As String
    nervo = GetEI().GetCalculations().nervo(r, rk, strformat)
End Function
'���������� ����������������, ����������� �� ��'
Public Function RoundNeopr(str As String) As String
    RoundNeopr = GetEI().GetCalculations().RoundNeopr(str)
End Function
'���������� ���������������, ����������� �� ���� 31371.7'
Public Function RoundNeoprGOSTGas(str As String) As String
    RoundNeoprGOSTGas = GetEI().GetCalculations().RoundNeoprGOSTGas(str)
End Function
'���������� ���� � ����� ������ �����; ���������: dodcid - ����� ���������, batchno - ����� �����, includeTime - ���������� ����� ��� ���'
Public Function ��������������������(docid As String, batchno As String, includeTime As Boolean) As String
    �������������������� = GetEI().GetCalculations().BatchSamplingDateTime(docid, batchno, includeTime)
End Function
'���������� ���� � ����� ������� �����; batchno - ����� �����'
Public Function ���������������������(batchno As String) As String
    ��������������������� = GetEI().GetCalculations().GetDateOfAnalysis(batchno)
End Function
'���������� ��������� ����������� �� �����������, ���� �� ������ �����������, �� ��������� �� ���������� ������ ����� �������: resvalue - ���������, pogrvalue - �����������, precstring - ��������'
Public Function GetResultString(resvalue As String, pogrvalue As String, precstring As String) As String
    GetResultString = GetEI().GetCalculations().GetResultString(resvalue, pogrvalue, precstring)
End Function
'���������� �������� ���������� � �������� ������� � ������ ����������� � ���������� ������ ����� �������; resvalue - ���������, pogrvalue - �����������, precstring - ��������'
Public Function GetResultDigit(resvalue As String, pogrvalue As String, precstring As String) As Variant
    GetResultDigit = GetEI().GetCalculations().GetResultDigit(resvalue, pogrvalue, precstring)
End Function
'���������� ��������� � ������� ���������  ���� ����� �����������; resvalue - ���������, pogrvalue - �����������, precstring - ���������� ������ � ������� 0.000'
Public Function GetResultWithPogr(resvalue As String, pogrvalue As String, precstring As String) As String
    GetResultWithPogr = GetEI().GetCalculations().GetResultWithPogr(resvalue, pogrvalue, precstring)
End Function
'���������� ����� �����; docid - ����� ���������,batchno - ����� ����� '
Public Function GetProbNum(docid As String, batchno As String) As String
    ProbNum = GetEI().GetCalculations().GetBatchMetaData(docid, batchno, "����� �����")
    If ProbNum = "" Then
        GetProbNum = GetEI().GetCalculations().GetBatchMetaData(docid, batchno, "���� (�����) �����")
    Else
        GetProbNum = ProbNum
    End If
End Function
'���������� �������; r - ������ � ������������'
Public Function GetFormula(r As Range) As String
    GetFormula = GetEI().GetCalculations().GetFormuls(r)
End Function
'�������� �� Range �� ������� ��������� � �������� ��� ���������� ������ �� ����, �������� �� ������ ����������'
Public Function SumDistinctStringsRange(r As Range, delimetr As String) As String
Dim result As String
result = GetEI().GetCalculations().SumDistinctStringsRange(r, delimetr)
If result = "-2146826273" Then
    SumDistinctStringsRange = "�"
Else
    SumDistinctStringsRange = result
End If
End Function
'���������� ���� ��������� � ���������� ��� ���������; ZavNumber - ��������� �����, ToDate - ����, �� ������� ����� ������������� ����� ���������'
Public Function GetBarPopDocId(ZavNumber As String, ToDate As String, r As Range) As String
    GetBarPopDocId = GetEI().GetBarPopDocId(ZavNumber, ToDate, r)
End Function
'���������� ���� ��������� � ���������� ��� ����������; ZavNumber - ��������� �����, ToDate - ����, �� ������� ����� ������������� ����� ���������'
Public Function GetTempPopDocId(ZavNumber As String, ToDate As String, r As Range) As String
    GetTempPopDocId = GetEI().GetTempPopDocId(ZavNumber, ToDate, r)
End Function
'���������� �������� �������� ��� �����������; docid - ���� ��������� � ��������� ��� ����������, znach - �������� �����������'
Public Function GetPopr(docid As String, znach As Double) As Double
    GetPopr = GetEI().GetPopr(docid, znach)
End Function
'���������� �������� � ��������� ���������� �����; mesto - ����� ���������, lab - �����������, DateTo - ����, �� ������� ������, r - ����� ������ �� �����'
Public Function GetUslOkrDOc(mesto As String, lab As String, DateTo As String, r As Range) As String
    GetUslOkrDOc = GetEI().GetUslOkrDOc(mesto, lab, DateTo, r)
End Function
'������� ���� �����, str - ������ � ������, disp=true, ���� ���� ����� ��� �����������, ���� false, �� ���������'
Public Function RemoveIDStr(str As String, disp As Boolean) As String
    RemoveIDStr = GetWI().RemoveIDStr(str, disp)
End Function
'��������� ���� �����, str - ������ � ������, disp=true, ���� ���� ����� ��� �����������, ���� false, �� ���������'
Public Function GetIDFromStr(str As String, disp As Boolean) As String
    GetIDFromStr = GetWI().GetIDFromStr(str, disp)
End Function
'���������� ���� �������������� �������; r - ����� ������ �� �����, lab - �����������, kuveta1 - ������� ������ 1, optplotn1 - �������� ���������� ��������� 1-�� ������, kuveta2 - ������� ������ 2, optplotn2 - �������� ���������� ��������� 2-�� ������, prodnumber - ��������� ����� ���������, samplingplace - ����� ������'
Function GetCalibrGrafDocid(r As Range, lab As String, kuveta1 As String, optplotn1 As String, kuveta2 As String, optplotn2 As String, prodnumber As String, samplingplace As String, Optional test As String = "") As String
    GetCalibrGrafDocid = GetEI().GetCalculations().GetCalibrGrafDocid(r, lab, kuveta1, optplotn1, kuveta2, optplotn2, prodnumber, samplingplace, test)
End Function
'���������� ����������� A �������������� �������; docid - ���� ��������� �������������� �������'
Function getcoefA(docid As String) As Variant
    If InStr(1, docid, "|") <> 0 Then
        getcoefA = getBatchMetadataAsDouble(docid, docid, "����������� A", 0)
    Else
        getcoefA = ""
    End If
End Function
'���������� ����������� B �������������� �������; docid - ���� ��������� �������������� �������'
Function getcoefB(docid As String) As Variant
    If InStr(1, docid, "|") <> 0 Then
        getcoefB = getBatchMetadataAsDouble(docid, docid, "����������� B", 1)
    Else
        getcoefB = ""
    End If
End Function
'���������� ������� ������  ��������� ���������� ���������; docid - ���� ��������� �������������� �������'
Function getKuveta(docid As String) As String
    getKuveta = GetBatchMetaData(docid, docid, "������")
End Function
'������������ ��� ������ ��������� ������� �����������, ���������� � �.�. � �������, ������� ����������� ��� ������ ��; r - �������� ��� ������ ������� ���������, what - ��� ������, searchcolindex - � ����� �������� ������, colindex - �� ������ �������� ����������'
Function GetWorkNumber(r As Range, what As String, Optional n As Long = 1, Optional searchcolindex As Long = 1, Optional colindex As Long = 2) As String
    GetWorkNumber = GetEI().GetCalculations().GetWorkNumber(r, what, n, searchcolindex, colindex)
End Function
'���������� ��� ���� �� ���������, r - ��������, what - ������ ��� ������, isInstr - ���������� ��� ���'
Function GetSomethingInRange(r As Range, what As String, isInstr As Boolean, n As Long, searchcolindex As Long, colindex As Long) As String
    GetSomethingInRange = GetEI().GetCalculations().GetSomethingInRange(r, what, isInstr, n, searchcolindex, colindex)
End Function
'������� ���������, �������� �����������, ��������� � �������� ������� � ���������� ������ �� ���������������, r - ����� ������ �� �����, lab - �����������, docdescription - ��� ���������, key1 - ���� 1, value1 - �������� 1, sortmetadataname - ��� ���������� ��� ����������, ���������� � �������� �������, DateTo - �� ����� ���� ������'
Function GetSomeDocidBeforeDate(r As Range, lab As String, docdescription As String, key1 As String, Value1 As String, sortmetadataname As String, DateTo As String) As String
    GetSomeDocidBeforeDate = GetEI().GetSomeDocidBeforeDateForCurUser(r, lab, docdescription, key1, Value1, sortmetadataname, DateTo)
End Function
'���������� ����������� ����������� �����; r - ����� ������ �� �����, num - ����� �����, lab - �����������, DateTo - ����, �� ������� ������������ �����'
Function GetKislKolbVmest(r As Range, num As String, lab As String, DateTo As String) As Variant
    GetKislKolbVmest = GetEI().GetKislKolbVmest(r, num, lab, DateTo)
End Function
'���������� ������������� �������� ����������; termdocid - ����� ��������� � ����������, temp - �����������'
Public Function GetTermTempPopr(termdocid As String, temp As Double) As Variant
    GetTermTempPopr = GetEI().GetPopr(termdocid, temp)
End Function
'���������� �������� ��������������� ��������; docid - ���� ��������� � ���������, davl - �������� ��������, temp - �����������'
Public Function GetBarPopr(docid As String, davl As Double, temp As Double) As Double
    GetBarPopr = GetEI().GetPopr(docid, davl)
End Function
'���������� ���� ��������� � ���������� ��� ����������; ZavNumber - ��������� ����� ����������, r - ����� ������ �� ����� , lab - �����������, DateTo - ����, �� ������� ������������ ����� ���������'
Public Function GetTermPoprDocId(ZavNumber As String, r As Range, lab As String, DateTo As String) As String
    GetTermPoprDocId = GetSomePovDocId("���������", ZavNumber, r, lab, DateTo)
End Function
'���� ��������� ��� ��������, what - ������ ������, ZavNumber - ��������� �����, r - �������� ��� ������, lab - �����������, DateTo - ����, �� ������� ������'
Public Function GetSomePovDocId(what As String, ZavNumber As String, r As Range, lab As String, DateTo As String) As String
   On Error Resume Next
    Application.Cursor = xlWait
    GetSomePovDocId = GetSomeDocidBeforeDate(r, lab, what, "��������� �����", CStr(ZavNumber), "���� �������", DateTo)
    Application.Cursor = xlDefault
End Function
'������� ��� ������ �� ���������� x � ������� tabledataformethods � Oracle - �������� ��������������� PL\SQL �������; x - ��������, description - �������� �������, notFoundValue - ��������, ��������� �� ���������'
Function TableFind(x As Double, description As String, notFoundValue As Double) As Double
On Error GoTo errorhandler
    Dim wi As Object
    Application.Cursor = xlWait
    Set wi = GetWI
    TableFind = wi.TableFind(description, x, notFoundValue)
errorhandler:
    Application.Cursor = xlDefault
End Function
'���������� ������������ ��������� �������� �� ���� ����������; x1 - �������� ��������� 1, x2 - �������� ��������� 2, description - �������� �������, notFoundValue - ��������,��������� �� ���������'
Function TableCalc(x1 As Double, x2 As Double, description As String, notFoundValue As Double) As Double
    On Error GoTo errorhandler
    Dim wi As Object
    Application.Cursor = xlWait
    Set wi = GetWI
    TableCalc = wi.TableCalc(description, x1, x2, notFoundValue)
errorhandler:
    Application.Cursor = xlDefault
End Function
'�� ���������� � �������� ���������� �������� ������� ���������; x1 - �������� ��������� 1, Y - ���������� 2, description - �������� �������, notFoundValue - ��������,��������� �� ���������'
Function TableCalcObr(x1 As Double, Y As Double, description As String, notFoundValue As Double) As Double
On Error GoTo errorhandler
    Dim wi As Object
    Application.Cursor = xlWait
    Set wi = GetWI
    TableCalcObr = wi.TableCalcObr(description, x1, Y, notFoundValue)
errorhandler:
    Application.Cursor = xlDefault
End Function
'���������� ��������� �������� ��������� �� ����������� � ��������; description - �������� �������, t - �����������, p - ��������'
Public Function DensCalc(description As String, t As Double, p As Double) As Double
    DensCalc = TableCalc(t, p, description, -999)
End Function
'���������� �������� �����������; description - �������� �������, t - �����������, p20 - �������� ��������� ��� 20'
Public Function DensCalcobr(description As String, t As Double, p20 As Double) As Double
    DensCalcobr = TableCalcObr(t, p20, description, -999)
End Function
'���������� ��������� �������� ��������� �� ����������� � ��������; description - �������� �������, t - �����������, p - �������� �� ������ �� 2153 ��� 20 ��������'
Public Function MI2153_20(description As String, t As Double, p As Double) As Double
    MI2153_20 = TableCalc(t, p, description, -999) '"�� 2153 ��. ��� 20 ��. 20 �1"
End Function
'���������� ��������� �������� ��������� �� ����������� � ��������; description - �������� �������, t - �����������, p - �������� �� ������ �� 2153 ��� 15 ��������'
Public Function MI2153_15(description As String, t As Double, p As Double) As Double
    MI2153_15 = TableCalc(t, p, description, -999) '"�� 2153 ��. ��� 15 ��. 20 �2"
End Function
'��. TableCalc'
Public Function GetCorrection(description As String, t As Double, p As Double) As Double
    GetCorrection = TableCalc(t, p, description, -999)
End Function
'���������� �������� ��� ������ �� 52.24.495; description - �������� �������, t - �������� �����������'
Function CalcPoprRD52_24_495(description As String, t As Double) As Double
    Dim vs As Double
    vs = TableCalc(t * 10 \ 10, t - t * 10 \ 10, description, -999)
    CalcPoprRD52_24_495 = -999999
    If vs <> -1 Then
        CalcPoprRD52_24_495 = vs
    End If
End Function
'���������� ��������� �������� �������� ��� ������ ��� � 14.1:2:3:4.123; ���������: description - �������� �������, t - �������� �����������'
Function CalcPoprPNDF_123(description As String, t As Double) As Double
    Dim vs As Double

    vs = TableCalc(t * 10 \ 10, t - t * 10 \ 10, description, -1)
    CalcPoprPNDF_123 = 1
    If vs <> -1 Then
        CalcPoprPNDF_123 = vs
    End If
End Function
'��. TableCalc'
Public Function getValueA(description As String, t As Double, p As Double) As Double
    Dim wi As Object
    Set wi = GetWI
    getValueA = wi.TableCalcInterval(description, p, t, -999999)
End Function
'��������� ����� ������� �����, description - �������� �������, razmer � count - ��������� ��� �������'
Function CalcClassChist(description As String, razmer As String, count As Double) As Variant
    Dim wi As Object
    Set wi = GetWI
    CalcClassChist = wi.TableCalcInterval(description, razmer, count, -999999)
End Function
'���������� �������� �������� ��� ������� �����;termdocid - ���� ��������� � ��������� �� ���������, zeropoint - ��������� ������� �����'
Function GetTermZeroPopr(termdocid As String, zeropoint As Variant) As Double
    Dim zero As Double
    zero = getBatchMetadataAsDouble(termdocid, termdocid, "���-� ������� �����", -999)
    If zero <> -999 And zeropoint <> "�� �����������" Then
        GetTermZeroPopr = zero - zeropoint
    Else
        GetTermZeroPopr = 0
    End If
End Function
'���������� �������� �� ��������; termdocid - ���� ��������� � ������������� ���������, davl - ��������, unit - ������� ��������� ��������'
Function GetTermAtmPopr(termdocid As String, davl As Double, unit As String) As Double
    Dim Be As Double
    Dim unitterm As String
    Be = getBatchMetadataAsDouble(termdocid, termdocid, "Be", -999)
    unitterm = unit
    If Be <> -999 Then
        If unit <> "���" Then
            If unitterm <> "���" Then
                GetTermAtmPopr = Be * (760 - davl)
            Else
                GetTermAtmPopr = Be * (101.325 - davl / 0.00750064 / 1000)
            End If
        Else
            If unitterm <> "���" Then
                GetTermAtmPopr = Be * (760 - davl * 0.00750064 * 1000)
            Else
                GetTermAtmPopr = Be * (101.325 - davl)
            End If
        End If
    Else
        GetTermAtmPopr = 0
    End If
End Function
'���������� �������� �� �������� ��� ������ 2177, t - �������� �����������, P - �������� ��������, isformula -  isformula, �� ������� �� ������� �� ���� 2177, �����  �� �������� �������������, unit - ������� ���������'
Function CalcPopr2177(t As Double, p As Double, isFormula As Boolean, unit As String)
    Dim vs As Double
    If isFormula Then
        If unit <> "���" Then
            CalcPopr2177 = 0.00012 * (760 - p) * (273 + t)
        Else
            CalcPopr2177 = 0.00009 * (101.3 - p) * (273 + t)
        End If
        Exit Function
    End If
    If p < 750 Or p > 770 Then
        vs = TableFind(t, "���� 2177 ��������", -1)
        CalcPopr2177 = -999999
        If vs <> -1 Then
            ' ������������ �������. ��������� �������� �� 760, �� ��� ������ ������ ���
            If p < 750 Then
                CalcPopr2177 = Round((750 - p) / 10, 2) * vs
            End If
            If p > 770 Then
                CalcPopr2177 = Round((770 - p) / 10, 2) * vs
            End If
        End If
    Else
        CalcPopr = 0
    End If
End Function
'���������� �������� �������� �� ������ ���� 21534'
Public Function Calc21534(v As Range, vx As Double, t As Double, a As Double, vpr As Double) As Double
    Dim C As Long
    Dim sumv As Double
    Dim count As Long
    sumv = 0
    count = 0
    For C = 1 To v.Columns.count
        If v.Cells(1, C).value <> 0 Then
            sumv = sumv + v.Cells(1, C).value
            count = count + 1
        Else
            Exit For
        End If
    Next C
    Calc21534 = (sumv - count * vx) * t * 1000 * a / vpr
End Function
'���������� ������ � ���������� ������, strings - �������� �����'
Public Function MaxStr(strings As Range) As String
    MaxStr = GetEI().GetCalculations().MaxLenStr(strings)
End Function
'���������� �������� �������, r - �������� ��������'
Public Function GetDateInterval(r As Range) As String
    GetDateInterval = GetEI().GetCalculations().GetDateInterval(r)
End Function
'���������� ����� ��������� �� ���� ������; r - ����� ������ �� �����, lab - �����������, docdescription - �������� ���������, key1 - ���� 1, Value1 - �������� ����� 1, key2 - ���� 2, Value2 - �������� ����� 2, key3 - ���� 3, Value3 - �������� ����� 3, sortmetadataname - ��� ���������� ��� ����������, ���������� � �������� �������, DateTo - ����, �� ������� ����������� �����'
Function GetSomeDocidBy3Keys(r As Range, lab As String, docdescription As String, key1 As String, Value1 As String, key2 As String, Value2 As String, key3 As String, Value3 As String, sortmetadataname As String, DateTo As String)
    GetSomeDocidBy3Keys = GetEI().GetCalculations().GetSomeDocidBy3Keys(r, lab, docdescription, key1, Value1, key2, Value2, key3, Value3, sortmetadataname, DateTo)
End Function
'���������� ������� ���������� �����, r - '
Public Function GetUslByIntervals(r As Range) As String
    GetUslByIntervals = GetEI().GetCalculations().GetUslByIntervals(r)
End Function
'������� ����������� � ������������� ���� � ���������� �� � ���� ������ ��� - ����, ���� ������� ����� ���� ������ ��������� � ������� ���������, �� ���������� ��� - ���+��������, r - ��������, minutes - ��������'
Public Function GetDateIntervalMinMinutes(r As Range, minutes As Double) As String
    GetDateIntervalMinMinutes = GetEI().GetCalculations().GetDateIntervalMinMinutes(r, minutes)
End Function
'���������� �������� ������������, batchno - ����� �����, orderatrtibute - �������� ��� ����������'
Public Function GetSpecNorm(batchno As String, orderattribute As String) As String
    GetSpecNorm = GetEI().GetCalculations().GetSpecNorm(batchno, orderattribute)
End Function
'���������� ����� ��� ������� �� ������������, batchno - ����� �����, orderatrtibute - �������� ��� ����������'
Public Function GetSpecRaschNorm(batchno As String, orderattribute As String) As String
    GetSpecRaschNorm = GetEI().GetCalculations().GetSpecRaschNorm(batchno, orderattribute)
End Function
'���������� ���������� ������ �� ������������, batchno - ����� �����, orderattribute - ����������'
Public Function GetSpecNumPrec(batchno As String, orderattribute As String) As String
    GetSpecNumPrec = GetEI().GetCalculations().GetSpecNumPrec(batchno, orderattribute)
End Function
'���������� ����� ������������ ��� �����, batchno - ����� �����, orderattribute - ����������'
Public Function GetSpecNo(batchno As String, orderattribute As String) As String
    GetSpecNo = GetEI().GetCalculations().GetSpecNo(batchno, orderattribute)
End Function
'������ ������������, docid - ���� ��������� � ������� ��� �������, x - ����������'
Public Function CalcConcentration(docid As String, x As Double) As Double
    CalcConcentration = GetEI().GetCalculations().CalcConcentration(docid, x)
End Function
'�������� ����� � ������ �� ��������� ��������; str - ������, repl - ��������� ��������'
Public Function ReplaceDigitsTo(str As String, repl As String) As String
    ReplaceDigitsTo = GetEI().GetCalculations().ReplaceDigitsTo(str, repl)
End Function
'������� ������ ������� �� �����; str - ����� � ��������� ���������'
Public Function GetNumFormatByNumber(str As String) As String
    GetNumFormatByNumber = GetEI().GetCalculations().GetNumFormatByNumber(str)
End Function
'��� ��������� ������ �� ������������ � ������� �������� �� ���������������� �������; docid - �������������� ��������, batchno - ���� �����, key - ����� ����� ��� ������ �����������, methodname - �����, testname - ����������, opr - ����� ����������� (1��� ��� �������), n - ����� ����������� � ����� (1 ��� ����������, 2 ��� �������������� � �.�.)'
Public Function GetBatcMasBSMultiMethod(docid As String, batchno As String, key As String, methodname As String, testname As String, opr As String, n As String) As Variant
    Set ei = GetEI
    GetBatcMasBSMultiMethod = ei.GetCalculations().GetBatcMasBSMultiMethod(docid, batchno, key, methodname, testname, opr, n)
End Function
'���������� ��������� �������� �� ����������; r - , docdescription - �������� ���������, key1 - ���� 1, value 1 - �������� 1, whattoget - ����, sortmetadata - ��� ���������� �� ��������� ������� ����� ����������� ���������� ��������� ������ � �������� ������� (���� ����� ���� �����������), DateTo - ����, �� ������� ������������ �����'
Public Function GetSomething(r As Range, lab As String, docdescription As String, key1 As String, Value1 As String, whattoget As String, sortmetadataname As String, DateTo As String) As Variant
    GetSomething = GetEI().GetCalculations().GetSomething(r, lab, docdescription, key1, Value1, whattoget, sortmetadataname, DateTo)
End Function
'���������� ����������� ����������; r - , num - ����� ����������, lab - �����������, DateTo - ����, �� ������� ������������ �����'
Function GetPiknVmest(r As Range, num As String, lab As String, DateTo As String) As Variant
On Error Resume Next
    GetPiknVmest = GetSomething(r, lab, "����������� ����������� ����������", "����� ����������", num, "�����������", "���� �����������", DateTo)
End Function
'���������� �������� �� ����; docid -����� ��������� � ���������� �� ����, nomrange - �������� � ����������'
Function GetGiriPopr(docid As String, nomrange As Range) As Double
    GetGiriPopr = GetEI().GetCalculations().GetGiriPopr(docid, nomrange)
End Function
'������ ����� ���� ���� 20060
Function TRossCalc(description As String, x1 As Double, x2 As Double, defaultval As Double) As Double
    TRossCalc = GetWI().TRossCalc(description, x1, x2, defaultval)
End Function
'������ ����� ����'
Function TRosCalc(x As Double, xr As Range, yr As Range) As Double
    TRosCalc = GetEI().GetCalculations().TRosCalc(x, xr, yr)
End Function
'������ ����� ���� �� ���� 53763 �� �������� � Oracle; x1 - ������� �� ���� ������������ �������� ���� � �������, x2 - ����������� ����� ���� �� �����, description - "���� 53763" ������� ���", notfoundvalue - ��������, ��������� ����� ������ �� �������'
Function TRos40Calc(x1 As Double, x2 As Double, description As String, notFoundValue As Double) As Double
    On Error GoTo errorhandler
    Application.Cursor = xlWait
    TRos40Calc = GetWI().TRos40CalcStr(description, x1, x2, notFoundValue)
errorhandler:
    Application.Cursor = xlDefault
End Function
'��������� ������ ����� ���� �� ���� 53763 �� �������� � Oracle; x1 - ������� �� ���� ������������ �������� ���� � �������, x2 - ����������� ����� ���� �� �����, description - "���� 53763" ������� ���", notfoundvalue - ��������, ��������� ����� ������ �� �������'
Function TRos40CalcStr(x1 As Double, x2 As Double, description As String, notFoundValue As Double) As Double
    On Error GoTo errorhandler
    Application.Cursor = xlWait
    TRos40CalcStr = GetWI().TRos40CalcStr(description, x1, x2, notFoundValue)
errorhandler:
    Application.Cursor = xlDefault
End Function
'���������� �������� ��������� �� ����� � ������� �������� ������������ (��������� �����); batchno - ����� �����, methodname - ��� ������, testname - ��� ����������, instrtype - ��� ����������, instrdelimeter - �����������'
Function GetBatchInstruments(batchno As String, methodname As String, testname As String, instrtype As String, instrdelimeter As String) As String
    GetBatchInstruments = GetEI().GetCalculations.GetBatchInstruments(batchno, methodname, testname, instrtype, instrdelimeter)
End Function
'���������� ���������� �� ������������ ������������; batchno - ����� �����, orderattribute - ��� ��������� ���������� � ������� ����_����������, instrtype - ��� �����������, instrdelimeter - �����������'
Function GetBatchInstrumentsByOrderattr(batchno As String, orderattribute As String, instrtype As String, instrdelimeter As String) As String
    GetBatchInstrumentsByOrderattr = GetEI().GetCalculations.GetBatchInstrumentsByOrderattr(batchno, orderattribute, instrtype, instrdelimeter)
End Function
'���������� ���������� �� ������������ � �����, batchno - ���� �����, methoddescr - �������� ������, testmeta - �� ��������� ����������, instrtype - ��� ������������, instrdelimeter - ����������� ������������ ��� ����������, formatstr - ������ ������ (��: {Description}{ProdNumber}, � �������� ������� ����� ���� ����� ���� ������� Instruments))'
Function GetBatchInstrumentsInfo(batchno As String, methoddescr As String, testmeta As String, instrtype As String, instrdelimeter As String, formatstr As String) As String
    GetBatchInstrumentsInfo = GetEI().GetCalculations.GetBatchInstrumentsInfo(batchno, methoddescr, testmeta, instrtype, instrdelimeter, formatstr)
End Function
'���������� ���������� ����������� � �����; batchno - ����� �����, orderattribute - ����������'
Function GetEnteredOpredCount(batchno As String, orderattribute As String) As String
    GetEnteredOpredCount = GetEI().GetCalculations.GetEnteredOpredCount(batchno, orderattribute)
End Function
'���������� ���������� �� ������������ � �����, batchno - ���� �����, orderattribute - ��� ��������� ���������� � ������� ����_����������, instrtype - ��� ������������, instrdelimeter - ����������� ������������ ��� ����������, formatstr - ������ ������ (��: {Description}{ProdNumber}, � �������� ������� ����� ���� ����� ���� ������� Instruments))'
Function GetBatchInstrumentsInfoByOrderattr(batchno As String, orderattribute As String, instrtype As String, instrdelimeter As String, formatstr As String) As String
GetBatchInstrumentsInfoByOrderattr = GetEI().GetCalculations.GetBatchInstrumentsInfoByOrderattr(batchno, orderattribute, instrtype, instrdelimeter, formatstr)
End Function
'����������� ����� �� ��������� ������� � ��������� � ����������� ������; number - �����'
Function ConvertNumberToTextGenitive(number As Long)
    ConvertNumberToTextGenitive = GetEI().GetCalculations.ConvertNumberToTextGenitive(number)
End Function
'����������� ����� � ����� � ������������ ������, number - �����'
Function ConvertNumberToTextNominative(number As Long)
    ConvertNumberToTextNominative = GetEI().GetCalculations.ConvertNumberToTextNominative(number)
End Function
'������������� ������� � ���� ���������� �������� ���������� �� �������� �� ����� ��� �� Delta, ���������� ���; r - ������� ��������'
Function GetUnchanged(r As Range, Optional Delta As Double = 0) As Variant
    GetUnchanged = GetEI().GetUnchanged(r, Delta)
End Function
'���������� ������� �� ���������; r - ��������'
Function Getchcount(r As Range) As Double
    Getchcount = GetEI().GetCalculations.Getchcount(r)
End Function
'������ ����������� ������������, docid - ���� ��������� � ������� ��� �������,x - ����������'
Function CalcMinConcentration(docid As String, x As Double) As Double
    CalcMinConcentration = GetEI().GetCalculations.CalcMinConcentration(docid, x)
End Function
'������ ������������ ������������, docid - ���� ��������� � ������� ��� �������,x - ����������'
Function CalcMaxConcentration(docid As String, x As Double) As Double
    CalcMaxConcentration = GetEI().GetCalculations.CalcMaxConcentration(docid, x)
End Function
'����������� � c#'
Function GetMetaValueFromSheet(testname As String, methodname As String) As Double
    GetMetaValueFromSheet = GetEI().GetCalculations.GetMetaValueFromSheet(testname, methodname)
End Function
'���������� ��� ���������� (��������), ����������� � ������ � ����� "���������"
Function GetMethodsTests(methodsids As String) As String
    GetMethodsTests = GetEI().GetCalculations.GetMethodsTests(methodsids)
End Function
'���� �� ����� ������ ������ ���������� ������ - ��� �������, � ������� �� ����� �������� ��������
Public Function GetSpaceInsteadEmpty(str As String) As String
    GetSpaceInsteadEmpty = str
    If str = "" Then
        GetSpaceInsteadEmpty = " "
    End If
End Function
'���������� ��� ���������� (������� ��������), ����������� � ������ � ����� "���������"
Function GetMethodsTestsShortDesc(methodsids As String) As String
    GetMethodsTestsShortDesc = GetEI().GetCalculations.GetMethodsTestsShortDesc(methodsids)
End Function
'���������� �������� ���� �������� �� ID, purposeid - id ���� ��������
Function GetPurposeDescriptionById(purposeid As String) As String
        GetPurposeDescriptionById = GetEI().GetCalculations.GetPurposeDescriptionById(purposeid)
End Function
'���������� ���������� �� ������������ � �����, batchno - ���� �����, methoddescr - �������� ������ (�� �����������), testmeta - �� ��������� ���������� (�� �����������), instrtype - ��� ������������ (�� �����������), instrdelimeter - ����������� ������������ ��� ����������, formatstr - ������ ������ (��: {Description}{ProdNumber}, � �������� ������� ����� ���� ����� ���� ������� Instruments))'
Function GetBatchInstrumentsInfo2(batchno As String, methoddescr As String, testmeta As String, instrtype As String, instrdelimeter As String, formatstr As String) As String
    GetBatchInstrumentsInfo2 = GetEI().GetCalculations.GetBatchInstrumentsInfo2(batchno, methoddescr, testmeta, instrtype, instrdelimeter, formatstr)
End Function
'���� ������������ ���������� ������ �� ���������
Function FindMaxCharsInRange(r As Range) As Integer
Dim C As Range
Dim i, count As Integer
count = 0
For Each C In r
    If CStr(C.value) <> "" Then
        i = IIf(Int(C.value) = C.value, 0, Len(Split(C.value, Mid(1 / 2, 2, 1))(UBound(Split(C.value, Mid(1 / 2, 2, 1))))))
            If i > count Then count = i
            End If
Next
FindMaxCharsInRange = count
End Function
'���� �������
Public Function �����������(d As String)
    Dim vs As String
    Dim year As String
    Dim vsd As Date
    vsd = CDate(d)
    vs = format(vsd, "Long Date")
    year = format(vsd, "yyyy")
    ����������� = vs
    vs = Replace(vs, " " & year & " �.", "")
    If (Mid(vs, Len(vs), 1) = "?" Or Mid(vs, Len(vs), 1) = "�" Or Mid(vs, Len(vs), 1) = "�") Then
        vs = Mid(vs, 1, Len(vs) - 1) & "�"
    Else
        vs = vs & "�"
    End If
    ����������� = """" & Replace(LCase(vs), " ", """ ") & " " & LCase(year) & " �."
End Function
