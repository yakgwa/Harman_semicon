class c_4_3;
    bit[7:0] req_addr = 8'h0;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:43)
    {
       (req_addr == 8'haa);
    }
endclass

program p_4_3;
    c_4_3 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "zx0x0001x0010zxx0x0xz0xzx1z01xzzzxxxxzxxxzzxzzxxxzzxzzxzxzzzxzxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
