/// <summary>
/// TableExtension "Customer" (ID 61001) extends Record Customer.
/// </summary>
tableextension 61001 BC2SC_Customer extends Customer
{
    fields
    {
        field(61000; "BC2SC_Qty. Transports"; Integer)
        {
            Caption = 'Qty. Transports';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BC2SC_Transport Header" where("Customer No." = field("No.")));
        }
    }
}
