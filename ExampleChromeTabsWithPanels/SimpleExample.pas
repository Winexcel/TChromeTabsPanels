unit SimpleExample;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, ChromeTabs, ChromeTabsPanels, ChromeTabsClasses,
  Vcl.StdCtrls;

type
  TForm4 = class(TForm)
    ChromeTabs: TChromeTabs;
    BrowserPanels: TPanel;
    tools: TPanel;
    Button1: TButton;
    procedure ChromeTabsActiveTabChanged(Sender: TObject; ATab: TChromeTab);
    procedure FormCreate(Sender: TObject);
    procedure ChromeTabsButtonCloseTabClick(Sender: TObject; ATab: TChromeTab;
      var Close: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    TabsPanels:TChromeTabsPanelsWithChrome;
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
  if ChromeTabs.Tabs.ActiveTab<>nil then
    if ChromeTabs.Tabs.ActiveTab.TabPanel is TPanel then
      Showmessage(TPanel(ChromeTabs.Tabs.ActiveTab.TabPanel).Caption);
end;

procedure TForm4.ChromeTabsActiveTabChanged(Sender: TObject; ATab: TChromeTab);
begin
 if Assigned(TabsPanels) then
     TabsPanels.ShowPanel(ATab);
end;


procedure TForm4.ChromeTabsButtonCloseTabClick(Sender: TObject;
  ATab: TChromeTab; var Close: Boolean);
begin
  if Assigned(TabsPanels) then
    TabsPanels.RemovePanel(ATab);
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  TabsPanels:=TChromeTabsPanelsWithChrome.Create(ChromeTabs, Self.BrowserPanels);
end;

end.
