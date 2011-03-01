VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "spartan3"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        BEGIN BLOCKDEF data_buffer
            TIMESTAMP 2011 3 1 15 5 2
            RECTANGLE N 64 -384 320 0 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            LINE N 64 -224 0 -224 
            LINE N 64 -160 0 -160 
            LINE N 64 -96 0 -96 
            LINE N 64 -32 0 -32 
            LINE N 320 -288 384 -288 
            LINE N 320 -352 384 -352 
        END BLOCKDEF
        BEGIN BLOCKDEF multiplier
            TIMESTAMP 2011 3 1 15 35 52
            RECTANGLE N 64 -128 320 0 
            LINE N 64 -96 0 -96 
            LINE N 320 -96 384 -96 
            LINE N 64 -32 0 -32 
        END BLOCKDEF
        BEGIN BLOCKDEF gain_amp
            TIMESTAMP 2011 3 1 12 58 30
            RECTANGLE N 64 -192 320 0 
            LINE N 64 -160 0 -160 
            LINE N 320 -160 384 -160 
            LINE N 64 -96 0 -96 
            LINE N 64 -32 0 -32 
        END BLOCKDEF
        BEGIN BLOCKDEF filter
            TIMESTAMP 2011 3 1 14 5 45
            RECTANGLE N 64 -192 320 0 
            LINE N 64 -32 0 -32 
            LINE N 64 -96 0 -96 
            LINE N 64 -160 0 -160 
            LINE N 320 -160 384 -160 
        END BLOCKDEF
        BEGIN BLOCKDEF coeff_io
            TIMESTAMP 2011 3 1 15 26 13
            RECTANGLE N 0 -64 256 0 
            LINE N 256 -32 320 -32 
        END BLOCKDEF
        BEGIN BLOCK XLXI_5 data_buffer
            PIN sample_in
            PIN CE
            PIN load
            PIN reset
            PIN read
            PIN clk
            PIN OE
            PIN sample_out
        END BLOCK
        BEGIN BLOCK XLXI_6 multiplier
            PIN DI
            PIN DO
            PIN DI_C
        END BLOCK
        BEGIN BLOCK XLXI_8 gain_amp
            PIN DI
            PIN DO
            PIN clk
            PIN gain
        END BLOCK
        BEGIN BLOCK XLXI_9 filter
            PIN clk
            PIN sam_in
            PIN coef_in
            PIN sam_out
        END BLOCK
        BEGIN BLOCK XLXI_10 coeff_io
            PIN tc
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 5440 3520
        BEGIN INSTANCE XLXI_6 1136 896 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_10 1696 832 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_8 2000 1584 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_9 1424 1584 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_5 544 1152 R0
        END INSTANCE
    END SHEET
END SCHEMATIC
