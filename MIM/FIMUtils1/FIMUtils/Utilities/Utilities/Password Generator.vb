Imports System
Imports System.Security
Imports System.Security.Cryptography

Public Class Password_Generator
    Private rng As RNGCryptoServiceProvider
    Private pwdUpperCaseCharArray As Char() = ("ABCDEFGHJKLMNPQRSTUVWXYZ").ToCharArray()
    Private pwdLowerCaseCharArray As Char() = ("abcdefghjkmnopqrstuvwxyz").ToCharArray()
    Private pwdNumericCharArray As Char() = ("0123456789").ToCharArray()

    Private Const UC_LENGTH As Integer = 1
    Private Const LC_LENGTH As Integer = 5
    Private Const N_LENGTH As Integer = 2

    Public Sub PasswordGenerator()
        rng = New RNGCryptoServiceProvider()
    End Sub

    Protected Function GetCryptographicRandomNumber(ByVal lBound As Integer, ByVal uBound As Integer) As Integer

        ' Assumes lBound >= 0 && lBound < uBound and Returns an int >= lBound and < uBound
        Dim urndnum As UInteger
        Dim rndnum(4) As Byte
        If lBound = uBound - 1 Then
            Return lBound
        End If

        Dim xcludeRndBase As UInteger = (UInteger.MaxValue - (UInteger.MaxValue * (1 / (uBound - lBound))))
        Do
            While (urndnum >= xcludeRndBase)
                rng.GetBytes(rndnum)
                urndnum = System.BitConverter.ToUInt32(rndnum, 0)
            End While
        Loop

        Return (urndnum * (1 / (uBound - lBound))) + lBound
    End Function

    Protected Function GetLCRandomCharacter() As Char
        Dim upperBound As Integer = pwdLowerCaseCharArray.GetUpperBound(0)

        Dim randomCharPosition As Integer = GetCryptographicRandomNumber(pwdLowerCaseCharArray.GetLowerBound(0), upperBound)
        Dim randomChar As Char = pwdLowerCaseCharArray(randomCharPosition)
        Return randomChar
    End Function

    Protected Function GetUCRandomCharacter() As Char

        Dim upperBound As Integer = pwdUpperCaseCharArray.GetUpperBound(0)
        Dim randomCharPosition As Integer = GetCryptographicRandomNumber(pwdUpperCaseCharArray.GetLowerBound(0), upperBound)
        Dim randomChar As Char = pwdUpperCaseCharArray(randomCharPosition)

        Return randomChar
    End Function

    Protected Function GetNRandomCharacter() As Char

        Dim upperBound As Integer = pwdNumericCharArray.GetUpperBound(0)
        Dim randomCharPosition As Integer = GetCryptographicRandomNumber(pwdNumericCharArray.GetLowerBound(0), upperBound)
        Dim randomChar As Char = pwdNumericCharArray(randomCharPosition)
        Return randomChar
    End Function

    Public Function Generate() As String

        Dim pwdBuffer As Text.StringBuilder = New Text.StringBuilder()
        Dim nextCharacter As Char

        pwdBuffer.Capacity = UC_LENGTH + LC_LENGTH + N_LENGTH
        nextCharacter = "\n"

        For i As Integer = 0 To UC_LENGTH
            nextCharacter = GetUCRandomCharacter()
            pwdBuffer.Append(nextCharacter)
        Next i

        For i As Integer = 0 To LC_LENGTH
            nextCharacter = GetLCRandomCharacter()
            pwdBuffer.Append(nextCharacter)
        Next i

        For i As Integer = 0 To N_LENGTH
            nextCharacter = GetNRandomCharacter()
            pwdBuffer.Append(nextCharacter)
        Next

        If Not pwdBuffer.Length = 0 Then
            Return pwdBuffer.ToString()
        Else
            Return String.Empty
        End If
    End Function

End Class

