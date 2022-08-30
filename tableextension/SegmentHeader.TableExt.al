tableextension 61002 "Segment Header" extends "Segment Header"
{
    fields
    {
        field(61000; "BC2SC_Qty. Transports"; Integer)
        {
            Caption = 'Qty. Transports';
            FieldClass = FlowField;
            CalcFormula = count("BC2SC_Transport Header" where("Source Document Type" = const(Segment), "Source Document No." = field("No.")));
            Editable = false;
        }
        field(61001; "BC2SC_Parcel Weight"; Decimal)
        {
            Caption = 'Parcel Weight';
        }
        field(61002; "BC2SC_Packaging Code"; Code[20])
        {
            Caption = 'Packaging Code';
            TableRelation = BC2SC_Packaging;
        }
        field(61003; "BC2SC_Shipping Item No."; Code[20])
        {
            Caption = 'Shipping Item No.';
            TableRelation = Item;
        }
        field(61004; "BC2SC_Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(61005; "BC2SC_Ship. Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("BC2SC_Shipping Agent Code"));
        }
    }
}
