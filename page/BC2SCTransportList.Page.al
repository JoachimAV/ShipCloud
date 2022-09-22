/// <summary>
/// Page BC2SC_Transport List (ID 61002).
/// </summary>
page 61002 "BC2SC_Transport List"
{
    ApplicationArea = All;
    Caption = 'BC2SC_Transport List';
    PageType = List;
    SourceTable = "BC2SC_Transport Header";
    sourcetableview = sorting("No.") order(descending);
    UsageCategory = Lists;
    CardPageId = 61003;
    AutoSplitKey = True;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Direction; Rec."Transport Document Type")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                Field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    Visible = True;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Created from Document Type"; Rec."Created from Document Type")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Created from Document No."; Rec."Created from Document No.")
                {
                    ApplicationArea = All;
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                }
                field("Created at"; rec."Created at")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Created from"; rec."Created from")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Transport sendet at"; rec."Transport sendet at")
                {
                    ApplicationArea = All;
                    Visible = False;
                }

                field("Transport sendet from"; rec."Transport sendet from")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("No. of Printed"; Rec."No. of Printed")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                Applicationarea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action(SendTransport)
            {
                ApplicationArea = All;
                Caption = 'Send Transports to ShipCloud';
                Image = SendTo;
                trigger OnAction()
                var
                    TransportHeader: Record "BC2SC_Transport Header";
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    ConfMsg002: label 'Send Transports to Shipcloud (marked lines)?';
                begin
                    if Confirm(ConfMsg002, True) then begin
                        CurrPage.SetSelectionFilter(TransportHeader);
                        TransportHeader.FindFirst();
                        repeat
                            ShipCloudMgt.SendTransport(TransportHeader);
                            commit;
                        until TransportHeader.Next() = 0;
                    end;
                end;
            }
            action(CancelTransport)
            {
                ApplicationArea = All;
                Caption = 'Cancel Shipcloud Transports';
                Image = Cancel;
                trigger OnAction()
                var
                    TransportHeader: record "BC2SC_Transport Header";
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    ConfMsg003: label 'Cancel ShipCloud Transports (marked lines)?';
                    d: Dialog;
                begin
                    if Confirm(ConfMsg003, True) then begin
                        CurrPage.SetSelectionFilter(TransportHeader);
                        TransportHeader.FindFirst();
                        d.open('#1###################');
                        repeat
                            d.update(1, TransportHeader."No.");
                            ShipCloudMgt.CancelTransport(TransportHeader);
                            commit;
                        until TransportHeader.Next() = 0;
                        d.Close();
                    end;
                end;
            }
        }
        area(Reporting)
        {
            action(PrintTransport)
            {
                ApplicationArea = All;
                Caption = 'Print all Labels';
                Enabled = NodePrintActivated;
                Image = PrintDocument;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    TransportHeader: Record "BC2SC_Transport Header";
                    d: dialog;
                begin
                    if confirm(lbl001) then begin
                        CurrPage.SetSelectionFilter(TransportHeader);
                        TransportHeader.FindFirst();
                        d.open(lbl002);
                        repeat
                            d.Update(1, TransportHeader."No.");
                            ShipCloudMgt.PrintTransport(TransportHeader);
                        until TransportHeader.Next() = 0;
                    end;
                end;
            }

            Action(PrintNodeUser)
            {
                Caption = 'PrintNode User Setup';
                RunObject = page "BC2SC_PrintNode User Setup";
                image = UserSetup;
                ApplicationArea = All;
            }
            action(DownLoad)
            {
                ApplicationArea = All;
                Caption = 'Download Labels';
                ToolTip = 'Download labels for the selected transports to download folder';
                Image = Download;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    TransportHeader: record "BC2SC_Transport Header";
                    Parcel: record BC2SC_Parcel;
                    Recordlink: record "Record Link";
                    d: Dialog;
                begin
                    currpage.SetSelectionFilter(TransportHeader);
                    ShipCloudMgt.DownloadParcelsFromTransport(TransportHeader);

                    //d.close;
                end;
            }
        }
    }
    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        NodePrintActivated: Boolean;
        lbl001: label 'Print all parcel labels for selected transports?';
        lbl002: label 'Printing Transport #1###############';
        LblLabelUrl: Label 'Label URL Parcel %1';

    trigger OnOpenPage()
    begin
        ShipCloudSetup.Get();
        NodePrintActivated := ShipCloudSetup."Activate PrintNode printing";
    end;
}
