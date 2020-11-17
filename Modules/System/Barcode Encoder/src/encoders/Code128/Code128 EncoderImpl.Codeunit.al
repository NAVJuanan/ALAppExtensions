// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-128 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-128/ 
/// Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
/// </summary>
codeunit 9217 Code128_BarcodeEncoderImpl
{
    Access = Internal;

    var
        No128CodeSetDefinedErr: label 'You must define a Code 128 codeset, this can be either auto, a, b or c';

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_128/
    /// Code 128 is a high-density linear barcode symbology defined in ISO/IEC 15417:2007.[1] It is used for alphanumeric or numeric-only barcodes. 
    /// It can encode all 128 characters of ASCII and, by use of an extension symbol (FNC4), the Latin-1 characters defined in ISO/IEC 8859-1. 
    /// It generally results in more compact barcodes compared to other methods like Code 39, especially when the texts contain mostly digits.
    /// GS1-128 (formerly known as UCC/EAN-128) is a subset of Code 128 and is used extensively worldwide in shipping and packaging industries as a product identification code for the container and pallet levels in the supply chain.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; IsHandled: Boolean)
    var
        FontEncoder: DotNet dnFontEncoder;
        ReturnType: Integer;
        UseTildeAsEscapeChar: Boolean;
    begin
        if IsHandled then exit;

        //#Todo find a way to control type a, b, c with or without TildeAsEscapeChar
        FontEncoder := FontEncoder.FontEncoder();
        case Lowercase(TempBarcodeParameters.OptionParameterString) of
            '':
                Error(No128CodeSetDefinedErr);
            'a':
                EncodedText := FontEncoder.Code128a(TempBarcodeParameters."Input String");
            'b':
                EncodedText := FontEncoder.Code128b(TempBarcodeParameters."Input String");
            'c':
                EncodedText := FontEncoder.Code128c(TempBarcodeParameters."Input String");
            else
                EncodedText := FontEncoder.Code128(TempBarcodeParameters."Input String", ReturnType, UseTildeAsEscapeChar);
        end;
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Code_128/
    /// Code 128 includes 108 symbols: 103 data symbols, 3 start symbols, and 2 stop symbols. 
    /// Each symbol consists of three black bars and three white spaces of varying widths. All widths are multiples of a basic "module". 
    /// Each bar and space is 1 to 4 modules wide, and the symbols are fixed width: the sum of the widths of the three black bars and three white bars is 11 modules.
    /// The stop pattern is composed of two overlapped symbols and has four bars. The stop pattern permits bidirectional scanning. When the stop pattern is read left-to-right (the usual case), the stop symbol (followed by a 2-module bar) is recognized. 
    /// When the stop pattern is read right-to-left, the reverse stop symbol (followed by a 2-module bar) is recognized. A scanner seeing the reverse stop symbol then knows it must skip the 2-module bar and read the rest of the barcode in reverse.
    /// Despite its name, Code 128 does not have 128 distinct symbols, so it cannot represent 128 code points directly. To represent all 128 ASCII values, it shifts among three code sets (A, B, C). 
    /// Together, code sets A and B cover all 128 ASCII characters. Code set C is used to efficiently encode digit strings. 
    /// The initial subset is selected by using the appropriate start symbol. Within each code set, some of the 103 data code points are reserved for shifting to one of the other two code sets. 
    /// The shifts are done using code points 98 and 99 in code sets A and B, 100 in code sets A and C and 101 in code sets B and C to switch between them):
    ///    -  128A (Code Set A) – ASCII characters 00 to 95 (0–9, A–Z and control codes), special characters, and FNC 1–4
    ///    -  128B (Code Set B) – ASCII characters 32 to 127 (0–9, A–Z, a–z), special characters, and FNC 1–4
    ///    -  128C (Code Set C) – 00–99 (encodes two digits with a single code point) and FNC1
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="ValidationResult">Parameter of type Boolean.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary; var ValidationResult: Boolean; IsHandled: Boolean)
    var
        RegexPattern: codeunit Regex;
    begin
        if IsHandled then exit;

        ValidationResult := true;

        // null or empty
        if (TempBarcodeParameters."Input String" = '') then begin
            ValidationResult := false;
            exit;
        end;

        case Lowercase(TempBarcodeParameters.OptionParameterString) of
            '':
                Error(No128CodeSetDefinedErr);
            'a':
                ValidationResult := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '^[\000-\137]*$');
            'b':
                ValidationResult := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '^[\040-\177]*$');
            'c':
                ValidationResult := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '^(([0-9]{2})+?)*$');
            else
                ValidationResult := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '^[\000-\177]*$');
        end;
    end;

    // Format the Inputstring of the barcode
    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Data: Text; var IsHandled: Boolean)
    begin
        if IsHandled then exit;
    end;
}
