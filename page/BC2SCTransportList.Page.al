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
                begin
                    if Confirm(ConfMsg003, True) then begin
                        CurrPage.SetSelectionFilter(TransportHeader);
                        TransportHeader.FindFirst();
                        repeat
                            ShipCloudMgt.CancelTransport(TransportHeader);
                        until TransportHeader.Next() = 0;
                    end;
                end;
            }

        }
    }
}
