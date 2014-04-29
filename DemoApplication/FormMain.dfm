object FormMain: TFormMain
  Left = 592
  Top = 459
  Width = 634
  Height = 433
  Caption = 'PBPageControlDemo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 313
    Top = 0
    Width = 313
    Height = 406
    Align = alClient
    TabOrder = 0
    object PBPageControl2: TPBPageControl
      Left = 1
      Top = 184
      Width = 311
      Height = 221
      ActivePage = TabSheet6
      Align = alBottom
      TabOrder = 0
      TabPosition = tpBottom
      object TabSheet3: TTabSheet
        Caption = 'Enabled'
      end
      object TabSheet4: TTabSheet
        Caption = 'Disabled'
        Enabled = False
        ImageIndex = 1
      end
      object TabSheet6: TTabSheet
        Caption = 'Enabled'
        ImageIndex = 2
      end
    end
    object PBPageControl1: TPBPageControl
      Left = 1
      Top = 1
      Width = 311
      Height = 183
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 1
      object TabSheet1: TTabSheet
        Caption = 'Enabled'
        object Button1: TButton
          Left = 96
          Top = 24
          Width = 75
          Height = 25
          Caption = 'Test it'
          TabOrder = 0
          OnClick = Button1Click
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Disabled'
        Enabled = False
        ImageIndex = 1
      end
      object TabSheet5: TTabSheet
        Caption = 'Test me'
        ImageIndex = 2
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 313
    Height = 406
    Align = alLeft
    TabOrder = 1
    object PBPageControl3: TPBPageControl
      Left = 1
      Top = 1
      Width = 152
      Height = 404
      ActivePage = TabSheet11
      Align = alLeft
      MultiLine = True
      TabOrder = 0
      TabPosition = tpLeft
      object TabSheet7: TTabSheet
        Caption = 'Disabled'
        Enabled = False
      end
      object TabSheet8: TTabSheet
        Caption = 'Enabled'
        ImageIndex = 1
      end
      object TabSheet11: TTabSheet
        Caption = 'Enabled'
        ImageIndex = 2
      end
    end
    object PBPageControl4: TPBPageControl
      Left = 153
      Top = 1
      Width = 159
      Height = 404
      ActivePage = TabSheet12
      Align = alClient
      MultiLine = True
      TabOrder = 1
      TabPosition = tpRight
      object TabSheet9: TTabSheet
        Caption = 'Disabled'
        Enabled = False
      end
      object TabSheet10: TTabSheet
        Caption = 'Enabled'
        ImageIndex = 1
      end
      object TabSheet12: TTabSheet
        Caption = 'Enabled'
        ImageIndex = 2
      end
    end
  end
end
