/// <summary>
/// Table BC2SC_Transport Line (ID 61002).
/// </summary>
table 61002 "BC2SC_Transport Line"
{
    Caption = 'BC2SC_Transport Line';

    fields
    {
        field(1; "Transport No."; Code[20])
        {
            Caption = 'Transport No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Type"; Enum BC2SC_TransportLine_Type)
        {
            Caption = 'Type';
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Rec.TestField(Type, Rec.Type::Item);
                Item.get("No.");
                Rec.Description := Item.Description;
                Rec."Description 2" := Item."Description 2";
                Rec."Unit of Measure Code" := Item."Base Unit of Measure";
                Rec."Weight per Unit" := Item."Gross Weight";
            end;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = ToBeClassified;
        }

        field(11; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
        }

        field(14; Quantity; Decimal)
        {
            Caption = 'Quantity';
            trigger OnValidate()
            begin
                Rec."Total Weight" := Rec."Weight per Unit" * Rec.Quantity;
            end;
        }
        field(15; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = ToBeClassified;
        }

        field(16; "Weight per Unit"; Decimal)
        {
            Caption = 'Weight per Unit';
        }
        field(17; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
        }
        field(18; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(20; "Parcel No."; Code[20])
        {
            Caption = 'Parcel No.';
            Editable = false;
            TableRelation = BC2SC_Parcel;
        }
        field(21; "Tracking No."; Text[50])
        {
            FieldClass = FlowField;
            Editable = False;
            CalcFormula = lookup(BC2SC_Parcel."Tracking No." where("No." = field("Parcel No."), "Transport No." = field("Transport No.")));
        }
        field(30; "Qty. to pack"; Decimal)
        {
            Caption = 'Qty. to pack';
        }

    }
    keys
    {
        key(PK; "Transport No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
