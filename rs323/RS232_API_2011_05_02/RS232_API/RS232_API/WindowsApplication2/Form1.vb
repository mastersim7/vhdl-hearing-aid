Imports System.Text

Public Class Form1


    Private Sub DataReceived(ByVal sender As Object, ByVal e As System.IO.Ports.SerialDataReceivedEventArgs) Handles SerialPort1.DataReceived
 
        Try
            Datarecieved_textbox.Invoke(New myDelegate(AddressOf UpdateTextBox), New Object() {})
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try


    End Sub


    Private Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Button1.Click
        If SerialPort1.IsOpen Then
            SerialPort1.Close()
        End If
        Try
            With SerialPort1
                .PortName = ComPorts.Text
                .BaudRate = 9600
                .Parity = IO.Ports.Parity.None
                .DataBits = 8
                .StopBits = IO.Ports.StopBits.One
            End With
            SerialPort1.Open()
            Lblmessage.Text = ComPorts.Text & " connected at " + System.DateTime.Now
            Button1.Enabled = False
            Button2.Enabled = True
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub

    Public Delegate Sub myDelegate()
    Public Sub UpdateTextBox()
        Dim strOut0 As String
        strOut0 = ConvertToBinary(SerialPort1.ReadExisting)
        Label_1.Text = strOut0
        If Label_1.Text.Length > 64 Then
            Label_1.Text = Label_1.Text + strOut0
            Label_1.Text = strOut0
            Dim value_1 As String = Label_1.Text.Substring(0, 8)
            Dim value_2 As String = Label_1.Text.Substring(8, 8)
            Dim value_3 As String = Label_1.Text.Substring(16, 8)
            Dim value_4 As String = Label_1.Text.Substring(24, 8)
            Dim value_5 As String = Label_1.Text.Substring(32, 8)
            Dim value_6 As String = Label_1.Text.Substring(40, 8)
            Dim value_7 As String = Label_1.Text.Substring(48, 8)
            Dim value_8 As String = Label_1.Text.Substring(56, 8)
            Dim Valu_int1 As Integer = value_1
            Dim Valu_int2 As Integer = value_2
            Dim Valu_int3 As Integer = value_3
            Dim Valu_int4 As Integer = value_4
            Dim Valu_int5 As Integer = value_5
            Dim Valu_int6 As Integer = value_6
            Dim Valu_int7 As Integer = value_7
            Dim Valu_int8 As Integer = value_8

            'ProgressBar1.Value = Valu_int1
            'ProgressBar2.Value = Valu_int2
            'ProgressBar3.Value = Valu_int3
            'ProgressBar4.Value = Valu_int4
            'ProgressBar5.Value = Valu_int5
            'ProgressBar6.Value = Valu_int6
            'ProgressBar7.Value = Valu_int7
            'ProgressBar8.Value = Valu_int8
        End If
        With Datarecieved_textbox
            '.Clear()
            .Font = New Font("TimesNewRoman", 12.0!, FontStyle.Bold)
            .SelectionColor = Color.Red
            .AppendText(strOut0)
            .ScrollToCaret()
        End With


    End Sub

    Private Sub Label1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Label1.Click

    End Sub

    Private Sub Button2_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Button2.Click
        Try
            SerialPort1.Close()
            Lblmessage.Text = ComPorts.Text & " disconnected " + System.DateTime.Now
            Button1.Enabled = True
            Button2.Enabled = False
            Datarecieved_textbox.Clear()
            'ProgressBar1.Value = 0
            'ProgressBar2.Value = 0
            'ProgressBar3.Value = 0
            'ProgressBar4.Value = 0
            'ProgressBar5.Value = 0
            'ProgressBar6.Value = 0
            'ProgressBar7.Value = 0
            'ProgressBar8.Value = 0
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub

    Private Sub Form1_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        For i As Integer = 0 To My.Computer.Ports.SerialPortNames.Count - 1
            ComPorts.Items.Add(My.Computer.Ports.SerialPortNames(i))
        Next
        Button2.Enabled = Enabled
        Timer1.Enabled = True
    End Sub

    Private Sub Tx_Button_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Tx_Button.Click

        Dim sTx1 As Char
        Dim sTx2 As Char
        Dim sTx3 As Char
        Dim sTx4 As Char
        Dim sTx5 As Char
        Dim sTx6 As Char
        Dim sTx7 As Char
        Dim sTx8 As Char

        sTx1 = ChrW(TrackBar1.Value)
        sTx2 = ChrW(TrackBar2.Value)
        sTx3 = ChrW(TrackBar3.Value)
        sTx4 = ChrW(TrackBar4.Value)
        sTx5 = ChrW(TrackBar5.Value)
        sTx6 = ChrW(TrackBar6.Value)
        sTx7 = ChrW(TrackBar7.Value)
        sTx8 = ChrW(TrackBar8.Value)

        If SerialPort1.IsOpen() = True Then
            SerialPort1.Write(sTx1)
            SerialPort1.Write(sTx2)
            SerialPort1.Write(sTx3)
            SerialPort1.Write(sTx4)
            SerialPort1.Write(sTx5)
            SerialPort1.Write(sTx6)
            SerialPort1.Write(sTx7)
            SerialPort1.Write(sTx8)
            Datarecieved_textbox.Clear()
        Else
            MessageBox.Show(" COM port not connected!")
        End If

    End Sub

    Private Sub Close_Button_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Close_Button.Click
        Me.Close()
    End Sub

    Private Function HexString(ByVal EvalString As String) As String
        Dim intStrLen As Integer
        Dim intLoop As Integer
        Dim strHex As String = ""
        ' EvalString = Trim(EvalString)
        intStrLen = Len(EvalString)
        For intLoop = 1 To intStrLen
            strHex = strHex & "" & Hex(Asc(Mid(EvalString, intLoop, 1)))
        Next
        HexString = strHex
    End Function

    Public Function ConvertToBinary(ByVal str As String) As String
        Dim converted As New StringBuilder
        For Each b As Byte In ASCIIEncoding.UTF8.GetBytes(str)
            converted.Append(Convert.ToString(b, 2).PadLeft(8, "0"))
        Next
        Return converted.ToString()
    End Function


    Private Sub receive_gain_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles receive_gain.Click
        Dim rx_gain1 As Char
        Dim rx_gain2 As Char
        
        rx_gain1 = ChrW(64)
        rx_gain2 = ChrW(128)
        If SerialPort1.IsOpen() = True Then
            SerialPort1.Write(rx_gain1)
            SerialPort1.Write(rx_gain2)
        Else
            MessageBox.Show(" COM port not connected!")
        End If
    End Sub
End Class
