class c_3_3;
    bit[7:0] req_addr = 8'h0;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:43)
    {
       (req_addr == 8'haa);
    }
endclass

program p_3_3;
    c_3_3 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "101z0x00zzz1zx0xx011xzz1111x0x0zxxzzzzxzzxzzxxxzxzxzzzzzzxzxxzxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
