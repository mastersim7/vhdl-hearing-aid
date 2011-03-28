Public Class Form1

    Private Sub DataReceived(ByVal sender As Object, ByVal e As System.IO.Ports.SerialDataReceivedEventArgs) Handles SerialPort1.DataReceived
        Datarecieved_textbox.Invoke(New myDelegate(AddressOf UpdateTextBox), New Object() {})
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
        strOut0 = HexString(SerialPort1.ReadExisting)
        With Datarecieved_textbox
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



End Class
