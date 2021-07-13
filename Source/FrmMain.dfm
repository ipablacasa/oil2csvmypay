object FrmPrincipale: TFrmPrincipale
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Conversione giornale di cassa OIL -> csv'
  ClientHeight = 701
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 52
    Height = 13
    Caption = 'File singolo'
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 51
    Height = 13
    Caption = 'File multipli'
  end
  object Label3: TLabel
    Left = 8
    Top = 344
    Width = 100
    Height = 13
    Caption = 'Cartella destinazione'
  end
  object SpeedButton1: TSpeedButton
    Left = 580
    Top = 176
    Width = 30
    Height = 30
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
      5555555555555555555555555555555555555555555555555555555555555555
      555555555555555555555555555555555555555FFFFFFFFFF555550000000000
      55555577777777775F55500B8B8B8B8B05555775F555555575F550F0B8B8B8B8
      B05557F75F555555575F50BF0B8B8B8B8B0557F575FFFFFFFF7F50FBF0000000
      000557F557777777777550BFBFBFBFB0555557F555555557F55550FBFBFBFBF0
      555557F555555FF7555550BFBFBF00055555575F555577755555550BFBF05555
      55555575FFF75555555555700007555555555557777555555555555555555555
      5555555555555555555555555555555555555555555555555555}
    NumGlyphs = 2
    OnClick = SpeedButton1Click
  end
  object LblOutputFolder: TJvDirectoryEdit
    Left = 8
    Top = 363
    Width = 593
    Height = 21
    TabOrder = 0
    Text = 'C:\ExportGdc'
  end
  object BtnElaborate: TButton
    Left = 8
    Top = 661
    Width = 75
    Height = 25
    Caption = 'Elabora'
    TabOrder = 1
    OnClick = BtnElaborateClick
  end
  object BtnClose: TButton
    Left = 526
    Top = 661
    Width = 75
    Height = 25
    Caption = 'Chiudi'
    TabOrder = 2
    OnClick = BtnCloseClick
  end
  object EdtSelectedOILFile: TJvFilenameEdit
    Left = 8
    Top = 35
    Width = 593
    Height = 21
    AddQuotes = False
    Filter = 'OIL FIle (*.xml)|*.xml'
    TabOrder = 3
    Text = ''
  end
  object Memo1: TMemo
    Left = 856
    Top = 35
    Width = 426
    Height = 261
    Lines.Strings = (
      'Memo1')
    TabOrder = 4
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 390
    Width = 593
    Height = 254
    DataSource = DataSource1
    TabOrder = 5
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object LbxFiles: TListBox
    Left = 8
    Top = 83
    Width = 569
    Height = 242
    ItemHeight = 13
    TabOrder = 6
  end
  object XMLSource: TXMLDocument
    Left = 360
    Top = 88
  end
  object CdsTemp: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'AnnoBolletta'
        DataType = ftString
        Size = 4
      end
      item
        Name = 'NumeroBolletta'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'DataMovimento'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'Ordinante'
        DataType = ftString
        Size = 200
      end
      item
        Name = 'Causale'
        DataType = ftString
        Size = 200
      end
      item
        Name = 'Importo'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'DataValuta'
        DataType = ftString
        Size = 10
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 576
    Top = 32
  end
  object DataSource1: TDataSource
    DataSet = CdsTemp
    Left = 440
    Top = 456
  end
  object JvDBGridCSVExport: TJvDBGridCSVExport
    Caption = 'Exporting to CSV/Text...'
    Grid = DBGrid1
    ExportSeparator = esSemiColon
    QuoteEveryTime = False
    Left = 680
    Top = 24
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.xml'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 256
    Top = 648
  end
end
