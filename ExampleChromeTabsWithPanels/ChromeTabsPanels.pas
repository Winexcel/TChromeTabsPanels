unit ChromeTabsPanels;

interface

uses
  System.SysUtils, Vcl.Controls, Vcl.ExtCtrls, ChromeTabs, ChromeTabsGlassForm,
  ChromeTabsClasses, Winapi.GDIPAPI, System.Generics.Collections, cefvcl, cefgui,
  ceflib, System.Classes;

type

  TPanelTab = class(TPanel)
  private
    FChromeTab:TChromeTab;
    isPopupBrowser:boolean;
    procedure SetChromeTab(ChromeTab:TChromeTab);
    //procedure SetChrome(Chrome:TChromium);
//    procedure SetFrame(Frame:ICefFrame);
  public
    property ChromeTab:TChromeTab read FChromeTab write SetChromeTab;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
  TCallBackShowPanel = Procedure(ChromeTab:TChromeTab) of object;
  TChromeTabsPanels = class
  private
    ChromeTabs:TChromeTabs;
    Container:TWinControl;
    LaterActiveChromeTab:TChromeTab;
    ActiveTabPanel:TPanelTab;
    Panels:TList<TPanelTab>;
  public
    constructor Create(var ChromeTabs: TChromeTabs; Container:TWinControl);
    destructor Destroy(); override;
    function AddPanel(ChromeTab:TChromeTab; isBeforePopup:boolean=false; isVisible:boolean=true):TPanelTab;
    //function AddPanel(ChromeTab:TChromeTab; isBeforePopup:boolean):TPanelTab; overload;
    procedure RemovePanel(ChromeTab:TChromeTab); overload;
    //procedure RemovePanel(const Frame:ICefFrame); overload;
    procedure ShowPanel(ChromeTab:TChromeTab; isBeforePopup:boolean=false; callback:TCallBackShowPanel=nil; isVisible:boolean=true);
    procedure HidePanel(ChromeTab:TChromeTab);
    function GetPanel(ChromeTab:TChromeTab):TPanelTab; overload;
    //function GetPanel(const Frame:ICefFrame):TPanelTab; overload;
    //function GetPanel(const Browser:ICefBrowser):TPanelTab; overload;
  end;

  TChromeTabsPanelsWithChrome = class(TChromeTabsPanels)
  public
    constructor Create(ChromeTabs: TChromeTabs; Container:TWinControl);
    destructor Destroy(); override;
    //procedure AddFrame(ChromeTab:TChromeTab; Frame:ICefFrame);
  end;

implementation

{ TChromeTabsPanels }

function TChromeTabsPanels.AddPanel(ChromeTab: TChromeTab;
  isBeforePopup: boolean=false; isVisible:boolean=true): TPanelTab;
var
  index:integer;
begin
  index:=Panels.Add(TPanelTab.Create(Container));
  Panels[index].ChromeTab := ChromeTab;
  with Panels[index] do
  begin
    Parent := Container;
    Align := alClient;
    Caption:='Tab ' + ChromeTab.Index.ToString;
    //Hide;
  end;
  Result:=Panels[index];
  ChromeTab.TabPanel := Result;
end;

constructor TChromeTabsPanels.Create(var ChromeTabs: TChromeTabs;
  Container: TWinControl);
var
  i:integer;
begin
  inherited Create();
  if (ChromeTabs <> nil) and (Container <> nil) then
  begin
    Panels:=TList<TPanelTab>.Create;
    Self.Container := Container;
    Self.ChromeTabs := ChromeTabs;

    if ChromeTabs.ActiveTabIndex > -1 then
      LaterActiveChromeTab:=ChromeTabs.Tabs[ChromeTabs.ActiveTabIndex]
    else
      LaterActiveChromeTab:=nil;

    for i := 0 to ChromeTabs.Tabs.Count-1 do
      AddPanel(ChromeTabs.Tabs[i]);
    if Assigned(ChromeTabs.Tabs.ActiveTab) then
      ShowPanel(ChromeTabs.Tabs.ActiveTab);
  end
  else
    Destroy;
end;

destructor TChromeTabsPanels.Destroy;
 var
  o:TPanel;
begin
  for o in Panels do
    if Assigned(o) then
      o.Free;
  Panels.Free;
  inherited;
end;

{
function TChromeTabsPanels.GetPanel(const Frame: ICefFrame): TPanelTab;
var
  o:TPanelTab;
begin
  Result:=nil;
  if Assigned(Frame) then
    for o in Panels do
    begin
      if o.Frame.Browser.Identifier = Frame.browser.Identifier then
      begin
        Result:=o;
        break;
      end;
    end;
end;
}
function TChromeTabsPanels.GetPanel(ChromeTab: TChromeTab): TPanelTab;
var
  o:TPanelTab;
begin
  Result:=nil;
  if Assigned(ChromeTab) then
    for o in Panels do
    begin
      if o.ChromeTab = ChromeTab then
      begin
        Result:=o;
        break;
      end;
    end;
end;

{
function TChromeTabsPanels.GetPanel(const Browser: ICefBrowser): TPanelTab;
var
  o:TPanelTab;
begin
  Result:=nil;
  if Assigned(Browser) then
    for o in Panels do
    begin
      if o.Frame.Browser.Identifier = Browser.Identifier then
      begin
        Result:=o;
        break;
      end;
    end;
end;
}

procedure TChromeTabsPanels.HidePanel(ChromeTab:TChromeTab);
var
  o:TPanelTab;
begin
  o:=GetPanel(ChromeTab);
  if Assigned(o) then
    o.Hide;
end;

{
procedure TChromeTabsPanels.RemovePanel(const Frame: ICefFrame);
var
  o:TPanelTab;
begin
  o:=GetPanel(Frame);
  if Assigned(o) then
  begin
    if Assigned(o.FChrome) and not(o.isPopupBrowser)  then
      o.FChrome.Free;
    ChromeTabs.Tabs.DeleteTab(O.ChromeTab.Index, False);
    o.Free;
    Panels.Remove(o);
  end;
end;
}

procedure TChromeTabsPanels.RemovePanel(ChromeTab: TChromeTab);
var
  o:TPanelTab;
begin
  o:=GetPanel(ChromeTab);
  if Assigned(o) then
  begin
    ChromeTabs.Tabs.DeleteTab(O.ChromeTab.Index, False);
    o.Free;
    Panels.Remove(o);
  end;
end;

procedure TChromeTabsPanels.ShowPanel(ChromeTab:TChromeTab; isBeforePopup:boolean=false; callback:TCallBackShowPanel=nil; isVisible:boolean=true);
var
  o:TPanelTab;
  found:boolean;
begin
  o:=GetPanel(ChromeTab);
  if Assigned(o) then
  begin
    HidePanel(LaterActiveChromeTab);
    o.Show;
  end
  else
    o:=AddPanel(ChromeTab, isBeforePopup, isVisible);
  LaterActiveChromeTab:=o.ChromeTab;
  o.Show;
  ActiveTabPanel := o;
  if Assigned(callback) then
    callback(ChromeTab);
end;

{ TChromeTabsPanelsWithChrome }
{
procedure TChromeTabsPanelsWithChrome.AddFrame(ChromeTab: TChromeTab;
  Frame: ICefFrame);
var
  o:TPanelTab;
begin
  o:=GetPanel(ChromeTab);
  if Assigned(o) then
    o.Frame := Frame;
end;  }

constructor TChromeTabsPanelsWithChrome.Create(ChromeTabs: TChromeTabs;
  Container: TWinControl);
begin
  inherited Create(ChromeTabs, Container);
end;

destructor TChromeTabsPanelsWithChrome.Destroy;
begin
  inherited;
end;

{ TPanelTab }
constructor TPanelTab.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.BevelOuter := bvNone;
end;


destructor TPanelTab.Destroy;
begin
  FChromeTab:=nil;
  inherited;
end;

procedure TPanelTab.SetChromeTab(ChromeTab: TChromeTab);
begin
  FChromeTab:=ChromeTab;
end;

end.
