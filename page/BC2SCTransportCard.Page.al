/// <summary>
/// Page BC2SC_Transport Card (ID 61003).
/// </summary>
page 61003 "BC2SC_Transport Card"
{
    Caption = 'Transport Card';
    PageType = Card;
    SourceTable = "BC2SC_Transport Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = False;
                }
                field(Direction; Rec."Transport Document Type")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = Rec."Source Document Type" = Rec."Source Document Type"::Manual;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = All;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field("Notification E-Mail"; Rec."Notification E-Mail")
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
            }
            group(DocumentRef)
            {
                Caption = 'Document Reference';
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
                    Importance = Additional;
                }
            }
            part(Lines; "BC2SC_Transport Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Transport No." = Field("No.");
                UpdatePropagation = Both;
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
            Action(CreateParcel)
            {
                ApplicationArea = All;
                Caption = 'Create Parcel';
                Image = CreatePutawayPick;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    ConfMsg001: Label 'Create parcels for outstanding lines?';
                begin
                    if Confirm(ConfMsg001, true) then
                        ShipCloudMgt.CreateParcel(Rec);
                end;
            }
            action(SendTransport)
            {
                ApplicationArea = All;
                Caption = 'Send Transport to ShipCloud';
                Image = SendTo;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    ConfMsg002: label 'Send Transport to Shipcloud?';
                begin
                    if Confirm(ConfMsg002, True) then
                        ShipCloudMgt.SendTransport(Rec);
                end;
            }
            action(CancelTransport)
            {
                ApplicationArea = All;
                Caption = 'Cancel Shipcloud Transport';
                Image = Cancel;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    ConfMsg003: label 'Cancel ShipCloud Transport?';
                begin
                    if Confirm(ConfMsg003, false) then
                        ShipCloudMgt.CancelTransport(Rec);
                end;
            }
            action(SetQtyToPackZero)
            {
                ApplicationArea = All;
                Caption = 'Set Qty. to Pack Zero';
                Image = DeleteQtyToHandle;
                trigger OnAction()
                var
                    TransportLine: record "BC2SC_Transport Line";
                    lLabel001: label 'Set all qty. to pack to cero?';
                begin
                    if confirm(lLabel001) then begin
                        TransportLine.setrange("Transport No.", Rec."No.");
                        TransportLine.setrange("Parcel No.", '');
                        if TransportLine.findfirst() then
                            repeat
                                TransportLine.validate("Qty. to pack", 0);
                                TransportLine.modify(true);
                            until TransportLine.next = 0;
                    end;

                end;
            }
            action(CompleteTransport)
            {
                ApplicationArea = All;
                Caption = 'Pack all';
                Image = AllLines;

                trigger OnAction()
                var
                    TransportLine: Record "BC2SC_Transport Line";
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    ConfMsg004: label 'Pack all lines in one Parcel?';
                begin
                    if Confirm(ConfMsg004, true) then begin
                        TransportLine.setrange("Transport No.", Rec."No.");
                        TransportLine.setfilter("Parcel No.", '%1', '');
                        TransportLine.findfirst();
                        repeat
                            Transportline.validate("Qty. to pack", TransportLine.Quantity);
                            TransportLine.Modify(true);
                        until TransportLine.next() = 0;
                        commit;
                        ShipCloudMgt.CreateParcel(Rec);
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
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                begin
                    if confirm(lbl001) then
                        ShipCloudMgt.PrintTransport(Rec);
                end;
            }
        }
    }
    var
        PageEditable: Boolean;
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        NodePrintActivated: Boolean;
        lbl001: label 'Print all parcel labels?';

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Editable := CheckPageEditable();
    end;

    trigger OnOpenPage()
    begin
        ShipCloudSetup.Get();
        NodePrintActivated := ShipCloudSetup."Activate PrintNode printing";
    end;

    Procedure CheckPageEditable(): Boolean;
    begin
        PageEditable := (Rec.Status = Rec.Status::Open);
        Exit(PageEditable);
    end;

}
